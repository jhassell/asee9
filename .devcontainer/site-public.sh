#!/usr/bin/env bash
# Started detached by .devcontainer/autostart.sh in each VS Code terminal of a
# Codespace (and by setup.sh). There is deliberately no postAttachCommand.
#
# Serves ONLY the site/ folder on port 8000 and makes port 8000 public, so an
# agent-built page is live at https://<codespace>-8000.app.github.dev with no
# clicks. The server is site-server.py, which refuses any request whose real
# path is outside site/: the repository root, mine/ (your own documents) and
# ~/.openclaw (your key) stay unreachable even through a symlink inside site/.
#
# If your GitHub organization does not allow public ports, the port stays
# private: the site then opens only for you, from the Ports tab.
#
# Never fails and prints nothing: every problem is logged to ~/.agentic-classroom-site.log.

here="$(cd "$(dirname "$0")" && pwd)"
root="$(cd "$here/.." && pwd)"
site="$root/site"
server="$here/site-server.py"
log="$HOME/.agentic-classroom-site.log"
say() { printf '%s %s\n' "$(date -u +%H:%M:%S)" "$*" >>"$log"; }

mkdir -p "$site"
if [ ! -e "$site/index.html" ]; then
  cat >"$site/index.html" <<'EOF'
<!doctype html>
<meta charset="utf-8">
<title>Your site</title>
<!-- This folder is PUBLIC on the internet while the Codespace runs, and it is
     already being served. Do not start a web server. Never put keys, tokens,
     student data or anything private here. Real files only: a symlink is
     neither served nor published.
     Check with: python3 .devcontainer/site-check.py -->
<h1>Your site will appear here</h1>
<p>Ask the agent to build files in the site/ folder, then refresh this page.</p>
EOF
fi

if ! curl -s -o /dev/null --max-time 2 http://127.0.0.1:8000/; then
  # No fallback to `python3 -m http.server`: it would follow a symlink out of
  # site/ and publish whatever it points at.
  if [ ! -f "$server" ]; then
    say "site-server.py is missing; nothing is being served"
    exit 0
  fi
  setsid nohup python3 "$server" "$site" 8000 >>"$log" 2>&1 </dev/null &
  say "server started for $site"
fi
for i in $(seq 1 20); do
  curl -s -o /dev/null --max-time 2 http://127.0.0.1:8000/ && break
  sleep 0.5
done

if [ -z "${CODESPACE_NAME:-}" ]; then
  say "not a Codespace; left private"
  exit 0
fi
if ! command -v gh >/dev/null 2>&1; then
  say "gh not installed; left private"
  exit 0
fi

# The port is registered a moment after the server starts; retry for ~1 min.
for i in $(seq 1 12); do
  if gh codespace ports visibility 8000:public -c "$CODESPACE_NAME" >>"$log" 2>&1; then
    url="https://$CODESPACE_NAME-8000.${GITHUB_CODESPACES_PORT_FORWARDING_DOMAIN:-app.github.dev}"
    printf '%s\n' "$url" >"$HOME/.agentic-classroom-site-url"
    say "public: $url"
    exit 0
  fi
  say "visibility attempt $i failed"
  sleep 5
done
say "could not make port 8000 public"
exit 0
