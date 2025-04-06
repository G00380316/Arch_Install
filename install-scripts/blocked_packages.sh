#!/bin/bash

# Function to remove blocking dependencies
remove_blocking_dependencies() {
    local package="$1"
    local blocking_deps=()

    # Find packages causing conflicts
    echo "Checking for conflicts with $package..."
    for dep in $(pactree -r "$package" | tail -n +2); do
        if pacman -Qi "$dep" &>/dev/null; then
            blocking_deps+=("$dep")
        fi
    done

    if [ ${#blocking_deps[@]} -gt 0 ]; then
        echo "Removing blocking dependencies: ${blocking_deps[*]}"
        sudo pacman -Rns --noconfirm "${blocking_deps[@]}"
    else
        echo "No blocking dependencies found."
    fi
}

# Function to reinstall removed dependencies
reinstall_dependencies() {
    local dependencies=("$@")

    if [ ${#dependencies[@]} -gt 0 ]; then
        echo "Reinstalling dependencies: ${dependencies[*]}"
        sudo pacman -S --noconfirm "${dependencies[@]}"
    else
        echo "No dependencies to reinstall."
    fi
}

# Install package with handling for conflicts
install_package_with_handling() {
    local package="$1"

    # Backup the list of conflicting dependencies
    local removed_deps=()
    remove_blocking_dependencies "$package"
    removed_deps+=($(pactree -r "$package" | tail -n +2))

    # Attempt to install the package
    echo "Installing $package..."
    sudo pacman -S --noconfirm "$package"
    if [ $? -eq 0 ]; then
        echo "$package installed successfully."
    else
        echo "Failed to install $package. Exiting."
        exit 1
    fi

    # Reinstall previously removed dependencies
    reinstall_dependencies "${removed_deps[@]}"
}

# Usage: pass the desired package as the first argument
if [ -z "$1" ]; then
    echo "Usage: $0 <package>"
    exit 1
fi

install_package_with_handling "$1"
