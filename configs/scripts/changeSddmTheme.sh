#!/bin/bash

SDDM_CONFDIR="/etc/"
SDDM_CONF="/etc/sddm.conf"

# Get the list of available themes
themes=$(find /usr/share/sddm/themes/ -mindepth 1 -maxdepth 1 -type d -exec basename {} \;)

# Show the list in rofi (running as your user)
selected_theme=$(echo "$themes" | rofi -dmenu -p "Select SDDM Theme")

# If a theme was selected, apply it
if [[ -n "$selected_theme" ]]; then
    echo "Setting SDDM theme to $selected_theme..."
    echo "[Theme]" | sudo tee "$SDDM_CONF" > /dev/null
    echo "Current=$selected_theme" | sudo tee -a "$SDDM_CONF" > /dev/null
    sudo systemctl restart sddm
else
    echo "No theme selected."
fi
