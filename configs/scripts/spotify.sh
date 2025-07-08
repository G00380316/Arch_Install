#!/bin/bash

# Command to start Waybar
START_CMD="env LD_PRELOAD=/usr/lib/spotify-adblock.so spotify --uri=%U"

if ! pgrep -x "spotify" > /dev/null; then
    echo "$(date): Spotify not running. Restarting..."
    pkill -x spotify  # Kill any existing spotify processes (just in case)
    sleep 1
    $START_CMD &
else
    # Make sure only one waybar process is running
    SPOTIFY_COUNT=$(pgrep -xc spotify)
    if [ "$SPOTIFY_COUNT" -gt 1 ]; then
        echo "$(date): Multiple Spotify instances detected. Restarting clean..."
        pkill -x spotify
        sleep 1
        $START_CMD &
    fi
fi
