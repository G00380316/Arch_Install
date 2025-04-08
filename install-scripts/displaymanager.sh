#!/bin/bash

## WARNING: DO NOT EDIT BELOW UNLESS YOU KNOW WHAT YOU'RE DOING ##
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Source global functions
if ! source "$(dirname "$(readlink -f "$0")")/Global_functions.sh"; then
    echo "Failed to source Global_functions.sh"
    exit 1
fi

LOG="Install-Logs/install-$(date +%d-%H%M%S)_displaymanager.log"

# Redirecting all output and errors to log file
exec > >(tee -a "$LOG") 2>&1

# Log the start of the script
echo "=== Script started at $(date) ==="
# Function to check if a service is active and enabled
service_active_and_enabled() {
    local service="$1"
    # Check if service is active and enabled
    sudo systemctl is-active --quiet "$service" && sudo systemctl is-enabled --quiet "$service"
}

# Function to check if systemctl is available
check_systemctl() {
    if ! command -v systemctl &> /dev/null; then
        echo "systemctl not found. This script requires systemd to function properly."
        exit 1
    fi
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

# Check if systemctl is available
check_systemctl

# Detect the package manager
detect_package_manager

# Check if GDM3 is installed and enabled
check_gdm() {
    service_active_and_enabled gdm
}

# Check if SDDM is installed and enabled
check_sddm() {
    service_active_and_enabled sddm
}

# Check if LightDM is installed and enabled
check_lightdm() {
    service_active_and_enabled lightdm
}

# Check if LXDM is installed and enabled
check_lxdm() {
    service_active_and_enabled lxdm
}

# Check if Ly is installed and enabled
check_ly() {
    service_active_and_enabled ly
}

# Check if SLiM is installed and enabled
check_slim() {
    service_active_and_enabled slim
}

# Function to ask if user wants to install SDDM if another DM is installed
ask_install_sddm() {
    read -p "SDDM is recommended. Install? (y/n): " answer
    case $answer in
        [yY])
            sudo pacman -R --noconfirm ly
            sudo pacman -R --noconfirm slim
            sudo pacman -R --noconfirm lxdm
            sudo pacman -R --noconfirm lightdm
            sudo pacman -R --noconfirm gdm

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

# Function to install and enable GDM3
install_gdm() {
    echo "Installing minimal GDM3 (recommended)..."
    sudo pacman -Rdd --noconfirm poppler-qt6
    sudo $PACKAGE_COMMAND gdm
    sudo systemctl enable gdm
    sudo pacman -S --noconfirm poppler-qt6
    echo "GDM3 has been installed and enabled."
}

# Function to install and enable LightDM
install_lightdm() {
    echo "Installing LightDM..."
    sudo $PACKAGE_COMMAND lightdm
    sudo systemctl enable lightdm
    echo "LightDM has been installed and enabled."
}

# Function to install and enable LXDM
install_lxdm() {
    echo "Installing LXDM..."
    sudo $PACKAGE_COMMAND lxdm
    sudo systemctl enable lxdm
    echo "LXDM has been installed and enabled."
}

# Function to install and enable SLiM
install_slim() {
    echo "Installing SLiM..."
    sudo $PACKAGE_COMMAND slim
    sudo systemctl enable slim
    echo "SLiM has been installed and enabled."
}

# Check which display managers are installed and enabled
if check_gdm; then
    echo "GDM3 is already installed and enabled."
    exit 0
elif check_sddm; then
    echo "SDDM is already installed and enabled (recommended)."
    ask_install_sddm
    exit 0
elif check_lightdm; then
    echo "LightDM is already installed and enabled."
    ask_install_sddm
    exit 0
elif check_lxdm; then
    echo "LXDM is already installed and enabled."
    ask_install_sddm
    exit 0
elif check_ly; then
    echo "Ly is already installed and enabled."
    ask_install_sddm
    exit 0
elif check_slim; then
    echo "SLiM is already installed and enabled."
    ask_install_sddm
    exit 0
fi

# If none of the above are installed, offer a choice to the user
echo "No supported display manager found."

# Menu for user choice
echo "Choose an option (or '0' to skip):"
echo "1. Install minimal SDDM (recommended)"
echo "2. Install minimal GDM"
echo "3. Install LightDM"
echo "4. Install LXDM"
echo "5. Install SLiM"

read -p "Enter your choice (0/1/2/3/4/5): " choice

case $choice in
    0)
        echo "Skipping installation."
        exit 0
        ;;
    1)
        install_sddm
        ;;
    2)
        install_gdm
        ;;
    3)
        install_lightdm
        ;;
    4)
        install_lxdm
        ;;
    5)
        install_slim
        ;;
    *)
        echo "Invalid choice. Exiting."
        exit 1
        ;;
esac

# Final message to reboot or restart
echo "Installation complete. Please reboot your system or restart your display manager for changes to take effect."
