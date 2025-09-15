#!/usr/bin/env bash
set -euo pipefail

# Get current default sink name (works on PulseAudio & PipeWire)
def_sink="$(pactl get-default-sink 2>/dev/null || pactl info | awk -F': ' '/Default Sink/{print $2}')"
[ -z "${def_sink:-}" ] && { echo "🔊 ?"; exit 0; }

# Find a pretty label for that sink
label="$(pactl -f json list sinks | jq -r --arg tgt "$def_sink" '
  .[] | select(.name==$tgt)
  | (.properties["device.description"] // .description // .name)
')"

# Fallback if not found
[ -z "${label:-}" ] && label="$def_sink"

# Aggressive truncation for bar
max=6
if [ "${#label}" -gt "$max" ]; then
  label="${label:0:$max}…"
fi

printf '🔊 %s\n' "$label"


