#!/usr/bin/env bash
set -euo pipefail

# Build "name \t pretty" list
mapfile -t items < <(pactl -f json list sinks | jq -r '.[] | "\(.name)\t\(.properties["device.description"] // .description // .name)"')

# Menu shows only pretty label; we keep the machine name to set later
choice=$(printf '%s\n' "${items[@]}" | cut -f2 | rofi -dmenu -p "Output")
[ -z "${choice:-}" ] && exit 0

# Map back to sink name
sink=$(printf '%s\n' "${items[@]}" | awk -v c="$choice" -F'\t' '$2==c{print $1; exit}')
[ -z "${sink:-}" ] && exit 1

# Set default sink
pactl set-default-sink "$sink"

# Move all current streams to the new sink
pactl list short sink-inputs | awk '{print $1}' | xargs -r -n1 pactl move-sink-input "$sink"

