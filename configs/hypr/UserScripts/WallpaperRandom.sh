#!/bin/bash

# Script for Random Wallpaper (CTRL ALT W)

wallDIR="$HOME/Pictures/wallpapers"
SCRIPTSDIR="$HOME/.config/hypr/scripts"
last_wallpaper_file="/tmp/last_wallpaper"

PICS=($(find -L "${wallDIR}" -type f \( -name "*.jpg" -o -name "*.jpeg" -o -name "*.png" -o -name "*.pnm" -o -name "*.tga" -o -name "*.tiff" -o -name "*.webp" -o -name "*.bmp" -o -name "*.farbfeld" -o -name "*.gif" \)))

# Get the last wallpaper used
last_wallpaper=""
if [[ -f "$last_wallpaper_file" ]]; then
    last_wallpaper=$(cat "$last_wallpaper_file")
fi

# Pick a new wallpaper that is different from the last one
RANDOMPICS="${PICS[RANDOM % ${#PICS[@]}]}"
while [[ "$RANDOMPICS" == "$last_wallpaper" && ${#PICS[@]} -gt 1 ]]; do
    RANDOMPICS="${PICS[RANDOM % ${#PICS[@]}]}"
done

# Save the new wallpaper as the last used one
echo "$RANDOMPICS" > "$last_wallpaper_file"

# Transition config
FPS=60
TYPE="random"
DURATION=1
BEZIER=".43,1.19,1,.4"
SWWW_PARAMS="--transition-fps $FPS --transition-type $TYPE --transition-duration $DURATION --transition-bezier $BEZIER"

# Start swww if not running
swww query || swww-daemon --format xrgb

swww img "$(readlink -f "$RANDOMPICS")" $SWWW_PARAMS

wait $!
"$SCRIPTSDIR/WallustSwww.sh" &&

wait $!
sleep 2
"$SCRIPTSDIR/Refresh.sh"
