#!/bin/bash

# pacman -Qe
# grep "installed" /var/log/pacman.log | tail -n 20
# Function to check if a service is active and enabled
service_active_and_enabled() {
    local service="$1"
    # Check if service is active and enabled
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

echo "Would you like to run automated Clean-up? (y/n)"
read response

if [[ "$response" =~ ^[Yy]$ ]]; then
    echo "Automating some tasks for you..."
    # Update user directories
    xdg-user-dirs-update

    echo "Removing some directories..."
    sudo rm -rf ~/go
    sudo rm -rf ~/JetBrainsMono
    sudo rm -rf ~/install.sh
    sudo rm -rf ~/clone.sh
    sudo rm -rf ~/Clone
    echo "Dirs removed!"

    echo "Making Some useful directories..."
    cd ~/
    dircolors -p > ~/.dircolors
    mkdir -p ~/Coding/Projects
    echo "Dirs made!"

    echo "Removing unwanted extra packages..."
    sudo pacman -Rns $(pacman -Qdtq)
    yay -Rns $(yay -Qdtq)
    echo "Removed unwanted extra packages!"

    echo "Building Neovim Plugins..."
    cd ~/.local/share/nvim/lazy/command-t/lua/wincent/commandt/lib
    make clean
    make
    echo "Built Neovim Plugins!"

    echo "Building Waybar Plugins..."
    cd ~/.config/waybar/waybar-module-pomodoro/
    cargo build
    echo "Built Waybar Plugins!"

    echo "Checking if SDDM is installed..."

    echo "Building Weather Module Plugins..."

    # Attempt to run Weather.py
    if  python3 ~/.config/hypr/UserScripts/Weather.py; then
        echo "Built Weather Module!"
    else
        echo "Error occurred. Trying to install pyquery..."
        pip install pyquery

        # Try running Weather.py again
        if python3 ~/.config/hypr/UserScripts/Weather.py; then
            echo "Built Weather Module!"
        else
            echo "Failed to build Weather Module. Please check your script."
        fi
    fi

    echo "Adding a some themes..."
    # Add GTK theme and icon theme
    bash ~/Arch_Install/colorschemes/purple.sh

    echo "Checking if SDDM is installed..."
    if check_sddm; then
        echo "SDDM is already installed and enabled (recommended)."
        ask_enable_sddm
    else
        echo "SDDM is not installed or enabled."
        detect_package_manager
        ask_install_sddm
        bash ./sddm.sh
        bash ./sddm_theme.sh
    fi

    echo "Configuring FireFoxPWA"
    cp -r ./Extra/firefoxpwa/ ~/.local/share/
    echo "Configuring for FireFoxPWA is complete (Please enable plugins in the Apps {Youtube , Youtube Music and Timetree})"
    echo "For the best experience Shortkeys to open them should be working straight away!!"

    echo "Setting up SDDM Theme - Candy_Modified"
    sudo cp -r ./Extra/Candy_Modified /usr/share/sddm/themes/
    echo "Theme in the right dir now"

    # need to use "ln -s" here 
    cp -r ~/Arch_Install/configs/scripts/Hyde_Inject/share/kio ~/.local/share/
    cp -r ~/Arch_Install/configs/scripts/Hyde_Inject/share/kxmlgui5 ~/.local/share/
    cp -r ~/Arch_Install/configs/scripts/Hyde_Inject/share/icons ~/.local/share/
    cp -r ~/Arch_Install/configs/scripts/Hyde_Inject/share/dolphin ~/.local/share/
    cp -r ~/Arch_Install/configs/scripts/Hyde_Inject/share/fastfetch ~/.local/share/
    cp -r ~/Arch_Install/configs/scripts/Hyde_Inject/state/dolphinstaterc ~/.local/state/

    # Enable necessary services
    sudo pacman -Rns --noconfirm pulseaudio pulseaudio-alsa
    systemctl --user daemon-reload
    systemctl --user restart xdg-desktop-portal-wlr.service
    sudo systemctl enable avahi-daemon
    sudo systemctl enable acpid
    sudo systemctl --user enable --now pipewire pipewire-pulse
    xdg-mime default thunar.desktop inode/directory application/x-gnome-saved-search
    sudo systemctl enable --now tlp

    # Update user directories
    xdg-user-dirs-update

    # Clean up
    echo "Cleaning up..."
    sudo pacman -Sc --noconfirm

    echo "Automation done!!! Everything should be installed and tidy!"
else
    echo "Exiting without cleanup."
fi

exit 0
