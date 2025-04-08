#!/bin/bash

## WARNING: DO NOT EDIT BELOW UNLESS YOU KNOW WHAT YOU'RE DOING ##
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Source global functions
if ! source "$(dirname "$(readlink -f "$0")")/Global_functions.sh"; then
    echo "Failed to source Global_functions.sh"
    exit 1
fi

LOG="Install-Logs/install-$(date +%d-%H%M%S)_printer.log"

# Redirecting all output and errors to log file
exec > >(tee -a "$LOG") 2>&1

# Log the start of the script
echo "=== Script started at $(date) ==="

# Function to detect package manager (apt for Debian/Ubuntu, pacman for Arch)
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

# Detect the package manager
detect_package_manager

echo "Would you like to install printing services? (y/n)"
read response

if [[ "$response" =~ ^[Yy]$ ]]; then
    echo "Installing printing services..."
    if [ "$PACKAGE_MANAGER" = "pacman" ]; then
        # Arch-based systems
        sudo pacman -S --noconfirm reflector
        sudo reflector --latest 20 --protocol https --sort rate --save /etc/pacman.d/mirrorlist
        sudo pacman -Syy
        sudo pacman -S --noconfirm splix cups cups-filters
        sudo systemctl enable --now cups.service
        #Add the printer:

        #    Open a browser and go to http://localhost:631 to access the CUPS web interface.
        #    Go to the Administration tab, then click Add Printer.
        #    Follow the prompts to select your Samsung printer model, which should now be listed thanks to the splix driver.

        #Test the printer: After adding it, print a test page to confirm it’s set up correctly.
    elif [ "$PACKAGE_MANAGER" = "apt" ]; then
        # Debian-based systems
        sudo apt install -y cups system-config-printer simple-scan
        sudo systemctl enable cups.service
    fi
    echo "Printing services installed."
elif [[ "$response" =~ ^[Nn]$ ]]; then
    echo "Printing services will not be installed."
else
    echo "Invalid input. Please enter 'y' or 'n'."
fi
