#!/usr/bin/env sh

set -eu

print_wpctl() {
  output="$(wpctl get-volume @DEFAULT_AUDIO_SINK@ 2>/dev/null || true)"
  [ -n "$output" ] || return 1

  case "$output" in
    *"[MUTED]"*)
      printf '%%{T2}%%{T-}\n'
      return 0
      ;;
  esac

  volume="$(printf '%s\n' "$output" | awk '{print $2}')"
  [ -n "$volume" ] || return 1

  percent="$(awk -v v="$volume" 'BEGIN { printf "%d", v * 100 + 0.5 }')"
  printf '%%{F#c7772e}%%{T2}%%{T-}%%{F-} %%{F#f7f3ea}%s%%%%{F-}\n' "$percent"
}

print_pactl() {
  mute="$(pactl get-sink-mute @DEFAULT_SINK@ 2>/dev/null || true)"
  volume="$(pactl get-sink-volume @DEFAULT_SINK@ 2>/dev/null || true)"
  [ -n "$mute" ] || return 1
  [ -n "$volume" ] || return 1

  case "$mute" in
    *"yes"*)
      printf '%%{T2}%%{T-}\n'
      return 0
      ;;
  esac

  percent="$(printf '%s\n' "$volume" | awk 'match($0, /[0-9]+%/) { print substr($0, RSTART, RLENGTH - 1); exit }')"
  [ -n "$percent" ] || return 1

  printf '%%{F#c7772e}%%{T2}%%{T-}%%{F-} %%{F#f7f3ea}%s%%%%{F-}\n' "$percent"
}

print_status() {
  if command -v wpctl >/dev/null 2>&1 && print_wpctl; then
    return 0
  fi

  if command -v pactl >/dev/null 2>&1 && print_pactl; then
    return 0
  fi

  printf '%%{T2}%%{T-} --\n'
}

print_status

if command -v pactl >/dev/null 2>&1; then
  pactl subscribe 2>/dev/null | while IFS= read -r event; do
    case "$event" in
      *"on sink "*|*"on server "*)
        print_status
        ;;
    esac
  done
fi
