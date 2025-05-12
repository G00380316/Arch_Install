#!/bin/bash

    ## WARNING: DO NOT EDIT BELOW UNLESS YOU KNOW WHAT YOU'RE DOING ##
    SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

    # Source global functions
    if ! source "$(dirname "$(readlink -f "$0")")/Global_functions.sh"; then
        echo "Failed to source Global_functions.sh"
        exit 1
    fi

    LOG="Install-Logs/install-$(date +%d-%H%M%S)_wallust.log"

    # Redirecting all output and errors to log file
    exec > >(tee -a "$LOG") 2>&1

    # Log the start of the script
    echo "=== Script started at $(date) ==="

    # Check if Rust is installed
    if ! command -v rustc &>/dev/null; then
        echo "Rust is not installed. Installing Rust..."

        # Install Rust using rustup (Rust installer and version manager)
        if ! command -v curl &>/dev/null; then
            echo "curl is not installed. Please install curl first."
            exit 1
        fi

        # Install Rust via rustup (the recommended way)
        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

        # Add Rust to the PATH (needed for the current session)
        source "$HOME/.cargo/env"

        echo "Rust has been installed."
    else
        echo "Rust is already installed."
    fi

    # Proceed with the build process
    cd "${SCRIPT_DIR}/assets/wallust"
    cargo build --release
    sudo cp target/release/wallust /usr/local/bin/
