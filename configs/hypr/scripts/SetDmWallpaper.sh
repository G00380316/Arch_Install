#!/bin/bash

terminal=kitty
iDIR="$HOME/.config/swaync/images"
wallpaper_current="$HOME/.config/hypr/wallpaper_effects/.wallpaper_current"

# Check if user selected a wallpaper
  sddm_sequoia="/usr/share/sddm/themes/sequoia_2"
  if [ -d "$sddm_sequoia" ]; then
    if yad --info --text="Set current wallpaper as SDDM background?\n\nNOTE: This only applies to SEQUOIA SDDM Theme" \
    --text-align=left \
    --title="SDDM Background" \
    --timeout=10 \
    --timeout-indicator=right \
    --button="yad-yes:0" \
    --button="yad-no:1" \
    ; then

    # Check if terminal exists
    if ! command -v "$terminal" &>/dev/null; then
    notify-send -i "$iDIR/ja.png" "Missing $terminal" "Install $terminal to enable setting of wallpaper background"
    exit 1
    fi

    echo "Setting SDDM theme to $selected_theme..."
    echo "[Theme]" | sudo tee "$SDDM_CONF" > /dev/null
    echo "Current=$selected_theme" | sudo tee -a "$SDDM_CONF" > /dev/null
    $terminal -e bash -c "sudo systemctl restart sddm"
    # Open terminal to enter password
    $terminal -e bash -c "echo 'Enter your password to set wallpaper as SDDM Background'; \
    sudo cp -r $wallpaper_current '$sddm_sequoia/backgrounds/default' && \
    notify-send -i '$iDIR/ja.png' 'SDDM' 'Background SET'"
    fi
  fi
