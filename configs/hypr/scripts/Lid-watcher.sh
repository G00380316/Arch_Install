#!/bin/bash

SCRIPTSDIR="$HOME/.config/hypr/scripts"
LID_PATH="/proc/acpi/button/lid/LID0/state"
MONITOR_NAME="eDP-1"

# Get current lid state
if [[ -f "$LID_PATH" ]]; then
    LID_STATE=$(awk '{print $2}' "$LID_PATH")
else
    echo "Lid state file not found"
    exit 1
fi

# Get number of connected monitors (excluding disabled)
MONITOR_COUNT=$(hyprctl monitors | grep 'Monitor' | wc -l)

# If only one monitor (e.g., eDP-1 only), skip
if (( MONITOR_COUNT < 2 )); then
    echo "Only one monitor connected — skipping"
    exit 0
fi

# Check if eDP-1 is currently active (present in monitor list)
MONITOR_ACTIVE=$(hyprctl monitors | grep -q "$MONITOR_NAME" && echo "yes" || echo "no")

# Lid is closed and screen is still active —> disable it
if [[ "$LID_STATE" == "closed" && "$MONITOR_ACTIVE" == "yes" ]]; then
    hyprctl keyword monitor "$MONITOR_NAME, disable"
    pkill -x waybar

# Lid is open and screen is not active —> enable it
elif [[ "$LID_STATE" == "open" && "$MONITOR_ACTIVE" == "no" ]]; then
    hyprctl keyword monitor "$MONITOR_NAME, 2880x1800@60.0,0x1000,2"
    pkill -x waybar
fi
