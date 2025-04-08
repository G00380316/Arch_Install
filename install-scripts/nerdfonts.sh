#!/bin/bash

## WARNING: DO NOT EDIT BELOW UNLESS YOU KNOW WHAT YOU'RE DOING ##
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Source global functions
if ! source "$(dirname "$(readlink -f "$0")")/Global_functions.sh"; then
    echo "Failed to source Global_functions.sh"
    exit 1
fi

LOG="Install-Logs/install-$(date +%d-%H%M%S)_nerdfonts.log"

# Redirecting all output and errors to log file
exec > >(tee -a "$LOG") 2>&1

# Log the start of the script
echo "=== Script started at $(date) ==="

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

echo "Just making sure all the fonts have been install..."

# Check if unzip is installed; if not, install it
if ! command_exists unzip; then
    echo "Installing unzip..."
    sudo pacman -S --noconfirm unzip
fi

# Create directory for fonts if it doesn't exist
mkdir -p ~/.local/share/fonts

# Array of font names
fonts=(
    "CascadiaCode"
    "FiraCode"
    "Hack"
    "Inconsolata"
    "JetBrainsMono"
    "Meslo"
    "Mononoki"
    "RobotoMono"
    "SourceCodePro"
    "UbuntuMono"
    # Add additional fonts here if needed
)

# Function to check if font directory exists
check_font_installed() {
    font_name=$1
    if [ -d ~/.local/share/fonts/$font_name ]; then
        echo "Font $font_name is already installed. Skipping."
        return 0  # Font already installed
    else
        return 1  # Font not installed
    fi
}

# Loop through each font, check if installed, and install if not
for font in "${fonts[@]}"
do
    if check_font_installed "$font"; then
        echo "Skipping installation of font: $font"
        continue  # Skip installation if font is already installed
    fi
    
    echo "Installing font: $font"
    wget -q --show-progress "https://github.com/ryanoasis/nerd-fonts/releases/download/v3.1.1/$font.zip" -P /tmp
    if [ $? -ne 0 ]; then
        echo "Failed to download font: $font"
        continue
    fi
    
    unzip -q /tmp/$font.zip -d ~/.local/share/fonts/$font/
    if [ $? -ne 0 ]; then
        echo "Failed to extract font: $font"
        continue
    fi
    
    rm /tmp/$font.zip
done

# Update font cache
fc-cache -f

echo "Fonts installation completed."
