#!/bin/bash

# Interval between checks (in seconds)
INTERVAL=0.5

# Command to start Waybar
START_CMD="waybar"

while true; do
    if ! pgrep -x "waybar" > /dev/null; then
        echo "$(date): Waybar not running. Restarting..."
        pkill -x waybar  # Kill any existing waybar processes (just in case)
        ags -q && ags &
        sleep 1
        $START_CMD &
    else
        # Make sure only one waybar process is running
        WAYBAR_COUNT=$(pgrep -xc waybar)
        if [ "$WAYBAR_COUNT" -gt 1 ]; then
            echo "$(date): Multiple Waybar instances detected. Restarting clean..."
            pkill -x waybar
            ags -q && ags &
            sleep 1
            $START_CMD &
        fi
    fi
    sleep $INTERVAL
done
