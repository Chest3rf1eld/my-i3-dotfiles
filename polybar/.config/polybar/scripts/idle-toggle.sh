#!/usr/bin/env sh

set -eu

uid="$(id -u)"
pid_file="/tmp/polybar-idle-inhibit-${uid}.pid"

is_xss_lock_running() {
  pgrep -u "$uid" -x xss-lock >/dev/null 2>&1
}

is_inhibit_running() {
  [ -f "$pid_file" ] || return 1

  pid="$(cat "$pid_file" 2>/dev/null || true)"
  [ -n "$pid" ] || return 1
  kill -0 "$pid" 2>/dev/null
}

set_display_awake() {
  command -v xset >/dev/null 2>&1 || return 0
  [ -n "${DISPLAY:-}" ] || return 0

  xset s off -dpms s noblank >/dev/null 2>&1 || true
}

restore_display_idle() {
  command -v xset >/dev/null 2>&1 || return 0
  [ -n "${DISPLAY:-}" ] || return 0

  xset s on +dpms s blank >/dev/null 2>&1 || true
}

coffee_mode_on() {
  if ! is_inhibit_running; then
    (
      exec systemd-inhibit \
        --what=idle:sleep \
        --mode=block \
        --who="polybar" \
        --why="Coffee mode from polybar" \
        sh -c 'while :; do sleep 3600; done'
    ) >/dev/null 2>&1 &

    echo "$!" > "$pid_file"
  fi

  if is_xss_lock_running; then
    pkill -u "$uid" -STOP -x xss-lock >/dev/null 2>&1 || true
  fi

  set_display_awake
}

coffee_mode_off() {
  if is_inhibit_running; then
    pid="$(cat "$pid_file" 2>/dev/null || true)"
    if [ -n "$pid" ]; then
      kill "$pid" >/dev/null 2>&1 || true
    fi
  fi

  rm -f "$pid_file"

  if is_xss_lock_running; then
    pkill -u "$uid" -CONT -x xss-lock >/dev/null 2>&1 || true
  fi

  restore_display_idle
}

print_status() {
  if is_inhibit_running; then
    printf '%%{T2}󰅶%%{T-}\n'
  else
    printf '%%{T2}󰒲%%{T-}\n'
  fi
}

case "${1:---status}" in
  --toggle)
    if is_inhibit_running; then
      coffee_mode_off
    else
      coffee_mode_on
    fi
    ;;
  --status)
    print_status
    ;;
  *)
    printf 'Usage: %s [--status|--toggle]\n' "$0" >&2
    exit 1
    ;;
esac
