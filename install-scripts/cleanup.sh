#!/bin/bash

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

# Redirecting all output and errors to log file
exec > >(tee -a "$LOG") 2>&1

# Log the start of the script
echo "=== Script started at $(date) ==="

# Fixes Chaotic-Aur
sudo pacman -Fy
echo "Automating some tasks for you..."

### Clean Up Unwanted Files ###
echo "Removing temporary files and folders..."
rm -rf ~/go ~/JetBrainsMono ~/install.sh ~/clone.sh ~/Clone
echo "Cleanup complete."

### Remove Orphaned Packages ###
echo "Removing orphaned packages..."
if pacman -Qdtq &> /dev/null; then
    sudo pacman -Rns $(pacman -Qdtq)
fi
if command -v yay &> /dev/null && yay -Qdtq &> /dev/null; then
    yay -Rns $(yay -Qdtq)
fi
echo "Unwanted packages removed!"

### Service Configuration ###
echo "Configuring services..."

xdg-mime default thunar.desktop inode/directory application/x-gnome-saved-search

# Caching fonts once again
fc-cache -fv

echo "Configuring FireFoxPWA"
cp -r ~/Arch_Install/install-scripts/Extra/firefoxpwa ~/.local/share/
echo "Configuring for FireFoxPWA is complete (Please enable plugins in the Apps {Youtube , Youtube Music and Timetree})"
echo "For the best experience Shortkeys to open them should be working straight away!!"

### Add Themes ###
echo "Adding Extra Hyprlock Theme..."
sudo cp -r ~/Arch_Install/install-scripts/Extra/Candy_Modified /usr/share/sddm/themes

### Build Waybar Plugin ###
echo "Building Waybar Plugins..."
cd ~/.config/waybar/waybar-module-pomodoro/
cargo build
echo "Waybar Plugins built!"

### Build Neovim Plugins ###
echo "Building Neovim plugins..."
cd ~/.local/share/nvim/lazy/command-t/lua/wincent/commandt/lib
make clean && make
echo "Neovim plugins built!"

echo "Applying GTK and icon themes..."
bash ~/Arch_Install/colorschemes/purple.sh
bash ~/Arch_Install/colorschemes/blue.sh

### Build Weather Module ###
echo "Building Weather Module Plugins..."
if python3 ~/Arch_Install/config/hypr/UserScripts/Weather.py; then
    echo "Weather Module built successfully!"
else
    echo "Error occurred. Installing pyquery..."
    pip install pyquery
    pip install requests

    if python3 ~/.config/hypr/UserScripts/Weather.py; then
        echo "Weather Module built successfully after installing pyquery!"
    else
        echo "Failed to build Weather Module. Please check the script."
    fi
fi

# Ask the user if they want to install the Additional packages
echo "Do you want to install an Additonal set of packages? (y/n)"
read -r answer

if [[ "$answer" == "y" || "$answer" == "Y" ]]; then
    echo "Installing the additonal packages..."
    yay -S --noconfirm geany geany-plugins betterbird-bin onedrive-abraunegg fzf bat tofi arc-gtx-theme papirus-icon-theme microsoft-edge-stable-bin google-chrome anki-bin swww qimgv visual-studio-code-bin moneymanagerex filebot obsidian pokemon-colorscripts-git bluetui code flatseal blanket obs-studio bleachbit onlyoffice vesktop firefox \
    boxes foot spotube zathura zed
    sudo pacman -S --noconfirm acpi acpid avahi base-devel curl dialog dosfstools exa file-roller ttf-font-awesome terminus-font ttf-dejavu ttf-freefont gettext grim kitty libnotify mtools networkmanager papirus-icon-theme pavucontrol redshift slurp tilix thunar thunar-archive-plugin thunar-media-tags-plugin thunar-volman unzip xdotool \
    xfce4-power-manager pipewire pipewire-pulse pipewire-jack rsync parted gptfdisk exfatprogs ntfs-3g util-linux e2fsprogs usbutils pv network-manager-applet lazygit firefoxpwa unrar usbmuxd ifuse libimobiledevice vlc kodi flatpak dolphin btop qbittorrent feh gparted nwg-look gnome-disk-utility
    
    flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    flatpak install flathub dev.bragefuglseth.Keypunch -y
    flatpak install flathub net.lugsole.bible_gui -y
    flatpak install flathub com.usebruno.Bruno -y
    # flatpak install flathub org.gnome.Boxes -y
    flatpak install flathub info.febvre.Komikku -y
    flatpak install flathub io.github.mezoahmedii.Picker -y
    flatpak install flathub dev.edfloreshz.Tasks -y
    flatpak install flathub org.dbgate.DbGate  -y
else
    echo "No additional packages will be installed."
fi

### Easy Effect Presets ###                                   
echo "Importing Easyeffect presets..."                        
echo "1" | bash -c "$(curl -fsSL https://raw.githubusercontent.com/JackHack96/PulseEffects-Presets/master/install.sh)"

### Final Cleanup ###
echo "Running final cleanup..."
sudo pacman -Sc --noconfirm

echo "🎉 Automation complete! Your system should now be fully configured and tidy!"
