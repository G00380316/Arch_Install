#!/bin/zsh


# Main list of packages
packages=()

# AUR packages
yay_packages=(
    "Komikku"
    "obsidian"
    "pokemon-colorscripts-git"
)

flatpak_packages=(
    "dbgate"
    "dev.bragefuglseth.Keypunch"
    "net.lugsole.bible_gui"
    "com.usebruno.Bruno"
    "org.onlyoffice.desktopeditors"
    "org.gnome.Boxes"
    "io.github.mezoahmedii.Picker"
    "dev.edfloreshz.Tasks"
)


# Function to read common packages from a file
read_packages_from_file() {
    local file="$1"
    local -n array_ref="$2"
    if [ -f "$file" ]; then
        while read -r pkg; do
            [ -n "$pkg" ] && array_ref+=("$pkg")
        done < "$file"
    else
        echo "File not found: $file"
        exit 1
    fi
}

# Read package lists
read_packages_from_file "$HOME/Arch_Install/install-scripts/common_packages.txt" packages
read_packages_from_file "$HOME/Arch_Install/install-scripts/yay_common_packages.txt" yay_packages

# Function to install pacman packages if they are not already installed
install_packages() {
    local pkgs=("$@")
    local missing_pkgs=()

    for pkg in "${pkgs[@]}"; do
        if ! pacman -Q "$pkg" &>/dev/null; then
            missing_pkgs+=("$pkg")
        fi
    done

    if [ ${#missing_pkgs[@]} -gt 0 ]; then
        echo "Installing missing pacman packages: ${missing_pkgs[@]}"
        sudo pacman -S --noconfirm "${missing_pkgs[@]}" || {
            echo "Failed to install some packages. Continuing."
        }
    else
        echo "All pacman packages are already installed."
    fi
}

# Function to install yay packages if they are not already installed
install_yay_packages() {
    local pkgs=("$@")
    local missing_pkgs=()

    for pkg in "${pkgs[@]}"; do
        if ! yay -Q "$pkg" &>/dev/null; then
            missing_pkgs+=("$pkg")
        fi
    done

    if [ ${#missing_pkgs[@]} -gt 0 ]; then
        echo "Installing missing yay packages: ${missing_pkgs[@]}"
        yay -S --noconfirm "${missing_pkgs[@]}" || {
            echo "Failed to install some AUR packages. Continuing."
        }
    else
        echo "All yay packages are already installed."
    fi
}

# Function to check if Flatpak package is installed
check_flatpak_installed() {
    local pkg="$1"
    if flatpak list --app | grep -q "$pkg"; then
        echo "$pkg is already installed via Flatpak."
        return 0
    else
        return 1
    fi
}

# Function to install flatpak packages if they are not already installed
install_flatpak_packages() {
    local pkgs=("$@")
    local missing_pkgs=()

    for pkg in "${pkgs[@]}"; do
        if ! flatpak list --app | grep -q "$pkg"; then
            missing_pkgs+=("$pkg")
        fi
    done

    if [ ${#missing_pkgs[@]} -gt 0 ]; then
        echo "Installing missing flatpak packages: ${missing_pkgs[@]}"
        flatpak install -y "${missing_pkgs[@]}" || {
            echo "Failed to install some flatpak packages. Continuing."
        }
    else
        echo "All flatpak packages are already installed."
    fi
}

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
    # wget https://golang.org/dl/go1.20.5.linux-amd64.tar.gz
    # sudo tar -C /usr/local -xzf go1.20.5.linux-amd64.tar.gz
    echo 'export PATH=$PATH:/usr/local/go/bin' >> ~/.zshrc
    source ~/.zshrc

    # Install Rust
    echo "Installing Rust..."
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    source ~/.cargo/env
    source ~/.zshrc
    rustup update


    # Development Tools
    echo "Installing basic development tools..."
    sudo pacman -S --noconfirm github-cli lazygit gcc jdk-openjdk ruby

    # Flutter Install
    git clone https://github.com/flutter/flutter.git -b stable
    sudo mv flutter /opt/flutter

    # Cmake
    sudo pacman -S --noconfirm cmake
    # C#
    sudo pacman -S --noconfirm dotnet-runtime aspnet-runtime dotnet-sdk
    echo 'export PATH="$HOME/.dotnet/tools:$PATH"' >> ~/.zshrc
    # To be completely honest most things surrounding the installation of android
    # tools for flutter can be done through android Studio just navigate to the
    # settings and seach for 'Android SDK'

    # Android Development
    yay -S --noconfirm android-studio
    # yay -S --noconfirm android-sdk android-ndk

    flutter doctor

    # Install PHP and Lua
    echo "Installing PHP and Lua..."
    sudo pacman -S --noconfirm php lua

    # Runtime dependencies
    # Browsing and Other Applications
    echo "Installing Neovim"
    sudo pacman -S --noconfirm neovim

    # Productivity
    sudo pacman -S --noconfirm zoxide tmux

    # Audio
    sudo pacman -S --noconfirm easyeffects lsp-plugins ladspa calf

    # Install packages
    install_packages "${packages[@]}"
    install_yay_packages "${yay_packages[@]}"
    # Install Flatpak Packages
    install_flatpak_packages "${flatpak_packages[@]}"


    # Clean up
    echo "Cleaning up..."
    sudo pacman -Sc --noconfirm

    echo "All done! Now run util.sh and displaylinkinstall.sh and look at info.txt"
