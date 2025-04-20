#!/bin/bash

monitor=$(hyprctl monitors | awk '/^Monitor/{name=$2} /focused: yes/{print name}')
cache_file="$HOME/.cache/swww/$monitor"
rofi_link="$HOME/.config/rofi/.current_wallpaper"
mod_dir="$HOME/.config/hypr/wallpaper_effects"

echo "[wallust-watcher] Watching: $cache_file"

while true; do
    inotifywait -e close_write "$cache_file" >/dev/null 2>&1

    new_wallpaper=$(grep -v 'Lanczos3' "$cache_file" | head -n 1)

    if [[ -f "$new_wallpaper" ]]; then
        echo "[wallust-watcher] Detected new wallpaper: $new_wallpaper"

        ln -sf "$new_wallpaper" "$rofi_link"
        cp -r "$new_wallpaper" "$mod_dir/.wallpaper_modified"
        cp -r "$new_wallpaper" "$mod_dir/.wallpaper_current"

        wallust run "$new_wallpaper" -s &
    fi
done

