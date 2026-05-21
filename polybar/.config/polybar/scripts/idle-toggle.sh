#!/usr/bin/env sh

set -eu

PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:${PATH:-}"
export PATH

uid="$(id -u)"
runtime_dir="${XDG_RUNTIME_DIR:-/tmp}"
[ -d "$runtime_dir" ] && [ -w "$runtime_dir" ] || runtime_dir="/tmp"
pid_file="${runtime_dir}/polybar-idle-inhibit-${uid}.pid"

is_xss_lock_running() {
  pgrep -u "$uid" -x xss-lock >/dev/null 2>&1
}

is_inhibit_running() {
  [ -f "$pid_file" ] || return 1

  pid="$(cat "$pid_file" 2>/dev/null || true)"
  [ -n "$pid" ] || return 1

  if kill -0 "$pid" 2>/dev/null; then
    return 0
  fi

  rm -f "$pid_file"
  return 1
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
    if ! command -v systemd-inhibit >/dev/null 2>&1; then
      printf 'idle-toggle: systemd-inhibit not found\n' >&2
      return 1
    fi

    (
      exec systemd-inhibit \
        --what=idle:sleep \
        --mode=block \
        --who="polybar" \
        --why="Coffee mode from polybar" \
        sh -c 'while :; do sleep 3600; done'
    ) >/dev/null 2>&1 &

    echo "$!" > "$pid_file"
    sleep 0.1

    if ! is_inhibit_running; then
      printf 'idle-toggle: failed to start systemd-inhibit\n' >&2
      return 1
    fi
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
