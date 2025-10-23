#!/usr/bin/env bash
set -e
killall -q polybar || true
while pgrep -x polybar >/dev/null; do sleep 0.1; done

# One bar per active output
# polybar -m | cut -d: -f1 | while read -r m; do
#   MONITOR="$m" polybar -r bar1 &
# done

MONITOR=DisplayPort-0 polybar -r longbar &   # big monitor (acer)
MONITOR=DisplayPort-1 polybar -r bar2 &   # top monitor (hp)
MONITOR=DisplayPort-2 polybar -r bar1 &   # left monitor (viewsonic)

# Get monitors with polybar -m