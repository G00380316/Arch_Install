#!/bin/bash

# Main Hyprland Package #

hypr=(
  hyprland
  hypridle
  hyprlock
  libspng
)

## WARNING: DO NOT EDIT BEYOND THIS LINE IF YOU DON'T KNOW WHAT YOU ARE DOING! ##
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Change the working directory to the parent directory of the script
PARENT_DIR="$SCRIPT_DIR/.."
cd "$PARENT_DIR" || { echo "${ERROR} Failed to change directory to $PARENT_DIR"; exit 1; }

# Source the global functions script
if ! source "$(dirname "$(readlink -f "$0")")/Global_functions.sh"; then
  echo "Failed to source Global_functions.sh"
  exit 1
fi


# Set the name of the log file to include the current date and time
LOG="Install-Logs/install-$(date +%d-%H%M%S)_hyprland.log"

# Removing other Hyprland to avoid conflict
printf "${YELLOW} Checking for other hyprland packages and remove if any..${RESET}\n"
if pacman -Qs hyprland >/dev/null; then
  printf "${YELLOW} Hyprland detected. attempting to uninstall to install Hyprland from official repo...${RESET}\n"
  for hyprnvi in hyprland-git hyprland-nvidia hyprland-nvidia-git hyprland-nvidia-hidpi-git; do
    sudo pacman -R --noconfirm "$hyprnvi" 2>/dev/null | tee -a "$LOG" || true
  done
fi

# Hyprland
printf "${NOTE} Installing ${SKY_BLUE}Hyprland packages${RESET} .......\n"
for HYPR in "${hypr[@]}"; do
  install_package "$HYPR" "$LOG"
done

printf "\n%.0s" {1..2}