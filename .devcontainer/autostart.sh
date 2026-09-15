# asee9: start setup.sh by itself in the first terminal.
#
# SOURCED from ~/.bashrc, never run. postCreate.sh and setup.sh each add one
# guarded line that sources this file, so a change here reaches ~/.bashrc
# without touching it again.
#
# Safe to source in any shell: it sets no shell options, never calls exit, keeps
# every variable local to one function, and says nothing unless it starts setup.
#
# It runs `bash setup.sh` (not exec, so a failure or an agent exit lands at $)
# only when ALL of these hold:
#   1. the shell is interactive, with a terminal on stdin and stdout (setup reads
#      the key from it; this also keeps VS Code's background environment probe,
#      a `bash -ic` with no terminal, from ever starting setup)
#   2. TERM_PROGRAM is vscode or codespaces. Neither is set by
#      `gh codespace ssh` or while the container is being built.
#   3. CLASSROOM_NO_AUTOSTART is unset (setup.sh sets it for everything it
#      starts; set it yourself to switch autostart off)
#   4. there is no ~/.agentic-classroom-ready marker. setup.sh writes it at
#      READY, so autostart runs in every new terminal until setup has succeeded
#      once, and never after. There is no date cutoff.
#   5. the run-once lock ~/.agentic-classroom-setup.lock can be taken: a
#      directory holding a PID and that process's start time. A lock whose
#      process is gone (or whose PID now belongs to a different process) is
#      taken over, under a short mutex (~/.agentic-classroom-setup.lock.takeover)
#      so only one shell can. A lock held by a live process is not given up on
#      at once: the shell looks again every 0.5 s for about 5 s. This is for the
#      first terminal, which VS Code may relaunch a second or two after creating
#      it (after "Trust Folder & Continue"): the relaunched shell arrives while
#      the old shell and its setup still hold the lock and are dying.
#      .vscode/settings.json also turns that relaunch off.
# Terminals 2 and later therefore get a plain prompt, about 5 s late while
# setup is still running in terminal 1 (at once after READY: guard 4).

[ -n "${BASH_VERSION:-}" ] || return 0 2>/dev/null

__ac_proc_start() {   # $1 = PID; its start time, so a reused PID is not mistaken
  ps -o lstart= -p "$1" 2>/dev/null | awk '{$1=$1; print}'
}

__ac_lock_stale() {   # $1 = lock dir; true if nobody live holds it
  local pid="" start="" now=""
  # 2>/dev/null BEFORE the <, or a missing pid file prints an error.
  { read -r pid; read -r start; } 2>/dev/null <"$1/pid"
  if [ -z "$pid" ]; then
    # Taken a moment ago and the PID not written yet, or abandoned long ago.
    [ -n "$(find "$1" -maxdepth 0 -mmin +1 2>/dev/null)" ]
    return
  fi
  kill -0 "$pid" 2>/dev/null || return 0
  # Alive. Stale only if that PID is now a different process (after a
  # Codespace restart PIDs start again from low numbers).
  now="$(__ac_proc_start "$pid")"
  [ -n "$start" ] && [ -n "$now" ] && [ "$start" != "$now" ] && return 0
  return 1
}

__ac_mutex_take() {   # $1 = mutex dir; true if this shell now holds it
  mkdir "$1" 2>/dev/null && return 0
  # It is held for milliseconds. One older than a minute was left by a shell
  # killed while holding it: move it aside (a rename, so only one shell wins),
  # then try once more.
  [ -n "$(find "$1" -maxdepth 0 -mmin +1 2>/dev/null)" ] || return 1
  mv "$1" "$1.old.$$" 2>/dev/null || return 1
  rm -rf "$1.old.$$"
  mkdir "$1" 2>/dev/null
}

__ac_lock_write() {   # $1 = lock dir; record this shell as the holder
  printf '%s\n%s\n' "$$" "$(__ac_proc_start $$)" >"$1/pid" 2>/dev/null
}

__ac_lock_take() {    # $1 = lock dir; true once this shell holds the lock
  local tries=0
  while :; do
    # setup.sh writes the marker BEFORE it releases the lock, so a shell that
    # waited through READY sees the marker and stays quiet.
    [ ! -e "$HOME/.agentic-classroom-ready" ] || return 1
    # Free: never taken, or released a moment ago by a setup that was dying.
    if mkdir "$1" 2>/dev/null; then
      if [ -e "$HOME/.agentic-classroom-ready" ]; then rm -rf "$1"; return 1; fi
      __ac_lock_write "$1"
      return 0
    fi
    # Stale: taking it over is check, remove, create, three steps. When a
    # Codespace reopens, VS Code revives several terminals at once, and without
    # the mutex two of them could both take the same stale lock and both start
    # setup. The mutex is never held across a sleep.
    if __ac_lock_stale "$1" && __ac_mutex_take "$1.takeover"; then
      if __ac_lock_stale "$1"; then
        rm -rf "$1"
        if mkdir "$1" 2>/dev/null; then
          # PID in before the mutex goes, so the next shell sees a live lock.
          __ac_lock_write "$1"
          rmdir "$1.takeover" 2>/dev/null
          return 0
        fi
      fi
      rmdir "$1.takeover" 2>/dev/null
    fi
    # Held by a live process: look again every 0.5 s for about 5 s.
    [ "$tries" -lt 10 ] || return 1
    tries=$((tries + 1))
    sleep 0.5
  done
}

__ac_autostart() {    # $1 = path of this file
  local root setup lock pid=""

  case "$-" in *i*) ;; *) return 0 ;; esac
  [ -t 0 ] && [ -t 1 ] || return 0
  [ -z "${VSCODE_RESOLVING_ENVIRONMENT:-}" ] || return 0
  case "${TERM_PROGRAM:-}" in vscode|codespaces) ;; *) return 0 ;; esac

  # Public site on port 8000, in every VS Code terminal of a Codespace and before
  # the ready/lock guards, so it also comes back after a Codespace restart.
  # site-public.sh is idempotent and prints nothing; it runs detached.
  if [ -n "${CODESPACE_NAME:-}" ] && [ -n "$1" ] && [ -f "$(dirname "$1")/site-public.sh" ]; then
    ( setsid nohup bash "$(dirname "$1")/site-public.sh" >/dev/null 2>&1 </dev/null & ) 2>/dev/null
  fi

  [ -z "${CLASSROOM_NO_AUTOSTART+x}" ] || return 0
  [ ! -e "$HOME/.agentic-classroom-ready" ] || return 0

  # setup.sh sits one folder above this file, whatever the repo folder is called.
  [ -n "$1" ] || return 0
  root="$(cd "$(dirname "$1")/.." 2>/dev/null && pwd)" || return 0
  setup="$root/setup.sh"
  [ -f "$setup" ] || return 0

  lock="$HOME/.agentic-classroom-setup.lock"
  __ac_lock_take "$lock" || return 0

  CLASSROOM_AUTOSTARTED=1 bash "$setup"

  # setup.sh releases the lock itself. If it was killed before it could, clear
  # a lock that still names this shell or a process that is gone.
  if [ -d "$lock" ] && __ac_mutex_take "$lock.takeover"; then
    { read -r pid; } 2>/dev/null <"$lock/pid"
    if [ "$pid" = "$$" ] || __ac_lock_stale "$lock"; then
      rm -rf "$lock"
    fi
    rmdir "$lock.takeover" 2>/dev/null
  fi
  return 0
}

__ac_autostart "${BASH_SOURCE[0]:-}"
unset -f __ac_autostart __ac_lock_stale __ac_proc_start __ac_mutex_take \
  __ac_lock_take __ac_lock_write
