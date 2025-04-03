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


# Check if SDDM is installed and enabled
check_sddm() {
    service_active_and_enabled sddm
}

# Function to ask if user wants to enable SDDM if another DM is installed
ask_enable_sddm() {
    read -p "SDDM is recommended. Do you want to enable it? (y/n): " answer
    case $answer in
        [yY])
            sudo systemctl disable ly
            sudo systemctl disable slim
            sudo systemctl disable lxdm
            sudo systemctl disable lightdm
            sudo systemctl disable gdm

            enable_sddm
            ;;
        *)
            echo "Okay, exiting."
            exit 0
            ;;
    esac
}

# Function to ask if user wants to install and enable SDDM if another DM is installed
ask_install_sddm() {
    read -p "SDDM is recommended. Do you want to install and then enable it? (y/n): " answer
    case $answer in
        [yY])
            sudo systemctl disable ly
            sudo systemctl disable slim
            sudo systemctl disable lxdm
            sudo systemctl disable lightdm
            sudo systemctl disable gdm

            install_sddm
            ;;
        *)
            echo "Okay, exiting."
            exit 0
            ;;
    esac
}

# Function to install and enable SDDM
install_sddm() {
    echo "Installing minimal SDDM (recommended)..."
    sudo $PACKAGE_COMMAND sddm
    sudo systemctl enable sddm
    echo "SDDM has been installed and enabled."
}

enable_sddm() {
    sudo systemctl enable sddm
    echo "SDDM has been enabled."
}

echo "Would you like to run automated Clean-up? (y/n)"
read response

if [[ "$response" =~ ^[Yy]$ ]]; then
    echo "Automating some tasks for you..."

    echo "Removing some directories..."
    sudo rm -rf ~/go
    sudo rm -rf ~/JetBrainsMono
    sudo rm -rf ~/install.sh
    sudo rm -rf ~/clone.sh
    echo "Dirs removed!"

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

    # echo "Making some dirs..."
    # mkdir -p ~/Pictures/ScreenShots/
    # echo "Made new dirs!"

    echo "Configuring FireFoxPWA"
    cp -r ~/Arch_Install/Extra/firefoxpwa/ ~/.local/share/
    echo "Configuring for FireFoxPWA is complete (Please enable plugins in the Apps {Youtube , Youtube Music and Timetree})"
    echo "For the best experience Shortkeys to open them should be working straight away!!"

    cp -r ~/Arch_Install/configs/scripts/Hyde_Inject/share/kio ~/.local/share/
    cp -r ~/Arch_Install/configs/scripts/Hyde_Inject/share/kxmlgui5 ~/.local/share/
    cp -r ~/Arch_Install/configs/scripts/Hyde_Inject/share/icons ~/.local/share/
    cp -r ~/Arch_Install/configs/scripts/Hyde_Inject/share/dolphin ~/.local/share/
    cp -r ~/Arch_Install/configs/scripts/Hyde_Inject/share/fastfetch ~/.local/share/
    cp -r ~/Arch_Install/configs/scripts/Hyde_Inject/state/dolphinstaterc ~/.local/state/

    echo "Automation done!!! Everything should be installed and tidy!"
else
    echo "Exiting without cleanup."
fi

exit 0
