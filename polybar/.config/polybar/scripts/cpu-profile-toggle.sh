#!/usr/bin/env sh

set -eu

state_file="/tmp/polybar-cpu-profile.state"

notify() {
  if command -v notify-send >/dev/null 2>&1; then
    notify-send "CPU profile" "$1"
  fi
}

current_profile() {
  if profile="$(powerprofilesctl get 2>/dev/null)"; then
    printf '%s\n' "$profile"
    return 0
  fi

  if [ -r "$state_file" ]; then
    cat "$state_file"
    return 0
  fi

  printf 'balanced\n'
}

next_profile() {
  case "$1" in
    power-saver)
      printf 'balanced\n'
      ;;
    balanced)
      printf 'performance\n'
      ;;
    performance)
      printf 'power-saver\n'
      ;;
    *)
      printf 'balanced\n'
      ;;
  esac
}

set_profile() {
  target="$1"

  if powerprofilesctl set "$target" 2>/dev/null; then
    printf '%s\n' "$target" > "$state_file"
    notify "Switched to ${target}."
    return 0
  fi

  notify "Failed to switch to ${target}."
  exit 1
}

toggle_profile() {
  current="$(current_profile)"
  set_profile "$(next_profile "$current")"
}

case "${1:---toggle}" in
  --toggle)
    toggle_profile
    ;;
  *)
    printf 'Usage: %s --toggle\n' "$0" >&2
    exit 1
    ;;
esac
