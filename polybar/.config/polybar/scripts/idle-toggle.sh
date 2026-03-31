#!/usr/bin/env sh

set -eu

uid="$(id -u)"
pid_file="/tmp/polybar-idle-inhibit-${uid}.pid"

is_running() {
  [ -f "$pid_file" ] || return 1

  pid="$(cat "$pid_file" 2>/dev/null || true)"
  [ -n "$pid" ] || return 1
  kill -0 "$pid" 2>/dev/null
}

start_inhibit() {
  if is_running; then
    return 0
  fi

  (
    exec systemd-inhibit \
      --what=idle:sleep \
      --who="polybar" \
      --why="Idle lock from polybar" \
      sh -c 'while :; do sleep 3600; done'
  ) >/dev/null 2>&1 &

  echo "$!" > "$pid_file"
}

stop_inhibit() {
  if ! is_running; then
    rm -f "$pid_file"
    return 0
  fi

  pid="$(cat "$pid_file")"
  kill "$pid" 2>/dev/null || true
  rm -f "$pid_file"
}

print_status() {
  if is_running; then
    printf '󰅶\n'
  else
    printf '󰒲\n'
  fi
}

case "${1:---status}" in
  --toggle)
    if is_running; then
      stop_inhibit
    else
      start_inhibit
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
