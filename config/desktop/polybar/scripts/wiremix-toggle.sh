#!/usr/bin/env bash
set -euo pipefail

TITLE="Wiremix"                           # shown via -T
TERM="${TERMINAL:-xfce4-terminal}"
CACHE="${XDG_CACHE_HOME:-$HOME/.cache}/wiremix.winid"
mkdir -p "$(dirname "$CACHE")"

find_win() {
  xdotool search --name "^${TITLE}$" 2>/dev/null | head -n1
}

# If cached WINID is valid, toggle (focus if hidden, else close)
if [[ -f "$CACHE" ]]; then
  WINID=$(<"$CACHE")
  if xdotool getwindowname "$WINID" >/dev/null 2>&1; then
    if xprop -id "$WINID" _NET_WM_STATE 2>/dev/null | grep -q _NET_WM_STATE_HIDDEN; then
      xdotool windowmap "$WINID" 2>/dev/null || true
      xdotool windowactivate "$WINID"
    else
      xdotool windowclose "$WINID" || xdotool windowkill "$WINID"
      rm -f "$CACHE"
    fi
    exit 0
  else
    rm -f "$CACHE"
  fi
fi

# Launch and record its window id
setsid -f "$TERM" -T "$TITLE" -e wiremix >/dev/null 2>&1 &
for _ in {1..20}; do
  sleep 0.1
  NEW=$(find_win) && [[ -n "$NEW" ]] && { echo "$NEW" >"$CACHE"; xdotool windowactivate "$NEW"; exit 0; }
done
exit 0
