#!/bin/bash

# Interval between checks (in seconds)
INTERVAL=0.5

# Command to start EasyEffects
START_CMD="easyeffects --gapplication-service"

while true; do
    if ! pgrep -x "easyeffects" > /dev/null; then
        echo "$(date): EasyEffects not running. Restarting..."
        $START_CMD &
    fi
    sleep $INTERVAL
done
