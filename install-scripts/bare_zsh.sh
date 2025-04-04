#!/bin/bash

# Install zsh
echo "Installing zsh..."
sudo pacman -S --noconfirm zsh

# Set zsh as the default shell
echo "Setting zsh as the default shell..."
if ! grep -q "$(which zsh)" /etc/shells; then
    echo "$(which zsh)" | sudo tee -a /etc/shells
fi
chsh -s "$(which zsh)"

# Create or modify .zshrc
# echo "Configuring zsh..."
# cat <<EOF > ~/.zshrc
# Custom Zsh Configuration
#export PATH="\$HOME/bin:\$HOME/.local/bin:/usr/local/bin:\$PATH"

# Oh My Zsh theme and plugins
#ZSH_THEME="robbyrussell"
#plugins=(git fzf)

#source \$ZSH/oh-my-zsh.sh
#EOF

# Install Oh My Zsh
#if [ ! -d "$HOME/.oh-my-zsh" ]; then
#    echo "Installing Oh My Zsh..."
#    sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/# #ohmyzsh/master/tools/install.sh)"
#fi

# Source .zshrc to apply changes (this affects the current script only)
source ~/.zshrc

# Notify the user to restart their session
echo "zsh has been installed and set as the default shell. Please log out and log back in for the changes to take effect."

