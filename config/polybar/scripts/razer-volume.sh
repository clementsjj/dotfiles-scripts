#!/usr/bin/env bash
CARD=$(awk -v IGNORECASE=1 '/Razer Leviathan V2 X/{print $1; exit}' /proc/asound/cards)
[ -z "$CARD" ] && { echo "Razer card not found"; exit 1; }
# echo "Card: $CARD"

CTL="PCM,1"                     # <- control name you said works

STEP="${2:-5%}"
# echo "Step: $STEP"


case "$1" in
  up)   amixer -c "$CARD" sset "$CTL" "$STEP"+ unmute ;;
  down) amixer -c "$CARD" sset "$CTL" "$STEP"- ;;
  mute) amixer -c "$CARD" sset "$CTL" toggle ;;
  show) amixer -c "$CARD" -M sget 'PCM',1 | awk -F'[][]' '/Playback.*%/ {print $2, $4; exit}' ;;
  gui)  alsamixer -c "$CARD" -V playback ;;
  *)    echo "Usage: $0 {up|down|mute|show|gui} [STEP]"; exit 2 ;;
esac



