#!/usr/bin/env sh

set -eu

uid="$(id -u)"
bat="${BATTERY_DEVICE:-BAT0}"
limited_start="${BATTERY_LIMITED_START_THRESHOLD:-75}"
limited_stop="${BATTERY_LIMITED_STOP_THRESHOLD:-80}"
full_start="${BATTERY_FULL_START_THRESHOLD:-96}"
full_stop="${BATTERY_FULL_STOP_THRESHOLD:-100}"
state_file="/tmp/polybar-battery-threshold-${uid}.state"

read_stop_threshold() {
  for path in \
    "/sys/class/power_supply/${bat}/charge_control_end_threshold" \
    "/sys/devices/platform/smapi/${bat}/stop_charge_thresh" \
    "/sys/class/power_supply/${bat}/charge_stop_threshold"
  do
    if [ -r "$path" ]; then
      cat "$path"
      return 0
    fi
  done

  return 1
}

current_mode() {
  stop_value="$(read_stop_threshold 2>/dev/null || true)"

  if [ -n "$stop_value" ]; then
    if [ "$stop_value" -ge 95 ]; then
      printf 'full\n'
    else
      printf 'limited\n'
    fi
    return 0
  fi

  if [ -r "$state_file" ]; then
    cat "$state_file"
    return 0
  fi

  printf 'limited\n'
}

notify() {
  if command -v notify-send >/dev/null 2>&1; then
    notify-send "Battery threshold" "$1"
  fi
}

run_privileged() {
  sudo -n "$@"
}

apply_mode() {
  mode="$1"

  if [ "$mode" = "full" ]; then
    if run_privileged tlp setcharge "$full_start" "$full_stop" "$bat"; then
      printf 'full\n' > "$state_file"
      notify "Charging limit set to 100%."
      return 0
    fi

    notify "Failed to set charging limit to 100%."
    exit 1
  fi

  if run_privileged tlp setcharge "$limited_start" "$limited_stop" "$bat"; then
    printf 'limited\n' > "$state_file"
    notify "Charging limit set to ${limited_stop}%."
    return 0
  fi

  notify "Failed to set charging limit to ${limited_stop}%."
  exit 1
}

toggle_mode() {
  mode="$(current_mode)"

  if [ "$mode" = "full" ]; then
    apply_mode limited
  else
    apply_mode full
  fi
}

case "${1:---toggle}" in
  --toggle)
    toggle_mode
    ;;
  *)
    printf 'Usage: %s --toggle\n' "$0" >&2
    exit 1
    ;;
esac
