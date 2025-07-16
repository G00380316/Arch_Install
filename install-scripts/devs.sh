#!/bin/bash

## WARNING: DO NOT EDIT BELOW UNLESS YOU KNOW WHAT YOU'RE DOING ##
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Source global functions
if ! source "$(dirname "$(readlink -f "$0")")/Global_functions.sh"; then
    echo "Failed to source Global_functions.sh"
    exit 1
fi

LOG="Install-Logs/install-$(date +%d-%H%M%S)_dev.log"
mkdir -p "$(dirname "$LOG")"

exec > >(tee -a "$LOG") 2>&1

# Log the start of the script
echo "=== Script started at $(date) ==="

# Check if yay and pacman are available
command -v yay >/dev/null 2>&1 || { echo "yay not found. Please install yay first."; exit 1; }
command -v pacman >/dev/null 2>&1 || { echo "pacman not found. Are you on Arch-based Linux?"; exit 1; }

# Clone Neovim config
echo "Cloning Neovim configuration..."
if [ -d ./nvim/.git ]; then
    echo "nvim config already cloned in ./nvim, pulling latest changes..."
    git -C ./nvim pull
else
    echo "Cloning nvim config fresh..."
    rm -rf ./nvim
    git clone https://github.com/G00380316/nvim.git
fi

rm -rf ~/.config/nvim
mkdir -p ~/.config
cp -r ./nvim ~/.config/nvim/

# Clone tpm for tmux
# echo "Cloning tpm for tmux configuration..."
# if [ -d ./tpm/.git ]; then
#     echo "TPM already exists in ./tpm, pulling latest changes..."
#     git -C ./tpm pull
# else
#     echo "Cloning TPM fresh into ./tpm..."
#     git clone https://github.com/tmux-plugins/tpm ./tpm
# fi
#
# rm -rf ~/.tmux/plugins/tpm
# mkdir -p ~/.tmux/plugins/
# cp -r ./tpm ~/.tmux/plugins/tpm

# Setup dirs
dircolors -p > ~/.dircolors
mkdir -p ~/Coding/Projects ~/.cache/hyde/wallpapers

# Install JetBrains Nerd Font if not already installed
echo "Checking for JetBrains Mono Nerd Font..."
if fc-list | grep -i "JetBrainsMono Nerd Font" > /dev/null; then
    echo "JetBrainsMono Nerd Font is already installed. Skipping download."
else
    echo "Installing JetBrainsMono Nerd Font..."
    FONT_ZIP="JetBrainsMono.zip"
    FONT_URL="https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip"
    curl -LO "$FONT_URL"
    unzip "$FONT_ZIP" -d JetBrainsMono
    rm -f "$FONT_ZIP"
    mkdir -p ~/.local/share/fonts
    mv JetBrainsMono/* ~/.local/share/fonts/
    rm -rf JetBrainsMono
    fc-cache -fv
fi

# Pre-select clap-host provider to avoid pacman prompt
sudo pacman -S --noconfirm --needed reaper
sudo pacman -S --noconfirm --needed parallel

# Core dev stack
echo "Installing development tools..."
sudo pacman -S --noconfirm --needed lsp-plugins ladspa calf easyeffects
sudo pacman -S --noconfirm --needed php lua
sudo pacman -S --noconfirm --needed zoxide neovim #tmux
sudo pacman -S --noconfirm --needed cmake github-cli lazygit gcc jdk-openjdk ruby
sudo pacman -S --noconfirm --needed dotnet-runtime aspnet-runtime dotnet-sdk
sudo pacman -S --noconfirm --needed jdk8-openjdk jdk17-openjdk
echo 'export JAVA_HOME=/usr/lib/jvm/java-8-openjdk' >> ~/.zshrc
echo 'export PATH="$JAVA_HOME/bin:$PATH"' >> ~/.zshrc

# Install Dotnet
if command -v dotnet >/dev/null 2>&1; then
    echo "C# is already installed. Skipping..."
else
    echo 'export PATH="$HOME/.dotnet/tools:$PATH"' >> ~/.zshrc
    zsh -i -c "source ~/.zshrc"
fi

# Install Python via pyenv
echo "Installing pyenv and Python..."
if [ -d "$HOME/.pyenv" ]; then
    echo "pyenv is already installed. Skipping..."
else
    curl https://pyenv.run | zsh
    echo -e '\n# Pyenv configuration' >> ~/.zshrc
    echo 'export PATH="$HOME/.pyenv/bin:$PATH"' >> ~/.zshrc
    echo 'eval "$(pyenv init --path)"' >> ~/.zshrc
    echo 'eval "$(pyenv init -)"' >> ~/.zshrc
    zsh -i -c "source ~/.zshrc"
    pyenv install 3.11.4
    pyenv global 3.11.4
    sudo pacman --noconfirm --needed -S python-pip
    python -m venv path/to/venv
    source path/to/venv/bin/activate
    pip install hyfetch
fi

# Install Node via nvm
if [ -d "$HOME/.nvm" ]; then
    echo "nvm is already installed. Skipping..."
else
    echo "Installing nvm and Node.js..."
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | zsh
    export NVM_DIR="$HOME/.nvm"
    source "$NVM_DIR/nvm.sh"
    nvm install node
    nvm use node
fi

# Install Go
if command -v go >/dev/null 2>&1; then
    echo "Go is already installed. Skipping..."
else
    echo "Installing Go..."
    GO_VER="1.20.5"
    GO_TARBALL="go${GO_VER}.linux-amd64.tar.gz"
    wget "https://golang.org/dl/${GO_TARBALL}"
    sudo tar -C /usr/local -xzf "${GO_TARBALL}"
    rm -f "${GO_TARBALL}"
    echo 'export PATH=$PATH:/usr/local/go/bin' >> ~/.zshrc
    zsh -i -c "source ~/.zshrc"
fi

# Install Rust
if command -v cargo >/dev/null 2>&1; then
    echo "Rust is already installed. Skipping..."
else
    echo "Installing Rust..."
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    source ~/.cargo/env
    rustup update
fi

# Install Flutter + Android
if command -v flutter >/dev/null 2>&1; then
    echo "Flutter is already installed. Skipping..."
else
    echo "Installing Flutter and Android tools..."
    sudo rm -rf /opt/flutter
    git clone https://github.com/flutter/flutter.git -b stable
    sudo mv flutter /opt/flutter
    echo 'export PATH="$PATH:/opt/flutter/bin"' >> ~/.zshrc
    echo 'export CHROME_EXECUTABLE="/usr/bin/google-chrome-stable"' >> ~/.zshrc
    zsh -i -c "source ~/.zshrc"
    yay -S --noconfirm --needed android-studio sdkmanager
    sudo sdkmanager --install "cmdline-tools;latest"
    sudo sdkmanager "platforms;android-34"
    pacman -S --noconfirm --needed android-sdk android-sdk-platform-tools android-sdk-build-tools
    yay -Rns sdkmanager
    # echo 'export PATH="$PATH:~/.android/cmdline-tools/latest/bin"' >> ~/.zshrc
    sudo chown -R $USER:$USER /opt/android-sdk
    flutter doctor
fi

# Cleanup
echo "Cleaning up..."
sudo pacman -Scc --noconfirm
sudo yay -Scc --noconfirm


echo "=== All done! Dev environment installed ==="
