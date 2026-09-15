#!/usr/bin/env bash
# asee9 setup: configures the OpenClaw agent with YOUR OpenRouter key.
#
# In a new Codespace this starts BY ITSELF in the first terminal (see
# .devcontainer/autostart.sh) and keeps doing so in new terminals until it has
# succeeded once. If a terminal only shows a line ending in $, type:
#
#   bash setup.sh               set up (or repair) the agent
#   bash setup.sh --reset-key   forget the saved key and ask for a new one
#
# Where the key comes from, first match wins:
#   1. a Codespaces secret named OPENROUTER_API_KEY (nothing to type)
#   2. the key saved by an earlier run, in ~/.openclaw/openclaw.json
#      (skipped by --reset-key)
#   3. the terminal asks you for it; what you paste does not show on screen
#
# Optional: a Codespaces secret (or environment variable) OPENCLAW_MODEL picks a
# different model, for example openrouter/google/gemini-3.8-flash (the default).
#
# Switches for test harnesses:
#   CLASSROOM_NO_CHAT=1   stop at READY instead of opening the agent
#   CLASSROOM_FORCE=1     run even though setup is already running in another terminal
set -uo pipefail

DEFAULT_MODEL="openrouter/google/gemini-3.8-flash"
# Pinned, not @latest: see .devcontainer/devcontainer.json for why. These must
# stay in step with the versions .devcontainer/postCreate.sh installs.
OPENCLAW_VERSION="2026.9.2"
PIP_PKGS="pandas==3.0.5 matplotlib==3.11.1 markdown==3.10.3 jinja2==3.1.6 requests==2.34.2 beautifulsoup4==4.15.0 feedparser==6.0.14"
KEY_URL="https://openrouter.ai/api/v1/key"
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Everything the exit trap touches is defined here, before anything can fail,
# so `set -u` can never trip inside the trap.
TMP=""
DOTS_PID=""
DOTS_MSG=""
READING=0
STOPPED=0                                     # 1 after Ctrl+C, a closed terminal, or a kill
READY_DONE=0                                  # 1 once READY is reached
LOCK="$HOME/.agentic-classroom-setup.lock"    # run-once lock shared with autostart.sh
CONFIG_LOG="$HOME/.agentic-classroom-config.log"   # why configuration failed; never a key
MARKER="$HOME/.agentic-classroom-ready"       # written at READY; autostart.sh then stays quiet
SITE_URL_FILE="$HOME/.agentic-classroom-site-url"
AUTOSTART_TAG="# agentic-classroom-autostart"
CONFIG="$HOME/.openclaw/openclaw.json"
# Anything this script starts (the agent included) must never re-trigger the
# autostart hook, even if it opens an interactive shell.
export CLASSROOM_NO_AUTOSTART=1

RESET_KEY=0
for arg in "$@"; do
  case "$arg" in
    --reset-key) RESET_KEY=1 ;;
    -h|--help) sed -n '2,22p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
    *) echo "Unknown option: $arg   (try: bash setup.sh --help)"; exit 2 ;;
  esac
done

# The key lives in shell variables only. A Codespaces secret arrives exported;
# take it and un-export it at once, so no tool this script runs (npm, pip, git,
# openclaw doctor, the agent) inherits it. It is handed to python through that
# one command's environment, and to curl through stdin, never on a command line.
SECRET_KEY="${OPENROUTER_API_KEY:-}"
SECRET_KEY="${SECRET_KEY//[[:space:]]/}"
unset OPENROUTER_API_KEY
KEY=""

hr() { echo "=============================================="; }

# ------------------------------------------------------------ moving dots
# While a slow step runs, show "Checking your key." ".." "..." on the terminal,
# then finish the line with ✅ or ❌. The animation goes to /dev/tty and only
# when there is a real terminal; in a log or a test harness the plain message
# is printed instead.
dots_tty() {
  [ -t 1 ] && { : >/dev/tty; } 2>/dev/null
}
dots_start() {   # $1 = message, without trailing dots
  dots_stop fail          # never leave an older loop running
  DOTS_MSG="$1"
  if dots_tty; then
    # $$ in a subshell is still this script's PID: if the script vanishes
    # without running its trap (kill -9), the loop notices and ends itself.
    (
      while kill -0 $$ 2>/dev/null; do
        for d in "." ".." "..."; do
          printf '\r\033[K%s%s' "$DOTS_MSG" "$d" >/dev/tty 2>/dev/null || exit 0
          sleep 0.4
        done
      done
    ) &
    DOTS_PID=$!
  else
    echo "${DOTS_MSG}..."
  fi
}
dots_stop() {    # $1 = ok | fail
  [ -n "$DOTS_MSG" ] || return 0
  local mark="✅"
  [ "${1:-ok}" = "ok" ] || mark="❌"
  if [ -n "$DOTS_PID" ]; then
    # A background job in a script ignores Ctrl+C, so it must be killed here.
    kill "$DOTS_PID" 2>/dev/null
    wait "$DOTS_PID" 2>/dev/null
    DOTS_PID=""
    printf '\r\033[K' >/dev/tty 2>/dev/null
  fi
  echo "${DOTS_MSG}... ${mark}" 2>/dev/null
  DOTS_MSG=""
}

# ------------------------------------------------------ run-once lock
# autostart.sh takes the lock (a directory holding a PID) before it starts this
# script, so a second terminal stays quiet while setup runs. We own the lock if
# it names us, our parent (the terminal that autostart ran in), no one, or a
# process that no longer exists.
lock_owner() {   # prints "PID START" from the lock, or nothing
  local pid="" start=""
  # 2>/dev/null BEFORE the <, or a missing pid file prints an error.
  { read -r pid; read -r start; } 2>/dev/null <"$LOCK/pid"
  printf '%s %s' "$pid" "$start"
}
proc_start() {   # $1 = PID; its start time, so a reused PID is not mistaken
  ps -o lstart= -p "$1" 2>/dev/null | awk '{$1=$1; print}'
}
lock_write() {
  printf '%s\n%s\n' "$$" "$(proc_start $$)" >"$LOCK/pid" 2>/dev/null
}
mutex_take() {   # $1 = mutex dir; same rules as __ac_mutex_take in autostart.sh
  mkdir "$1" 2>/dev/null && return 0
  [ -n "$(find "$1" -maxdepth 0 -mmin +1 2>/dev/null)" ] || return 1
  mv "$1" "$1.old.$$" 2>/dev/null || return 1
  rm -rf "$1.old.$$"
  mkdir "$1" 2>/dev/null
}
lock_held_by_other() {   # true if a different, live setup (or a shell starting one) holds it
  local pid start now
  read -r pid start <<<"$(lock_owner)"
  if [ -z "$pid" ]; then
    # Created a moment ago and the PID not written yet, or abandoned long ago.
    [ -z "$(find "$LOCK" -maxdepth 0 -mmin +1 2>/dev/null)" ]
    return
  fi
  [ "$pid" != "$$" ] && [ "$pid" != "$PPID" ] || return 1
  kill -0 "$pid" 2>/dev/null || return 1
  now="$(proc_start "$pid")"
  [ -z "$start" ] || [ -z "$now" ] || [ "$start" = "$now" ]
}
lock_claim() {
  local pid start
  if mkdir "$LOCK" 2>/dev/null; then lock_write; return 0; fi
  read -r pid start <<<"$(lock_owner)"
  # Handed over by autostart.sh (our parent).
  if [ -n "$pid" ] && { [ "$pid" = "$$" ] || [ "$pid" = "$PPID" ]; }; then
    lock_write; return 0
  fi
  if lock_held_by_other; then
    # Typical case: setup waits for the key in terminal 1, someone opens a
    # second terminal and types bash setup.sh there. Send them back to the first.
    if [ -t 0 ] && [ -z "${CLASSROOM_FORCE:-}" ]; then
      echo
      echo "⚠️  Setup has already started in another terminal."
      echo "   Switch to it: the list of terminals at the right edge of this panel."
      echo "   Pick the first one. If it asks for your key, paste it there."
      exit 0
    fi
    return 0   # harness or CLASSROOM_FORCE=1: carry on without owning the lock
  fi
  # Nobody live holds it: take it over, under the same short mutex as
  # autostart.sh, so two starters cannot both take one stale lock.
  mutex_take "$LOCK.takeover" || return 0
  if lock_held_by_other; then rmdir "$LOCK.takeover" 2>/dev/null; return 0; fi
  rm -rf "$LOCK"
  if mkdir "$LOCK" 2>/dev/null; then lock_write; fi
  rmdir "$LOCK.takeover" 2>/dev/null
  return 0
}
lock_release() {   # only if it holds our PID, or no PID at all
  [ -d "$LOCK" ] || return 0
  local pid start
  read -r pid start <<<"$(lock_owner)"
  if [ -z "$pid" ] || [ "$pid" = "$$" ]; then
    rm -rf "$LOCK"
  fi
}

# ------------------------------------------------ autostart line in ~/.bashrc
# One guarded line that sources .devcontainer/autostart.sh. postCreate.sh adds
# it when the Codespace is created; adding it here too repairs a Codespace where
# that step failed. Idempotent. Only inside a Codespace, never on a laptop.
install_autostart_line() {
  [ "${CODESPACES:-}" = "true" ] || return 0
  local hook="$ROOT/.devcontainer/autostart.sh" rc="$HOME/.bashrc" line
  [ -f "$hook" ] || return 0
  line="$(printf 'if [ -f %q ]; then . %q; fi  %s' "$hook" "$hook" "$AUTOSTART_TAG")"
  touch "$rc" 2>/dev/null || return 0
  grep -qxF "$line" "$rc" && return 0
  if grep -qF "$AUTOSTART_TAG" "$rc"; then
    grep -vF "$AUTOSTART_TAG" "$rc" >"$rc.ac.$$" && cat "$rc.ac.$$" >"$rc"
    rm -f "$rc.ac.$$"
  fi
  printf '\n%s\n' "$line" >>"$rc"
}

# ------------------------------------------------- the pasted-command catch
# Setup starts by itself, so people sometimes type "bash setup.sh" at the key
# prompt, and with hidden input they cannot see that they did. A real key
# (sk-or-...) is never treated as a command, whatever letters it contains.
entry_is_command() {
  case "$(printf '%s' "$1" | tr -d '[:space:]')" in
    sk-or-*) return 1 ;;
  esac
  case "$(printf '%s' "$1" | tr '[:upper:]' '[:lower:]')" in
    *setup*|*openclaw*|*bash*) return 0 ;;
  esac
  return 1
}

# ------------------------------------------------------------ exit paths
on_exit() {
  dots_stop fail
  # Stopped at the hidden key prompt: turn echo back on and end the line.
  if [ "$READING" -eq 1 ]; then
    stty echo </dev/tty 2>/dev/null
    echo
  fi
  if [ -n "$TMP" ]; then rm -rf "$TMP"; fi
  lock_release
  if [ "$STOPPED" -eq 1 ] && [ "$READY_DONE" -eq 1 ]; then
    echo "To open the agent, type: openclaw chat" 2>/dev/null
  elif [ "$STOPPED" -eq 1 ]; then
    echo "Setup stopped. To start again, type: bash setup.sh" 2>/dev/null
  fi
}
# Installed BEFORE lock_claim, so a terminal closed at any point from here on
# releases the run-once lock.
trap on_exit EXIT
trap 'STOPPED=1; exit 130' INT
trap 'STOPPED=1; exit 143' TERM
trap 'STOPPED=1; exit 129' HUP

die() {
  dots_stop fail
  echo
  echo "❌ $1"
  echo
  echo "   $2"
  echo "   Still stuck? See the Troubleshooting table in README.md."
  exit 1
}

lock_claim

hr; echo " asee9: agentic AI setup"; hr
echo "Repository version: $(git -C "$ROOT" rev-parse --short HEAD 2>/dev/null || echo unknown)"
if [ -n "${CLASSROOM_AUTOSTARTED:-}" ]; then
  echo "Setup started by itself."
fi

# Future terminals in this Codespace start setup by themselves until READY.
install_autostart_line 2>/dev/null || true

# Public site on port 8000. autostart.sh starts it too (there is no
# postAttachCommand: after Trust it opens a new terminal that steals focus);
# this is belt and braces for a terminal where autostart did not run. In the
# background, idempotent, Codespaces only.
if [ -n "${CODESPACE_NAME:-}" ] && [ -f "$ROOT/.devcontainer/site-public.sh" ] \
   && [ ! -s "$SITE_URL_FILE" ]; then
  ( setsid nohup bash "$ROOT/.devcontainer/site-public.sh" >/dev/null 2>&1 </dev/null & ) 2>/dev/null
fi

# ------------------------------------------------------------- 1. tooling
# Everything that does not need your key happens first, so a container problem
# surfaces before you are asked for a key. The container normally installs these
# when it is created; if that failed, repair it here.
if ! command -v openclaw >/dev/null 2>&1; then
  echo "Installing the agent (about a minute; this only happens once)..."
  for attempt in 1 2 3; do
    npm install -g "openclaw@${OPENCLAW_VERSION}" >/tmp/openclaw-install.log 2>&1 && break
    echo "   attempt ${attempt} did not succeed; retrying..."
    sleep 5
  done
  hash -r
fi
command -v openclaw >/dev/null 2>&1 || die "The agent could not be installed." \
  "Read the last lines of /tmp/openclaw-install.log. Deleting this Codespace and creating a new one often fixes it."
echo "✅ Agent installed: $(openclaw --version 2>/dev/null | head -1)"

python3 -c 'import pandas, matplotlib, markdown, jinja2, requests, bs4, feedparser' 2>/dev/null || {
  echo "Installing Python libraries..."
  # shellcheck disable=SC2086
  pip install --user --quiet $PIP_PKGS >/tmp/python-install.log 2>&1 || true
  python3 -c 'import pandas, matplotlib, markdown, jinja2, requests, bs4, feedparser' 2>/dev/null || {
    echo "⚠️  Some Python libraries did not install (details: /tmp/python-install.log)."
    echo "   The agent still works; it may not be able to draw charts or build pages."
  }
}

TMP="$(mktemp -d)"   # private to this user (mode 700); removed on every exit

# ------------------------------------------------------------- 2. the model
MODEL="${OPENCLAW_MODEL:-$DEFAULT_MODEL}"
MODEL="${MODEL//[[:space:]]/}"
case "$MODEL" in
  */*) ;;
  *) die "OPENCLAW_MODEL is set to \"$MODEL\", which is not a model name." \
         "Use the full form, for example ${DEFAULT_MODEL}, or delete that secret." ;;
esac
[ "$MODEL" = "$DEFAULT_MODEL" ] || echo "Model from OPENCLAW_MODEL: $MODEL"

# ------------------------------------------------------------- 3. the key
stored_key() {   # prints the key saved in openclaw.json, or nothing
  python3 -c '
import json, os, sys
try:
    with open(os.path.expanduser("~/.openclaw/openclaw.json")) as f:
        v = json.load(f).get("env", {}).get("vars", {}).get("OPENROUTER_API_KEY", "")
    sys.stdout.write(v if isinstance(v, str) else "")
except Exception:
    pass
' 2>/dev/null
}
forget_stored_key() {
  [ -f "$CONFIG" ] || return 0
  python3 -c '
import json, os
p = os.path.expanduser("~/.openclaw/openclaw.json")
try:
    with open(p) as f:
        cfg = json.load(f)
except Exception:
    cfg = {}
cfg.get("env", {}).get("vars", {}).pop("OPENROUTER_API_KEY", None)
with open(p, "w") as f:
    json.dump(cfg, f, indent=2)
os.chmod(p, 0o600)
' 2>>"$CONFIG_LOG"
}

# check_key: asks OpenRouter about $KEY without spending credit. The key goes
# to curl as a config file on stdin (printf is a shell builtin, so the key is
# never on any command line). Sets HTTP to the status, 000 on a network failure.
check_key() {
  HTTP="$(printf 'header = "Authorization: Bearer %s"\n' "$KEY" \
    | curl -s -m 20 -K - -o "$TMP/keycheck.json" -w '%{http_code}' "$KEY_URL")"
  # When curl cannot connect it prints 000 itself AND exits non-zero.
  HTTP="${HTTP:0:3}"; HTTP="${HTTP:-000}"
}
key_looks_right() {
  [[ "$KEY" =~ ^sk-or-[A-Za-z0-9_-]+$ ]]
}
credit_report() {   # reads only the response body; never prints the key or its label
  local r
  r="$(python3 - "$TMP/keycheck.json" <<'PYEOF' 2>/dev/null
import json, sys
try:
    d = json.load(open(sys.argv[1])).get("data")
except Exception:
    d = None
if isinstance(d, dict) and "limit" in d:
    lim, rem = d.get("limit"), d.get("limit_remaining")
    num = lambda x: isinstance(x, (int, float)) and not isinstance(x, bool)
    if lim is None:
        print("NOLIMIT")
    elif num(lim) and num(rem):
        print("LIMIT $%.2f of the $%.2f limit left" % (rem, lim))
    elif num(lim):
        print("LIMIT $%.2f limit" % lim)
PYEOF
)"
  case "$r" in
    NOLIMIT)
      echo "⚠️  This key has no credit limit. Anything that uses it can spend without a cap."
      echo "   Set a limit (\$5-10 is plenty) at https://openrouter.ai/settings/keys" ;;
    LIMIT*) echo "   Credit on this key: ${r#LIMIT }." ;;
  esac
}
# One check of a key that was not typed (secret or saved). Returns 0 if good,
# 1 if OpenRouter refused it; dies on a network or unexpected failure.
check_quiet_key() {   # $1 = where it came from, for messages
  dots_start "Checking your key"
  check_key
  case "$HTTP" in
    200) dots_stop ok; return 0 ;;
    402) dots_stop ok
         echo "⚠️  OpenRouter accepted the key but says the account is out of credit (HTTP 402)."
         echo "   Add credit at https://openrouter.ai/settings/credits. The agent will fail until you do."
         return 0 ;;
    401|403) dots_stop fail; return 1 ;;
    000) die "Could not reach OpenRouter (network)." \
             "Check your connection, then run bash setup.sh again." ;;
    *)   die "Unexpected response from OpenRouter (HTTP $HTTP) while checking $1." \
             "Wait a minute, then run bash setup.sh again." ;;
  esac
}

rm -f "$CONFIG_LOG"
( umask 077; : >"$CONFIG_LOG" ) 2>/dev/null

if [ "$RESET_KEY" -eq 1 ]; then
  # Forget first, and drop the ready marker, so a reset abandoned halfway is
  # picked up again by the next terminal instead of leaving a keyless agent.
  forget_stored_key
  rm -f "$MARKER"
  echo "Forgot the saved key."
fi

if [ -n "$SECRET_KEY" ]; then
  echo "Using your Codespaces secret OPENROUTER_API_KEY"
  if [ "$RESET_KEY" -eq 1 ]; then
    echo "   (--reset-key cannot replace a secret. To change the key, edit the secret at"
    echo "    https://github.com/settings/codespaces, then stop and restart this Codespace.)"
  fi
  KEY="$SECRET_KEY"
  key_looks_right || die "The Codespaces secret OPENROUTER_API_KEY does not look like an OpenRouter key (it should start with sk-or-)." \
    "Fix the secret at https://github.com/settings/codespaces, then stop and restart this Codespace."
  check_quiet_key "your Codespaces secret" || die "OpenRouter did not accept the key in your Codespaces secret OPENROUTER_API_KEY (HTTP $HTTP)." \
    "Check the key at https://openrouter.ai/settings/keys, update the secret at https://github.com/settings/codespaces, then stop and restart this Codespace."
elif [ "$RESET_KEY" -eq 0 ] && KEY="$(stored_key)" && [ -n "$KEY" ]; then
  echo "Using the key saved by your last setup (to change it: bash setup.sh --reset-key)"
  if ! key_looks_right || ! check_quiet_key "your saved key"; then
    echo "   The saved key no longer works. Forgetting it."
    forget_stored_key
    KEY=""
  fi
else
  KEY=""
fi

if [ -z "$KEY" ]; then
  { : </dev/tty; } 2>/dev/null || die "No terminal to type a key into." \
    "Add a Codespaces secret named OPENROUTER_API_KEY (see README.md), or run bash setup.sh in a terminal."
  ATTEMPT=0
  while :; do
    ATTEMPT=$((ATTEMPT + 1))
    echo
    echo "Paste or type your OpenRouter key (it starts with sk-or-). It will not show on screen."
    echo "Then press Enter."
    printf "> "
    ENTRY=""
    READING=1
    IFS= read -rs ENTRY </dev/tty || true
    READING=0
    echo   # hidden input does not echo the Enter either

    # Someone typed "bash setup.sh" at the prompt. Not counted as an attempt.
    if entry_is_command "$ENTRY"; then
      echo "Setup is already running. Paste only your OpenRouter key."
      ATTEMPT=$((ATTEMPT - 1))
      continue
    fi

    KEY="${ENTRY//[[:space:]]/}"
    ENTRY=""
    FAILED=""
    if [ "${#KEY}" -eq 0 ]; then
      FAILED="Nothing came through."
    else
      echo "Received ${#KEY} characters."
      if ! key_looks_right; then
        FAILED="That does not look like an OpenRouter key: it should start with sk-or- and have no spaces."
      else
        dots_start "Checking your key"
        check_key
        case "$HTTP" in
          200) dots_stop ok; break ;;
          402) dots_stop ok
               echo "⚠️  OpenRouter accepted the key but says the account is out of credit (HTTP 402)."
               echo "   Add credit at https://openrouter.ai/settings/credits. The agent will fail until you do."
               break ;;
          401|403) dots_stop fail
               FAILED="That key was not accepted (HTTP $HTTP)." ;;
          000) die "Could not reach OpenRouter (network)." \
                   "Check your connection, then run bash setup.sh again." ;;
          *)   die "Unexpected response from OpenRouter (HTTP $HTTP)." \
                   "Wait a minute, then run bash setup.sh again." ;;
        esac
      fi
    fi
    KEY=""
    if [ "$ATTEMPT" -ge 3 ]; then
      die "$FAILED Three tries did not work, so setup stopped." \
          "Copy the key again from https://openrouter.ai/settings/keys (or create a new one), then run bash setup.sh again."
    fi
    echo "   $FAILED Try again ($((3 - ATTEMPT)) left)."
  done
fi
credit_report

# --------------------------------------------------------- 4. configure agent
dots_start "Configuring the agent"
# Write the config directly (OpenClaw 2026.9 schema): the key under env.vars,
# the model pinned as primary and allow-listed, memory search off (it would
# otherwise try to reach an OpenAI embeddings endpoint and log errors on every
# turn), the agent's working folder = this repository, and every tool call shown
# as an Exec card. Then let doctor normalize anything version-specific. The file
# is mode 600 in a mode 700 folder. Errors go to $CONFIG_LOG; Python's error
# text names no key value.
OPENROUTER_API_KEY="$KEY" CLASSROOM_ROOT="$ROOT" python3 - "$MODEL" >/dev/null 2>>"$CONFIG_LOG" <<'PYEOF' \
  || die "Could not write the agent configuration." \
         "Run bash setup.sh again (details: $CONFIG_LOG)."
import json, os, sys
model = sys.argv[1]
path = os.path.expanduser("~/.openclaw/openclaw.json")
os.makedirs(os.path.dirname(path), exist_ok=True)
os.chmod(os.path.dirname(path), 0o700)
cfg = {}
if os.path.exists(path):
    with open(path) as f:
        try: cfg = json.load(f)
        except Exception: cfg = {}
cfg.setdefault("env", {}).setdefault("vars", {})["OPENROUTER_API_KEY"] = os.environ["OPENROUTER_API_KEY"]
d = cfg.setdefault("agents", {}).setdefault("defaults", {})
d.setdefault("model", {})["primary"] = model
d.setdefault("modelPolicy", {})["allow"] = [model]
d.pop("models", None)
# Run the agent inside the repository so any file it writes lands where the
# editor shows it.
d["cwd"] = os.environ["CLASSROOM_ROOT"]
# Show each tool call as an "Exec" card in openclaw chat. Off by default, the
# screen shows only the prompt and the final answer, and the agent's loop
# (write a script, run it, fix it) is invisible.
d["verboseDefault"] = "on"
cfg.setdefault("memory", {}).setdefault("search", {})["enabled"] = False
fd = os.open(path, os.O_WRONLY | os.O_CREAT | os.O_TRUNC, 0o600)
with os.fdopen(fd, "w") as f:
    json.dump(cfg, f, indent=2)
os.chmod(path, 0o600)
print("OpenClaw pinned to", model)
PYEOF
KEY=""
openclaw doctor --fix >/dev/null 2>&1 || true
# OpenClaw's workspace ships a first-run "introduce yourself and pick a name"
# ritual (BOOTSTRAP.md) that would hijack your first prompt. Remove it and give
# the agent a fixed identity with the rules for the public site/ folder.
WS="$HOME/.openclaw/workspace"
mkdir -p "$WS"
rm -f "$WS/BOOTSTRAP.md"
cat > "$WS/IDENTITY.md" <<'IDEOF'
# IDENTITY.md - Who Am I?

- **Name:** asee9 Agent
- **Creature:** AI coding agent
- **Vibe:** plain, careful, shows its work
- **Emoji:** 🔧

## Rules

- Never print environment variables or the contents of ~/.openclaw.
- Never read or print ~/.config/netlify (it holds the human's Netlify token).

## Rules for the site/ folder

- Everything in `site/` is public on the internet. It is already being served; never start a web server.
- Never put keys, tokens or environment variables in `site/`, and never run `gh`.
- Never create a symlink in `site/`: only real files are served and published.
- Before saying a site is done, run: python3 .devcontainer/site-check.py
- Never run `publish-site.sh` (the permanent Netlify website). Publishing is the human's decision: when a site is ready, tell them to run `bash publish-site.sh` themselves.
IDEOF
if ! openclaw config validate >>"$CONFIG_LOG" 2>&1; then
  die "The agent did not accept its configuration." \
      "Run bash setup.sh again (details: $CONFIG_LOG)."
fi
# doctor may rewrite the file or leave a backup beside it: keep all of them private.
chmod 700 "$HOME/.openclaw" 2>/dev/null
chmod 600 "$HOME/.openclaw"/openclaw.json* 2>/dev/null
dots_stop ok

# Your own documents for the exercises. Gitignored: never committed.
mkdir -p "$ROOT/mine"
DOCS="$(find "$ROOT/mine" -type f ! -name '.*' 2>/dev/null | wc -l | tr -d ' ')"

# ------------------------------------------------------------------ READY
# Marker first, then the lock, so there is never a moment when a new terminal
# sees neither and starts setup again.
touch "$MARKER" 2>/dev/null
READY_DONE=1
lock_release
rm -rf "$TMP"; TMP=""

echo
hr
echo "  READY."
echo
echo "  Model:           $MODEL"
echo "  Your documents:  mine/   (${DOCS} files; never committed)"
echo "  Exercises:       exercises/"
if [ -s "$SITE_URL_FILE" ]; then
  echo "  Your public site (files in site/):  $(head -1 "$SITE_URL_FILE")"
elif [ -n "${CODESPACE_NAME:-}" ]; then
  echo "  Your site (files in site/): the Ports tab, port 8000"
else
  # Not a Codespace: nothing started the server, so do not claim it is running.
  echo "  Your site (files in site/): bash .devcontainer/site-public.sh serves it on port 8000"
fi
echo "  Permanent website: bash publish-site.sh"
echo
echo "  Enlarge this panel: the square button at its top right, just left of the X."
hr

# A second `openclaw chat` fails while one is open ("another OpenClaw process
# owns gateway-lifecycle").
agent_open() {
  command -v pgrep >/dev/null 2>&1 || return 1
  pgrep -f 'openclaw[^[:space:]]*[- ]chat' >/dev/null 2>&1
}

if [ -t 0 ] && [ -z "${CLASSROOM_NO_CHAT+x}" ] && agent_open; then
  echo "The agent is already open in another terminal: the list at the right edge of this panel."
  echo "If it is not there, type: openclaw chat"
elif [ -t 0 ] && [ -z "${CLASSROOM_NO_CHAT+x}" ]; then
  dots_start "Starting the agent"
  sleep 1.5
  dots_stop ok
  # Not exec: when the agent exits, the terminal lands at $ with this message.
  # Ctrl+C belongs to the agent now, as it would if you had typed the command.
  trap - INT TERM HUP
  # Every credential this environment may carry is taken out of the agent's
  # environment: the model key, the Netlify token and site id (so the Netlify
  # publish script cannot deploy behind your back, even with --yes), and the
  # Codespace's GitHub token (so `gh` and `git push` have nothing to
  # authenticate with). The agent runs as you and could still read a file you
  # saved, but nothing is handed to it.
  env -u OPENROUTER_API_KEY -u NETLIFY_AUTH_TOKEN -u NETLIFY_SITE_ID \
      -u GITHUB_TOKEN -u GH_TOKEN -u CLASSROOM_ROOT -u CLASSROOM_AUTOSTARTED \
      -u CLASSROOM_FORCE openclaw chat
  echo
  echo "The agent has closed. To open it again, type: openclaw chat"
else
  echo "Start the agent: openclaw chat"
fi
