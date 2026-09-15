#!/usr/bin/env bash
# Runs as the devcontainer's onCreateCommand: once while the Codespace is
# created (or inside a Codespaces prebuild, if you enable one).
#
# Deliberately NO blanket `set -e`: one failed install must not take the others
# down with it. Every step runs, reports, and leaves a log; setup.sh re-checks
# and repairs. This script never asks for or reads a key.

LOG=/tmp/agentic-classroom-postcreate.log
exec > >(tee -a "$LOG") 2>&1

# OpenClaw is PINNED, not @latest. See devcontainer.json for why.
OPENCLAW_VERSION="2026.9.2"

echo "Installing the agent (OpenClaw ${OPENCLAW_VERSION})..."
ok=0
for attempt in 1 2 3; do
  if npm install -g "openclaw@${OPENCLAW_VERSION}"; then ok=1; break; fi
  echo "npm attempt ${attempt} failed; retrying in 5s..."
  sleep 5
done
if [ "$ok" -eq 1 ]; then
  echo "OpenClaw ${OPENCLAW_VERSION} installed."
else
  echo "OpenClaw did not install here; setup.sh will install it."
fi

# Charting libraries, pinned like everything else in this container.
if pip install --user --quiet "pandas==3.0.5" "matplotlib==3.11.1"; then
  echo "pandas + matplotlib installed."
else
  echo "pandas/matplotlib did not install here; setup.sh will install them."
fi

# Site tools, for agent-built websites served from site/ (see site-public.sh).
# A separate pip call, so a failure here cannot take pandas/matplotlib down.
#   markdown + jinja2    write lessons in Markdown, render them into HTML pages
#   requests + bs4       fetch and read PUBLIC web pages as a site's source
#   feedparser           read public RSS/Atom feeds (news, arXiv listings)
SITE_PKGS="markdown==3.10.3 jinja2==3.1.6 requests==2.34.2 beautifulsoup4==4.15.0 feedparser==6.0.14"
# shellcheck disable=SC2086
if pip install --user --quiet $SITE_PKGS; then
  echo "Site tools installed."
else
  echo "Site tools did not install here; setup.sh will install them."
fi

# AUTOSTART. One guarded line in ~/.bashrc sources .devcontainer/autostart.sh,
# which starts setup.sh by itself in the first terminal you open. It does
# nothing here: there is no interactive VS Code terminal yet. Idempotent, and it
# never fails this script. setup.sh writes the identical line and tag.
install_autostart_line() {
  local hook rc="$HOME/.bashrc" tag="# agentic-classroom-autostart" line
  hook="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/autostart.sh"
  # The line is guarded by [ -f ], so a hook file missing from the commit would
  # make autostart silently do nothing. Say so in this log.
  [ -f "$hook" ] || echo "WARNING: $hook is missing; setup will NOT start by itself. Is it committed?"
  line="$(printf 'if [ -f %q ]; then . %q; fi  %s' "$hook" "$hook" "$tag")"
  touch "$rc" 2>/dev/null || return 0
  grep -qxF "$line" "$rc" && return 0
  if grep -qF "$tag" "$rc"; then
    grep -vF "$tag" "$rc" >"$rc.ac.$$" && cat "$rc.ac.$$" >"$rc"
    rm -f "$rc.ac.$$"
  fi
  printf '\n%s\n' "$line" >>"$rc"
}
if install_autostart_line; then
  echo "Autostart line present in ~/.bashrc."
else
  echo "Could not add the autostart line to ~/.bashrc (setup.sh will add it)."
fi

# The public site needs its server file. Like the autostart hook it is only a
# warning: site-public.sh serves nothing without it, and this log says why.
SITE_SERVER="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/site-server.py"
[ -f "$SITE_SERVER" ] \
  || echo "WARNING: $SITE_SERVER is missing; site/ will not be served. Is it committed?"

# GATE. Each install above tolerates failure, but a prebuild must not be marked
# ready without the tools in it. Check the real thing, not a log line, and fail
# the lifecycle command if anything is missing. (Without a prebuild, a failure
# here is repaired by setup.sh in the first terminal.)
FAIL=
openclaw --version 2>/dev/null | grep -qF "$OPENCLAW_VERSION" \
  || { echo "GATE FAILED: openclaw ${OPENCLAW_VERSION} is not installed"; FAIL=1; }
python3 -c 'import pandas, matplotlib' 2>/dev/null \
  || { echo "GATE FAILED: pandas/matplotlib do not import"; FAIL=1; }
python3 -c 'import markdown, jinja2, requests, bs4, feedparser' 2>/dev/null \
  || { echo "GATE FAILED: site tools do not import"; FAIL=1; }
gh --version 2>/dev/null | grep -qF "2.100.0" \
  || { echo "GATE FAILED: gh 2.100.0 is not installed (port 8000 cannot go public)"; FAIL=1; }
if [ -n "$FAIL" ]; then
  echo "Tooling incomplete. In the Codespace, bash setup.sh repairs it."
  exit 1
fi
echo "GATE PASSED: openclaw ${OPENCLAW_VERSION}, pandas, matplotlib, site tools, gh"

echo ""
echo "=============================================="
echo " Container ready."
echo " Next step: open a terminal. It asks for your OpenRouter key by itself"
echo " (or uses your Codespaces secret OPENROUTER_API_KEY)."
echo " If it only shows a line ending in \$, type:  bash setup.sh"
echo "=============================================="
