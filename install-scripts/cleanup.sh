#!/bin/bash
set -e  # Exit script on error

# Function to check if a service is active and enabled
service_active_and_enabled() {
    local service="$1"
    sudo systemctl is-active --quiet "$service" && sudo systemctl is-enabled --quiet "$service"
}

# Function to detect the package manager
detect_package_manager() {
    if command -v pacman &> /dev/null; then
        PACKAGE_MANAGER="pacman"
        PACKAGE_COMMAND="sudo pacman -S --noconfirm"
    elif command -v apt &> /dev/null; then
        PACKAGE_MANAGER="apt"
        PACKAGE_COMMAND="sudo apt install -y"
    else
        echo "No supported package manager found. Please install either pacman or apt."
        exit 1
    fi
}

## WARNING: DO NOT EDIT BELOW UNLESS YOU KNOW WHAT YOU'RE DOING ##
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Source global functions
if ! source "$(dirname "$(readlink -f "$0")")/Global_functions.sh"; then
    echo "Failed to source Global_functions.sh"
    exit 1
fi

LOG="Install-Logs/install-$(date +%d-%H%M%S)_cleanup.log"

echo "Automating some tasks for you..."

### Build Waybar Plugin ###
echo "Building Waybar Plugins..."
cd ~/.config/waybar/waybar-module-pomodoro/
cargo build
echo "Waybar Plugins built!"

### Build Weather Module ###
echo "Building Weather Module Plugins..."
if python3 ~/Arch_Install/config/hypr/UserScripts/Weather.py; then
    echo "Weather Module built successfully!"
else
    echo "Error occurred. Installing pyquery..."
    pip install pyquery

    if python3 ~/.config/hypr/UserScripts/Weather.py; then
        echo "Weather Module built successfully after installing pyquery!"
    else
        echo "Failed to build Weather Module. Please check the script."
    fi
fi

### Add Themes ###
echo "Adding Extra Hyprlock Theme..."
sudo cp -r ~/Arch_Install/install-scripts/Extra/Candy_Modified /usr/share/sddm/themes

echo "Applying GTK and icon themes..."
bash ~/Arch_Install/colorschemes/purple.sh
bash ~/Arch_Install/colorschemes/blue.sh

echo "Configuring FireFoxPWA"
cp -r ~/Arch_Install/install-scripts/Extra/firefoxpwa ~/.local/share/
echo "Configuring for FireFoxPWA is complete (Please enable plugins in the Apps {Youtube , Youtube Music and Timetree})"
echo "For the best experience Shortkeys to open them should be working straight away!!"


### Clean Up Unwanted Files ###
echo "Removing temporary files and folders..."
rm -rf ~/go ~/JetBrainsMono ~/install.sh ~/clone.sh ~/Clone
echo "Cleanup complete."

### Create Useful Directories ###
echo "Creating Coding/Projects directory..."
mkdir -p ~/Coding/Projects
dircolors -p > ~/.dircolors
echo "Directory structure set up!"

### Remove Orphaned Packages ###
echo "Removing orphaned packages..."
if pacman -Qdtq &> /dev/null; then
    sudo pacman -Rns $(pacman -Qdtq)
fi
if command -v yay &> /dev/null && yay -Qdtq &> /dev/null; then
    yay -Rns $(yay -Qdtq)
fi
echo "Unwanted packages removed!"

### Easy Effect Presets ###
echo "Importing Easyeffect presets..."
bash -c "$(curl -fsSL https://raw.githubusercontent.com/JackHack96/PulseEffects-Presets/master/install.sh)"

### Build Neovim Plugins ###
echo "Building Neovim plugins..."
cd ~/.local/share/nvim/lazy/command-t/lua/wincent/commandt/lib
make clean && make
echo "Neovim plugins built!"

### Service Configuration ###
echo "Configuring services..."

systemctl --user daemon-reload
systemctl --user restart xdg-desktop-portal-wlr.service
sudo systemctl enable avahi-daemon
sudo systemctl enable acpid
sudo systemctl --user enable --now pipewire pipewire-pulse
sudo systemctl enable --now tlp

xdg-mime default thunar.desktop inode/directory application/x-gnome-saved-search
xdg-user-dirs-update

# Caching fonts once again
fc-cache -fv

### Final Cleanup ###
echo "Running final cleanup..."
sudo pacman -Sc --noconfirm

echo "🎉 Automation complete! Your system should now be fully configured and tidy!"
