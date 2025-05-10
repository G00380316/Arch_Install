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

sudo cp ~/Arch_Install/install-scripts/assets/Hyprlock-main/ttyclock.ttf /usr/share/fonts/
sudo cp ~/Arch_Install/install-scripts/assets/Hyprlock-main/Anurati-Regular.otf /usr/share/fonts/

# Caching fonts once again
fc-cache -fv

echo "Configuring FireFoxPWA"
cp -r ~/Arch_Install/install-scripts/Extra/firefoxpwa ~/.local/share/
echo "Configuring for FireFoxPWA is complete (Please enable plugins in the Apps {Youtube , Youtube Music and Timetree})"
echo "For the best experience Shortkeys to open them should be working straight away!!"

### Add Themes ###
echo "Adding Extra Hyprlock Theme..."
sudo cp -r ~/Arch_Install/install-scripts/Extra/Candy_Modified /usr/share/sddm/themes

cd ~/.cache/hyde/themepatcher/
git clone https://github.com/Maroc02/Moonlight.git
theme.patch.sh "Moonlight" ./Moonlight

cd ~/.cache/hyde/themepatcher/
git clone https://github.com/cyb3rgh0u1/Another-World.git
theme.patch.sh "Another World" ./Another-World

echo '1' | theme.patch.sh "Abyssal-Wave" "https://github.com/Itz-Abhishek-Tiwari/Abyssal-Wave"

cd ~/Arch_Install/install-scripts/Extra/Themes
theme.patch.sh "Hack the Box" ./HackTheBox
# theme.patch.sh "Mac Os" ./MacOs
theme.patch.sh "Windows 11" ./Windows11
cp -r ~/Pictures/wallpapers ./G00380316/Configs/.config/hyde/themes/G00380316
theme.patch.sh "G00380316" ./G00380316

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
    python -m venv path/to/venv
    source path/to/venv/bin/activate
    sudo pacman --noconfirm --needed -S python-pyquery
    sudo pacman --noconfirm --needed -S python-requests

    if python3 ~/.config/hypr/UserScripts/Weather.py; then
        echo "Weather Module built successfully after installing pyquery!"
    else
        echo "Failed to build Weather Module. Please check the script."
    fi
fi

# Activate daemon for Wallust
systemctl --user daemon-reexec
systemctl --user daemon-reload
systemctl --user enable --now wallust-manager.service
systemctl --user enable --now easyeffects-manager.service

# Ask the user if they want to install the Additional packages
echo "Do you want to install an Additonal set of packages? (y/n)(Recommended if it is first install)"
read -r answer

if [[ "$answer" == "y" || "$answer" == "Y" ]]; then
    echo "Installing the additonal packages..."
    # ── Text editors & coding tools
    yay -S --noconfirm --needed geany geany-plugins code zed

    # ── Browsers & email
    yay -S --noconfirm --needed microsoft-edge-stable-bin google-chrome betterbird-bin

    # ── Productivity & knowledge
    yay -S --noconfirm --needed onlyoffice anki-bin obsidian flatseal blanket vesktop

    # ── Cloud & sync
    yay -S --noconfirm --needed onedrive-abraunegg

    # ── File & media tools
    yay -S --noconfirm --needed filebot moneymanagerex obs-studio

    # ── Terminal & fun
    yay -S --noconfirm --needed fzf bat tofi boxes foot bluetui pokemon-colorscripts-git

    # ── Audio & music
    yay -S --noconfirm --needed spotube

    # ── Themes & fonts
    yay -S --noconfirm --needed arc-gtx-theme papirus-icon-theme

    # ── System utilities
    yay -S --noconfirm --needed swww bleachbit sof-bin zathura spicetify-cli 

    yay -S --noconfirm --needed iwmenu bzmenu
 
    # ── Fonts & themes
    sudo pacman -S --noconfirm --needed terminus-font ttf-font-awesome ttf-dejavu ttf-freefont papirus-icon-theme gnome-settings-daemon

    # ── System & shell utilities
    sudo pacman -S --noconfirm --needed acpi acpid avahi base-devel curl dialog dosfstools exa file-roller gettext mtools pv unzip usbutils xdotool util-linux

    # ── Terminal & clipboard tools
    sudo pacman -S --noconfirm --needed grim kitty libnotify redshift slurp

    # ── File management
    sudo pacman -S --noconfirm --needed thunar thunar-archive-plugin thunar-media-tags-plugin thunar-volman gnome-disk-utility

    # ── Power & networking
    sudo pacman -S --noconfirm --needed xfce4-power-manager networkmanager network-manager-applet

    # ── File systems & drives
    sudo pacman -S --noconfirm --needed parted gptfdisk exfatprogs ntfs-3g e2fsprogs usbmuxd ifuse libimobiledevice

    # ── Media & extras
    sudo pacman -S --noconfirm --needed vlc kodi unrar qbittorrent feh

    # ── Dev tools
    sudo pacman -S --noconfirm --needed rsync lazygit firefoxpwa

    # ── Desktop environment tools
    sudo pacman -S --noconfirm --needed dolphin nwg-look btop gparted flatpak

    # ── Pipewire (audio stack)
    sudo pacman -S --noconfirm --needed pipewire pipewire-pulse pipewire-jack pavucontrol

    # ── Qt libraries
    sudo pacman -S --noconfirm --needed qt5-declarative qt5-quickcontrols qt5-quickcontrols2 qt5-graphicaleffects

    # ── Browsers again (from pacman)
    sudo pacman -S --noconfirm --needed firefox inotify-tools

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

echo "Do you want to run Dev.sh and Wallust.sh to make sure key dependencies are installed? (y/n)"
read -r answer1

if [[ "$answer1" == "y" || "$answer1" == "Y" ]]; then
    echo "running Dev.sh and Wallust.sh..."
    bash ./devs.sh
    bash ./wallust.sh

    sudo pacman -S --noconfirm --needed tmux
    sudo pacman -S --noconfirm --needed zoxide
    sudo pacman -S --noconfirm --needed neovim

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
