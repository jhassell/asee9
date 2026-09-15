#!/usr/bin/env bash
# publish-site.sh: put the site/ folder on a PERMANENT public website (Netlify).
#
# You run this yourself. The agent is told never to run it: publishing is a
# human decision. While a Codespace runs, site/ is already live on port 8000;
# that link dies with the Codespace. This gives it a URL that stays.
#
#   bash publish-site.sh                  check, confirm, publish
#   bash publish-site.sh --name my-beams  first publish only: ask for my-beams.netlify.app
#   bash publish-site.sh --yes            skip the confirmation (for CI)
#   bash publish-site.sh --forget-token   delete the saved Netlify token and stop
#
# What it does, in order:
#   1. runs python3 .devcontainer/site-check.py and stops if site/ is not ready
#   2. shows how many files and how much data will go public, and asks you
#   3. finds your Netlify token, first match wins:
#        a Codespaces secret NETLIFY_AUTH_TOKEN
#        a token saved earlier at ~/.config/netlify/token (mode 600, outside the repo)
#        the terminal asks for it (hidden) and offers to save it there
#      Create one at https://app.netlify.com : your avatar -> User settings ->
#      Applications -> Personal access tokens -> New access token.
#   4. finds the site: NETLIFY_SITE_ID (secret or variable), else the id saved at
#      ~/.config/netlify/site-id-<repository folder name>; with neither it creates
#      a new Netlify site and saves its id
#   5. zips site/ (symlinks are skipped here too, though step 1 already refuses
#      them), uploads it, waits until Netlify says ready, prints the permanent URL
#
# The token is never put on a command line, in a log, or on screen: curl reads it
# from a config on stdin.
set -uo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SITE="$ROOT/site"
API="https://api.netlify.com/api/v1"
REPO_NAME="$(basename "$ROOT")"
NETLIFY_DIR="$HOME/.config/netlify"
TOKEN_FILE="$NETLIFY_DIR/token"
SITE_ID_FILE="$NETLIFY_DIR/site-id-$REPO_NAME"
POLL_SECONDS="${PUBLISH_POLL_SECONDS:-3}"     # seconds between deploy status checks
POLL_LIMIT="${PUBLISH_POLL_LIMIT:-120}"       # give up waiting after this many seconds
# Whole seconds only: bash cannot add a fraction, so a value like 0.5 would
# leave the waited-so-far count at 0 and the wait would never time out.
[[ "$POLL_SECONDS" =~ ^[1-9][0-9]*$ ]] || POLL_SECONDS=3
[[ "$POLL_LIMIT"   =~ ^[1-9][0-9]*$ ]] || POLL_LIMIT=120
CONFIRM_TEXT="Publish site/ to a permanent public Netlify URL? Anyone with the link can see it. [y/N]"

# Take the secrets into shell variables and un-export them at once, so python3
# and anything else this script starts never inherit the token.
SECRET_TOKEN="${NETLIFY_AUTH_TOKEN:-}"
SECRET_TOKEN="${SECRET_TOKEN//[[:space:]]/}"
ENV_SITE_ID="${NETLIFY_SITE_ID:-}"
ENV_SITE_ID="${ENV_SITE_ID//[[:space:]]/}"
unset NETLIFY_AUTH_TOKEN NETLIFY_SITE_ID
TOKEN=""
TOKEN_FROM=""        # secret | file | typed
SAVE_TYPED=0
TMP=""
READING=0

NAME=""
ASSUME_YES=0
FORGET=0
while [ $# -gt 0 ]; do
  case "$1" in
    --name)   [ $# -ge 2 ] || { echo "--name needs a site name, for example: --name my-beams"; exit 2; }
              NAME="$2"; shift ;;
    --name=*) NAME="${1#--name=}" ;;
    --yes|-y) ASSUME_YES=1 ;;
    --forget-token) FORGET=1 ;;
    -h|--help) sed -n '2,30p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
    *) echo "Unknown option: $1   (try: bash publish-site.sh --help)"; exit 2 ;;
  esac
  shift
done

on_exit() {
  if [ "$READING" -eq 1 ]; then stty echo </dev/tty 2>/dev/null; echo; fi
  if [ -n "$TMP" ]; then rm -rf "$TMP"; fi
  TOKEN=""
}
trap on_exit EXIT
trap 'exit 130' INT
trap 'exit 143' TERM
trap 'exit 129' HUP

die() {   # $1 = what went wrong, $2 = what to do
  echo
  echo "❌ $1"
  [ -z "${2:-}" ] || echo "   $2"
  exit 1
}

have_tty() { { : </dev/tty; } 2>/dev/null; }

# ------------------------------------------------------------ --forget-token
if [ "$FORGET" -eq 1 ]; then
  if [ -e "$TOKEN_FILE" ] || [ -L "$TOKEN_FILE" ]; then
    rm -f "$TOKEN_FILE" && echo "Forgot the Netlify token saved at ~/.config/netlify/token."
  else
    echo "No Netlify token was saved at ~/.config/netlify/token."
  fi
  if [ -n "$SECRET_TOKEN" ]; then
    echo "A Codespaces secret NETLIFY_AUTH_TOKEN is also set. Delete it at"
    echo "https://github.com/settings/codespaces, then stop and restart this Codespace."
  fi
  echo "To revoke the token itself: https://app.netlify.com -> User settings -> Applications."
  exit 0
fi

# ------------------------------------------------------------ inputs that need no network
if [ -n "$NAME" ] && ! [[ "$NAME" =~ ^[a-z0-9]([a-z0-9-]{0,61}[a-z0-9])?$ ]]; then
  die "\"$NAME\" is not a usable Netlify site name." \
      "Use lowercase letters, digits and hyphens, for example: --name my-beams"
fi
if [ -n "$ENV_SITE_ID" ] && ! [[ "$ENV_SITE_ID" =~ ^[A-Za-z0-9._-]+$ ]]; then
  die "NETLIFY_SITE_ID does not look like a Netlify site id." \
      "Copy the Site ID from Netlify (Site configuration -> General), or delete that secret."
fi

# ------------------------------------------------------------ 1. check site/
[ -d "$SITE" ] || die "There is no site/ folder yet." \
  "Ask the agent to build a website in site/, then run bash publish-site.sh again."
[ -n "$(find "$SITE" -type f 2>/dev/null | head -1)" ] || die "site/ is empty." \
  "Ask the agent to build a website in site/, then run bash publish-site.sh again."

echo "Checking site/ before it goes public..."
python3 "$ROOT/.devcontainer/site-check.py" "$SITE" \
  || die "site/ did not pass the check, so nothing was published." \
         "Fix the problems listed above (or ask the agent to), then run bash publish-site.sh again."

TMP="$(mktemp -d)"   # private to this user; removed on every exit

# summary | zip <out>: one walk of site/, regular files only, symlinks skipped.
site_files() {
  python3 - "$SITE" "$@" <<'PYEOF'
import os, sys, zipfile
site, mode = sys.argv[1], sys.argv[2]
files, skipped = [], 0
for d, dirs, names in os.walk(site, followlinks=False):
    for n in list(dirs):
        if os.path.islink(os.path.join(d, n)):
            dirs.remove(n); skipped += 1
    for n in names:
        p = os.path.join(d, n)
        if os.path.islink(p) or not os.path.isfile(p):
            skipped += 1; continue
        files.append(p)
files.sort()
if mode == "summary":
    size = sum(os.path.getsize(p) for p in files)
    for unit in ("bytes", "KB", "MB", "GB"):
        if size < 1024 or unit == "GB":
            break
        size /= 1024.0
    shown = ("%d %s" % (size, unit)) if unit == "bytes" else ("%.1f %s" % (size, unit))
    print("%d file(s), %s" % (len(files), shown))
    if skipped:
        print("SKIPPED %d symlink(s) or special file(s)" % skipped)
else:
    with zipfile.ZipFile(sys.argv[3], "w", zipfile.ZIP_DEFLATED) as z:
        for p in files:
            z.write(p, os.path.relpath(p, site).replace(os.sep, "/"))
PYEOF
}

# ------------------------------------------------------------ 2. confirm
SUMMARY="$(site_files summary)" || die "Could not read site/." ""
echo
echo "About to publish site/: $(printf '%s\n' "$SUMMARY" | head -1)."
if printf '%s\n' "$SUMMARY" | grep -q '^SKIPPED'; then
  echo "   $(printf '%s\n' "$SUMMARY" | sed -n 's/^SKIPPED \(.*\)/\1 will NOT be uploaded./p')"
fi
if [ "$ASSUME_YES" -eq 1 ]; then
  echo "$CONFIRM_TEXT yes (--yes)"
else
  have_tty || die "No terminal to confirm in." "Run bash publish-site.sh in a terminal, or add --yes."
  printf '%s ' "$CONFIRM_TEXT"
  ANSWER=""
  IFS= read -r ANSWER </dev/tty || true
  ANSWER="$(printf '%s' "$ANSWER" | tr '[:upper:]' '[:lower:]' | tr -d '[:space:]')"
  case "$ANSWER" in
    y|yes) ;;
    *) echo "Not published. Nothing was sent."; exit 0 ;;
  esac
fi

# ------------------------------------------------------------ 3. the token
file_is_private() {   # true if $1 is a regular file, not a symlink, not readable by group/other
  [ -f "$1" ] && [ ! -L "$1" ] || return 1
  local m
  m="$(stat -c %a "$1" 2>/dev/null || stat -f %Lp "$1" 2>/dev/null)"
  [ -n "$m" ] || return 1
  [ "$(( 8#$m & 8#077 ))" -eq 0 ]
}

if [ -n "$SECRET_TOKEN" ]; then
  echo "Using your Codespaces secret NETLIFY_AUTH_TOKEN"
  TOKEN="$SECRET_TOKEN"; TOKEN_FROM="secret"
elif [ -e "$TOKEN_FILE" ] || [ -L "$TOKEN_FILE" ]; then
  file_is_private "$TOKEN_FILE" || die "~/.config/netlify/token is a symlink or can be read by other users, so it was not used." \
    "Delete it (bash publish-site.sh --forget-token) and run bash publish-site.sh again."
  TOKEN="$(tr -d '\r\n' <"$TOKEN_FILE")"
  TOKEN="${TOKEN//[[:space:]]/}"
  [ -n "$TOKEN" ] || die "~/.config/netlify/token is empty." "Run bash publish-site.sh --forget-token, then run bash publish-site.sh again."
  echo "Using the Netlify token saved at ~/.config/netlify/token (to change it: bash publish-site.sh --forget-token)"
  TOKEN_FROM="file"
else
  have_tty || die "No Netlify token and no terminal to type one into." \
    "Add a Codespaces secret NETLIFY_AUTH_TOKEN at https://github.com/settings/codespaces, or run this in a terminal."
  echo
  echo "A Netlify personal access token is needed. To create one:"
  echo "  https://app.netlify.com -> your avatar -> User settings -> Applications"
  echo "  -> Personal access tokens -> New access token. Copy it."
  echo "Paste or type the token. It will not show on screen. Then press Enter."
  printf "> "
  ENTRY=""
  READING=1
  IFS= read -rs ENTRY </dev/tty || true
  READING=0
  echo
  TOKEN="${ENTRY//[[:space:]]/}"; ENTRY=""
  [ -n "$TOKEN" ] || die "Nothing came through, so nothing was published." "Run bash publish-site.sh again."
  echo "Received ${#TOKEN} characters."
  TOKEN_FROM="typed"
  printf 'Save it at ~/.config/netlify/token (private to you, outside the repository) so you are not asked again? [y/N] '
  ANSWER=""
  IFS= read -r ANSWER </dev/tty || true
  case "$(printf '%s' "$ANSWER" | tr '[:upper:]' '[:lower:]' | tr -d '[:space:]')" in
    y|yes) SAVE_TYPED=1 ;;
  esac
fi

# A token curl could not carry: a quote or a backslash picked up from a bad
# paste would end up inside the Authorization header and come back as an
# unexplained 401, sending you off to make a new token for what is a typo.
if ! [[ "$TOKEN" =~ ^[A-Za-z0-9_.-]+$ ]]; then
  case "$TOKEN_FROM" in
    secret) die "The Codespaces secret NETLIFY_AUTH_TOKEN has characters a Netlify token never contains - it was probably pasted with something extra." \
                "Copy it again from https://app.netlify.com -> User settings -> Applications -> Personal access tokens, fix the secret at https://github.com/settings/codespaces, then stop and restart this Codespace." ;;
    file)   die "The token saved at ~/.config/netlify/token has characters a Netlify token never contains - it was probably pasted with something extra." \
                "Run bash publish-site.sh --forget-token, then run bash publish-site.sh again and paste it." ;;
    *)      die "That token has characters a Netlify token never contains - it was probably pasted with something extra." \
                "Copy it again from User settings -> Applications -> Personal access tokens, then run bash publish-site.sh again." ;;
  esac
fi

save_typed_token() {   # after Netlify has accepted it, never before
  [ "$SAVE_TYPED" -eq 1 ] || return 0
  SAVE_TYPED=0
  ( umask 077; mkdir -p "$NETLIFY_DIR" && chmod 700 "$NETLIFY_DIR" \
    && rm -f "$TOKEN_FILE" && printf '%s' "$TOKEN" >"$TOKEN_FILE" && chmod 600 "$TOKEN_FILE" ) 2>/dev/null \
    && echo "Saved the token at ~/.config/netlify/token (mode 600). Forget it with: bash publish-site.sh --forget-token" \
    || echo "⚠️  Could not save the token; you will be asked again next time."
}

# ------------------------------------------------------------ talking to Netlify
# api METHOD URL OUTFILE [BODYFILE CONTENT-TYPE [MAX-SECONDS]]
# The Authorization header goes to curl as a config on stdin (printf is a shell
# builtin, so the token is on no command line). Sets HTTP; 000 = no connection.
api() {
  local method="$1" url="$2" out="$3" body="${4:-}" ctype="${5:-}" max="${6:-60}"
  local args=(-sS -m "$max" -K - -o "$out" -w '%{http_code}' -X "$method")
  if [ -n "$body" ]; then args+=(-H "Content-Type: $ctype" --data-binary "@$body"); fi
  HTTP="$(printf 'header = "Authorization: Bearer %s"\n' "$TOKEN" \
    | curl "${args[@]}" "$url" 2>"$TMP/curl.err")"
  HTTP="${HTTP:0:3}"; HTTP="${HTTP:-000}"
}

json_get() {   # $1 = file, $2... = keys to try in order; prints the first non-empty string
  python3 - "$@" <<'PYEOF' 2>/dev/null
import json, sys
try:
    d = json.load(open(sys.argv[1]))
except Exception:
    d = {}
for k in sys.argv[2:]:
    v = d.get(k) if isinstance(d, dict) else None
    if isinstance(v, (str, int)) and not isinstance(v, bool) and str(v):
        print(v); break
PYEOF
}

netlify_message() {   # Netlify's own error text, one line, short; never holds the token
  local m
  m="$(json_get "$1" message error_message errors error | head -1 | cut -c1-200)"
  [ -z "$m" ] || echo "   Netlify says: $m"
}

api_fail() {   # $1 = what we were doing, $2 = response file
  local what="$1" body="$2" fix
  case "$TOKEN_FROM" in
    secret) fix="Create a new token, update the secret NETLIFY_AUTH_TOKEN at https://github.com/settings/codespaces, then stop and restart this Codespace." ;;
    file)   fix="Run bash publish-site.sh --forget-token, then run bash publish-site.sh again and paste a new token." ;;
    *)      fix="Create a new token (User settings -> Applications -> Personal access tokens) and run bash publish-site.sh again." ;;
  esac
  case "$HTTP" in
    401) netlify_message "$body"
         die "Netlify did not accept the token (HTTP 401) while $what. Nothing was published." "$fix" ;;
    403) netlify_message "$body"
         die "Netlify refused (HTTP 403) while $what: this token may not manage that site." \
             "Use a token from the Netlify account that owns the site, or remove the saved site id ($SITE_ID_FROM_HINT)." ;;
    404) die "Netlify has no site with the id \"$SITE_ID\" for this token (HTTP 404)." \
             "Check it, or remove it so a new site is made: $SITE_ID_FROM_HINT" ;;
    422) netlify_message "$body"
         die "Netlify rejected the request (HTTP 422) while $what." \
             "If a site name was given with --name, it may be taken: try another name." ;;
    429) die "Netlify is rate-limiting requests (HTTP 429)." "Wait a minute, then run bash publish-site.sh again." ;;
    000) die "Could not reach Netlify (network) while $what." "Check your connection, then run bash publish-site.sh again." ;;
    *)   netlify_message "$body"
         die "Unexpected response from Netlify (HTTP $HTTP) while $what." "Wait a minute, then run bash publish-site.sh again." ;;
  esac
}

# ------------------------------------------------------------ 4. the site
SITE_ID=""
SITE_ID_FROM_HINT=""
if [ -n "$ENV_SITE_ID" ]; then
  SITE_ID="$ENV_SITE_ID"
  SITE_ID_FROM_HINT="edit or delete the NETLIFY_SITE_ID secret at https://github.com/settings/codespaces"
  echo "Using NETLIFY_SITE_ID: $SITE_ID"
elif [ -f "$SITE_ID_FILE" ] && [ ! -L "$SITE_ID_FILE" ]; then
  SITE_ID="$(tr -d '[:space:]' <"$SITE_ID_FILE")"
  SITE_ID_FROM_HINT="rm ~/.config/netlify/site-id-$REPO_NAME"
  [[ "$SITE_ID" =~ ^[A-Za-z0-9._-]+$ ]] || die "The saved site id in ~/.config/netlify/site-id-$REPO_NAME is damaged." \
    "Delete that file and run bash publish-site.sh again (a new site will be made)."
  echo "Using the Netlify site saved for $REPO_NAME: $SITE_ID"
fi
if [ -n "$SITE_ID" ] && [ -n "$NAME" ]; then
  echo "   (--name is ignored: this site already exists. Rename it in Netlify: Site configuration -> Change site name.)"
fi

if [ -z "$SITE_ID" ]; then
  echo "Creating a new Netlify site${NAME:+ named $NAME}..."
  if [ -n "$NAME" ]; then
    python3 -c 'import json,sys; print(json.dumps({"name": sys.argv[1]}))' "$NAME" >"$TMP/site.json"
  else
    printf '{}' >"$TMP/site.json"
  fi
  api POST "$API/sites" "$TMP/create.json" "$TMP/site.json" "application/json"
  case "$HTTP" in
    200|201) ;;
    *) SITE_ID_FROM_HINT="(none saved yet)"; api_fail "creating the site" "$TMP/create.json" ;;
  esac
  save_typed_token
  SITE_ID="$(json_get "$TMP/create.json" id site_id)"
  [[ "$SITE_ID" =~ ^[A-Za-z0-9._-]+$ ]] || die "Netlify created a site but its reply had no usable id." \
    "Look at https://app.netlify.com, copy the new site's Site ID into a Codespaces secret NETLIFY_SITE_ID, and run again."
  ( umask 077; mkdir -p "$NETLIFY_DIR" && chmod 700 "$NETLIFY_DIR" && printf '%s\n' "$SITE_ID" >"$SITE_ID_FILE" ) 2>/dev/null \
    || echo "⚠️  Could not save the site id at ~/.config/netlify/site-id-$REPO_NAME."
  SITE_ID_FROM_HINT="rm ~/.config/netlify/site-id-$REPO_NAME"
  echo "✅ Site created. Its id is saved at ~/.config/netlify/site-id-$REPO_NAME"
  echo "   This Codespace will reuse it. So that a NEW Codespace publishes to the same"
  echo "   site and URL, add a Codespaces secret at https://github.com/settings/codespaces:"
  echo "     Name:  NETLIFY_SITE_ID"
  echo "     Value: $SITE_ID"
fi

# ------------------------------------------------------------ 5. upload
site_files zip "$TMP/site.zip" 2>"$TMP/zip.err" || die "Could not zip site/." "Details: $(tail -1 "$TMP/zip.err")"
echo "Uploading site/ ($(printf '%s\n' "$SUMMARY" | head -1))..."
api POST "$API/sites/$SITE_ID/deploys" "$TMP/deploy.json" "$TMP/site.zip" "application/zip" 300
case "$HTTP" in
  200|201) ;;
  *) api_fail "uploading the site" "$TMP/deploy.json" ;;
esac
save_typed_token
DEPLOY_ID="$(json_get "$TMP/deploy.json" id)"
[[ "$DEPLOY_ID" =~ ^[A-Za-z0-9._-]+$ ]] || die "Netlify accepted the upload but its reply had no deploy id." \
  "Look at the site at https://app.netlify.com to see whether it went live."
STATE="$(json_get "$TMP/deploy.json" state)"

WAITED=0
printf 'Waiting for Netlify to finish'
while [ "$STATE" != "ready" ] && [ "$STATE" != "error" ]; do
  if [ "$WAITED" -ge "$POLL_LIMIT" ]; then
    echo
    die "Netlify had not finished after ${POLL_LIMIT} s (last state: ${STATE:-unknown})." \
        "It may still go live: look at the site's Deploys page at https://app.netlify.com, or run bash publish-site.sh again."
  fi
  sleep "$POLL_SECONDS"
  WAITED=$((WAITED + POLL_SECONDS))
  printf '.'
  api GET "$API/deploys/$DEPLOY_ID" "$TMP/status.json"
  case "$HTTP" in
    200) STATE="$(json_get "$TMP/status.json" state)"; cp "$TMP/status.json" "$TMP/deploy.json" ;;
    000|5??|429) ;;   # a blip: keep waiting until the time limit
    *) echo; api_fail "waiting for the deploy" "$TMP/status.json" ;;
  esac
done
echo

if [ "$STATE" = "error" ]; then
  netlify_message "$TMP/deploy.json"
  die "Netlify could not publish this upload (deploy state: error)." \
      "Look at the site's Deploys page at https://app.netlify.com for details."
fi

URL="$(json_get "$TMP/deploy.json" ssl_url url)"
echo "=============================================="
echo "  PUBLISHED."
echo
echo "  Permanent URL:  ${URL:-see https://app.netlify.com}"
echo
echo "  Anyone with the link can see it. To update it, change site/ and run"
echo "  bash publish-site.sh again: the same URL gets the new version."
echo "=============================================="
