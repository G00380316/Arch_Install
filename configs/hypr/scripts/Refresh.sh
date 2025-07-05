#!/bin/bash

# Scripts for refreshing ags, waybar, rofi

SCRIPTSDIR=$HOME/.config/hypr/scripts
UserScripts=$HOME/.config/hypr/UserScripts
hydeScripts=$HOME/.config/scripts/Hyde_Inject/Scripts/

# Define file_exists function
file_exists() {
    if [ -e "$1" ]; then
        return 0  # File exists
    else
        return 1  # File does not exist
    fi
}

# Kill already running processes
_ps=(waybar rofi ags)
for _prs in "${_ps[@]}"; do
    if pidof "${_prs}" >/dev/null; then
        pkill "${_prs}"
    fi
done

killall -SIGUSR2 waybar

# quit ags & relaunch ags
ags -q && ags &

# some process to kill
for pid in $(pidof waybar rofi); do
    kill -SIGUSR1 "$pid"
done

#Restart waybar
# sleep 1
# waybar &

# Relaunching rainbow borders if the script exists
sleep 1
if file_exists "${UserScripts}/RainbowBorders.sh"; then
    ${UserScripts}/RainbowBorders.sh &
fi

exit 0