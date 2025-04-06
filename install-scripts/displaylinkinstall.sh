#!/bin/bash

# Update the system
echo "Updating system..."
sudo pacman -Syu linux-headers --noconfirm

# Source the global functions script
if ! source "$(dirname "$(readlink -f "$0")")/Global_functions.sh"; then
    echo "Failed to source Global_functions.sh"
    exit 1
fi

# Set the name of the log file to include the current date and time
LOG="Install-Logs/install-$(date +%d-%H%M%S)_displaylink.log"

# Install the Evdi driver
echo "Installing Evdi driver..."
install_package evdi

# Install the DisplayLink driver
echo "Installing DisplayLink driver..."
install_package displaylink

# Enable the DisplayLink service
echo "Enabling DisplayLink service..."
sudo systemctl enable displaylink.service
sudo systemctl start displaylink.service

# Load the DisplayLink kernel module
echo "Loading the DisplayLink kernel module..."
sudo modprobe evdi

# Clean up
echo "Cleaning up..."

echo "Installation complete! Please reboot your system.(sudo reboot)"
