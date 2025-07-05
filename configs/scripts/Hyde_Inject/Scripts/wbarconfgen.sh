#!/usr/bin/env bash

scrDir="$(dirname "$(realpath "$0")")"
# shellcheck disable=SC1091
source "${scrDir}/globalcontrol.sh"
config_dir="$HOME/.config/waybar"
configs_dir="$config_dir/configs"
link_target="$config_dir/config"

# Get the list of config files in the order they appear in the directory
mapfile -t configs < <(find "$configs_dir" -maxdepth 1 -type f -printf "%f\n")
num_configs=${#configs[@]}

if (( num_configs == 0 )); then
    echo "No configs found in $configs_dir"
    exit 1
fi

# Determine the current config name from the symlink
current_config=$(readlink "$link_target")
current_name=$(basename "$current_config")

# Find the current index in the list
current_index=-1
for i in "${!configs[@]}"; do
    if [[ "${configs[$i]}" == "$current_name" ]]; then
        current_index=$i
        break
    fi
done

if (( current_index == -1 )); then
    echo "Current config is not in the list, defaulting to first"
    current_index=0
fi

# Determine next or previous config
case "$1" in
    n) next_index=$(( (current_index + 1) % num_configs )) ;;
    p) next_index=$(( (current_index - 1 + num_configs) % num_configs )) ;;
    *)
        echo "Usage: $0 [n|p]"
        exit 1
        ;;
esac

next_config="${configs[$next_index]}"

# Update symlink
ln -sf "$configs_dir/$next_config" "$link_target"

"$scrDir/wbarstylegen.sh"

# Restart Waybar
killall waybar
waybar & disown

echo "Switched to config: $next_config"