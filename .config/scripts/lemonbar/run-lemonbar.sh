#!/bin/bash
set -Eeuo pipefail

bar_geom="x22"                 # height 22px; width = screen
bar_font="monospace-10"        # pick something you have: run 'fc-list'
FG="#ffffff" 
BG="#222222"
ul="#ffff00"
BLUE="#0000ff"
YELLOW="#ffff00"
GREEN="#00ff00"

# --- Lemonbar wrappers ---
F() { printf '%%{F%s}' "$1"; }   # set foreground
B() { printf '%%{B%s}' "$1"; }   # set background
FR() { printf '%%{F-}'; }        # reset foreground
BR() { printf '%%{B-}'; }        # reset background

Clock() { echo -n " "; date "+%a %d %b | %H:%M "; }

WindowList() {
  # windows on the focused desktop
  local focused wid app
  focused="$(bspc query -N -n focused 2>/dev/null || true)"
  for wid in $(bspc query -N -d focused -n .window 2>/dev/null); do
    # take the last quoted token from WM_CLASS (more robust across apps)
    app="$(xprop -id "$wid" WM_CLASS 2>/dev/null | awk -F\" '/WM_CLASS/ {print $(NF-1)}')"
    if [[ "$wid" == "$focused" ]]; then
      printf '%%{u%s}%%{+u}%s%%{-u}  ' "$ul" "${app:-?}"
    else
      printf '%s  ' "${app:-?}"
    fi
  done
}

Battery0() { acpi -b 2>/dev/null | awk -F': |, ' '/Battery 0/ {print "B0: " $3 "%"}'; }
Battery1() { acpi -b 2>/dev/null | awk -F': |, ' '/Battery 1/ {print "B1: " $3 "%"}'; }
#BatteryTime() { acpi -b 2>/dev/null | awk -F': |, ' '/Battery 0/ {print $4}'; }


#BatteryTime() {
#    acpi -b | awk -F': |, ' '/Battery 0/ {print substr($4,1,5)}'
#}
#BatteryTime() {
  #acpi -b 2>/dev/null |
  #awk -F': |, ' '
    #/Battery [0-9]+/ {
      ## $2 = status, $3 = percent, $4 = time (hh:mm:ss ...), sometimes absent
      #if ($4 ~ /^[0-9]{1,2}:[0-9]{2}:/) {
        #split($4,t,":")
        #sym = ($2 ~ /Discharging/) ? "↓" : ($2 ~ /Charging/ ? "↑" : "")
        #printf "%s%02d:%02d\n", sym, t[1], t[2]
        #exit
      #}
    #}
  #'
#}

#BatteryTime() {
#  local dev
#  dev=$(upower -e | grep DisplayDevice) || return
#  upower -i "$dev" 2>/dev/null |
#  awk -F': *' '
#    /state:/ {s=$2}
#    /time to empty:/ {e=$2}
#    /time to full:/ {f=$2}
#    END {
#      if (s ~ /discharging/ && e) {
#        sub(/ hours?/, "h", e); sub(/ minutes?/, "m", e); print "↓" e
#      } else if (s ~ /charging/ && f) {
#        sub(/ hours?/, "h", f); sub(/ minutes?/, "m", f); print "↑" f
#      }
#    }'
#}
#
#BatteryPct() {
#  acpi -b 2>/dev/null |
#  awk -F': |, ' '/Battery [0-9]+/ {printf "B" $1+0 ": " $3 "  "}'
#}


# --- Combined time from DisplayDevice via upower (HH:MM, no words) ---
_BattCombinedTime() {
  local dev state val mins hours
  dev=$(upower -e 2>/dev/null | grep DisplayDevice) || return

  while IFS= read -r line; do
    case "$line" in
      *"state:"*) state=$(awk -F': *' '{print $2}' <<<"$line") ;;
      *"time to empty:"*)
        [ "$state" = "discharging" ] || continue
        val=$(awk -F': *' '{print $2}' <<<"$line")
        ;;
      *"time to full:"*)
        [ "$state" = "charging" ] || continue
        val=$(awk -F': *' '{print $2}' <<<"$line")
        ;;
    esac
  done < <(upower -i "$dev" 2>/dev/null)

  case "$val" in
    *hour*) mins=$(awk '{printf "%d", ($1*60)+0.5}' <<<"$val") ;;
    *minute*) mins=$(awk '{print int($1)}' <<<"$val") ;;
    *) return 0 ;;
  esac

  hours=$(( mins / 60 ))
  mins=$(( mins % 60 ))

  if [ "$state" = "discharging" ]; then
    # yellow text
    printf "%%{F#ffff00}%02d:%02d%%{F-}" "$hours" "$mins"
  elif [ "$state" = "charging" ]; then
    # green text
    printf "%%{F#00ff00}%02d:%02d%%{F-}" "$hours" "$mins"
  fi
}

# --- Identify the ACTIVE battery pack and its percent ---
# Prefers Discharging, else Charging; falls back to the first battery line.
_ActiveBatteryPct() {
  acpi -b 2>/dev/null | awk -F': |, ' '
    /Battery [0-9]+/ {
      n = $1 + 0; st = $2; pct = $3
      if (st ~ /Discharging/) { printf "B%d %s\n", n, pct; exit }
      if (st ~ /Charging/   ) { c_n=n; c_pct=pct }
      if (!seen++) { f_n=n; f_pct=pct }
    }
    END {
      if (c_pct != "")      printf "B%d %s\n", c_n, c_pct;
      else if (f_pct != "") printf "B%d %s\n", f_n, f_pct;
    }
  '
}


#produce_line() {
#  printf '%%{l}%s  %%{r}%s | %s  %%{F%s}%s%%{F-}  %%{c}%%{F%s}%%{B#0000FF}%s%%{F-}%%{B-}\n' \
#    "$(WindowList)" \
#    "$(Battery0)" "$(Battery1)" "$ul" "$(BatteryTime)" "$fg" "$(Clock)"
#}


#produce_line() {
#  printf '%%{l}%s  %%{c}%s  %%{r}%s %s\n' \
#    "$(WindowList)" \
#    "$(Clock)" \
#    "$(BatteryPct)" \
#    "$(BatteryTime)"
#}

produce_line() {
  printf '%%{l}%s  %%{c}%s%s%s  %%{r}%s %s\n' \
    "$(WindowList)" \
    "$(B "$BLUE")$(F "$FG")" "$(Clock)" "$(BR)$(FR)" \
    "$(_ActiveBatteryPct)" \
    "$(_BattCombinedTime)"
}


main() {
  while :; do
    produce_line
    sleep 1
  done
}

# Run and feed lemonbar
main | lemonbar -p -g "$bar_geom" -f "$bar_font" -F "$FG" -B "$BG" -u 2 &
wait

