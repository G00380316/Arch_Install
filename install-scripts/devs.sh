#!/bin/bash

    ## WARNING: DO NOT EDIT BELOW UNLESS YOU KNOW WHAT YOU'RE DOING ##
    SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

    # Source global functions
    if ! source "$(dirname "$(readlink -f "$0")")/Global_functions.sh"; then
        echo "Failed to source Global_functions.sh"
        exit 1
    fi

    LOG="Install-Logs/install-$(date +%d-%H%M%S)_dev.log"

    # Redirecting all output and errors to log file
    exec > >(tee -a "$LOG") 2>&1

    # Log the start of the script
    echo "=== Script started at $(date) ==="

    # Clone Neovim Configuration Repository
    echo "Cloning Neovim configuration..."
    git clone https://github.com/G00380316/nvim.git
    mv ./nvim ~/.config

    echo "Cloning tpm for tmux configuration..."
    git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

    cd ~/
    dircolors -p > ~/.dircolors
    mkdir -p ~/Coding/Projects

    mkdir -p ~/.cache/hyde/wallpapers

    echo "Installing JetBrains Nerd Font..."
    # Step 1: Download the Nerd Font
    echo "Downloading JetBrains Nerd Font..."
    FONT_ZIP="JetBrainsMono.zip"
    FONT_URL="https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip"
    curl -LO "$FONT_URL"

    # Step 2: Extract the Font
    echo "Extracting the font..."
    unzip "$FONT_ZIP" -d JetBrainsMono
    rm -rf "$FONT_ZIP"

    # Step 3: Install the Font
    echo "Installing the font..."
    cd ~/.local/share
    mkdir -p fonts
    mv JetBrainsMono ~/.local/share/fonts/
    fc-cache -fv

    # Browsing and Other Applications
    # Install PHP and Lua
    # Cmake
    # CSharp
    # Development Tools
    echo "Installing basic development tools..."
    echo "Installing PHP and Lua..."
    echo "Installing Neovim"
    sudo pacman -S --noconfirm php lua neovim easyeffects lsp-plugins ladspa calf zoxide tmux
    sudo pacman -S --noconfirm cmake github-cli lazygit gcc jdk-openjdk ruby
    sudo pacman -S --noconfirm dotnet-runtime aspnet-runtime dotnet-sdk
    echo 'export PATH="$HOME/.dotnet/tools:$PATH"' >> ~/.zshrc
    
    # Install Python using pyenv
    echo "Installing pyenv and Python..."
    curl https://pyenv.run | zsh
    echo -e '\n# Pyenv configuration' >> ~/.zshrc
    echo 'export PATH="$HOME/.pyenv/bin:$PATH"' >> ~/.zshrc
    echo 'eval "$(pyenv init --path)"' >> ~/.zshrc
    echo 'eval "$(pyenv init -)"' >> ~/.zshrc
    source ~/.zshrc
    pyenv install 3.11.4
    pyenv global 3.11.4
    pip install -U hyfetch

    # Install Node.js using nvm
    echo "Installing nvm and Node.js..."
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | zsh
    source ~/.nvm/nvm.sh
    nvm install node
    nvm use node

    # Install Go
    echo "Installing Go..."
    wget https://golang.org/dl/go1.20.5.linux-amd64.tar.gz
    sudo tar -C /usr/local -xzf go1.20.5.linux-amd64.tar.gz
    echo 'export PATH=$PATH:/usr/local/go/bin' >> ~/.zshrc
    source ~/.zshrc

    # Install Rust
    echo "Installing Rust..."
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    source ~/.cargo/env
    source ~/.zshrc
    rustup update

    # To be completely honest most things surrounding the installation of android
    # tools for flutter can be done through android Studio just navigate to the
    # settings and seach for 'Android SDK'

    # Android Development
    # Flutter Install
    git clone https://github.com/flutter/flutter.git -b stable
    sudo mv flutter /opt/flutter
    yay -S --noconfirm android-studio android-sdk android-ndk
    flutter doctor

    # Clean up
    echo "Cleaning up..."
    sudo pacman -Sc --noconfirm

    echo "All done! Now run util.sh and displaylinkinstall.sh and look at info.txt"
