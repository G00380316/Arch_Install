#!/bin/bash

# Function to check if a command exists
command_exists() {
    command -v "$1" &> /dev/null
}

# Check if git is installed, else attempt installation
if ! command_exists git; then
    echo "Git is not installed. Attempting to install Git..."
    if command_exists pacman; then
        sudo pacman -Sy --noconfirm
        sudo pacman -S --noconfirm git
        if command_exists git; then
            echo "Git installation successful. Run this script again to use git."
            exit 1
        else
            echo "Cannot install Git automatically. Please install Git manually."
            exit 1
        fi
    fi
fi

echo "Git is installed. Continuing with the script..."

if [ -d "$HOME/Arch_Install" ]; then
    echo "Arch_Install directory already exists. Pulling latest changes..."
    cd "$HOME/Arch_Install" && git pull
else
    git clone https://github.com/G00380316/Arch_Install.git "$HOME/Arch_Install"
fi

DIRECTORY="$HOME/Arch_Install"

if [ ! -d "$DIRECTORY" ]; then
    echo "Error: Directory $DIRECTORY does not exist. Run the script again! ;)"
    exit 1
fi

echo "Directory $DIRECTORY exists. Continuing..."
sleep 3
clear

echo "
        +-+-+-+-+-+-+-+-+-+-+-+-+-+
        | | |G|0|0|3|8|0|3|1|6| | |
        +-+-+-+-+-+-+-+-+-+-+-+-+-+
        |c|u|s|t|o|m| |s|c|r|i|p|t|
        +-+-+-+-+-+-+ +-+-+-+-+-+-+
"

cd ~/Arch_Install/install-scripts/ || exit 1

# Make scripts executable
chmod +x *.sh

# Available scripts
SCRIPTS=( "vanilla_sway.sh" "packages.sh" "displaymanager.sh" "printers.sh" "bluetooth.sh" "displaylinkinstall.sh" "util.sh" "nerdfonts.sh" "AniInstall.sh" "wallpapers.sh" "install.sh" "cleanup.sh")

# Function to run a script
run_script() {
    echo "Running $1..."
    bash ./$1
}

# Loop to keep asking the user for valid input
while true; do
    # Display Menu
    echo " "
    echo " "
    echo "Select scripts to run (multiple selections allowed, separate by space):"
    echo " "
    echo "all or 0) All"
    echo "skip) Skip"
    echo "quit) Exit the script"
    echo " "
    for i in "${!SCRIPTS[@]}"; do
        echo "$((i + 1))) ${SCRIPTS[$i]}"
    done

    echo " "
    echo -n "Enter your choice: "
    read -ra CHOICES

    # If the user chooses to quit
    if [[ " ${CHOICES[*]} " =~ " quit " ]]; then
        echo "Exiting the script. Goodbye!"
        exit 0
    fi

    # Check if the user chose "0" or "all" for all scripts
    if [[ " ${CHOICES[*]} " =~ " 0 " || " ${CHOICES[*]} " =~ " all " ]]; then
        for script in "${SCRIPTS[@]}"; do
            run_script "$script"
        done
        break  # Exit the loop after running all scripts
    # If "skip" is chosen, skip the scripts
    elif [[ " ${CHOICES[*]} " =~ " skip " ]]; then
        echo "Skipping selected scripts."
        break  # Exit the loop after skipping
    # Handle invalid input
    else
        # Validate user input
        valid_input=true
        for choice in "${CHOICES[@]}"; do
            # Check if the input corresponds to a valid script index
            if [[ ! "$choice" =~ ^[0-9]+$ || "$choice" -lt 1 || "$choice" -gt "${#SCRIPTS[@]}" ]]; then
                valid_input=false
                break
            fi
        done

        if [ "$valid_input" = true ]; then
            # Run selected scripts
            for choice in "${CHOICES[@]}"; do
                index=$((choice - 1))
                run_script "${SCRIPTS[$index]}"
            done
            break  # Exit the loop after running selected scripts
        else
            echo "Invalid choice(s). Please try again."
        fi
    fi
done

cd ~/Arch_Install/

# Move custom configuration files
clear
sleep 3
echo "Working hard on moving your existing config files..."
clear
sleep 3
echo "Working hard on moving your existing config files..."
clear
sleep 3
echo "Working hard on moving your existing config files..."

rsync -a --progress ~/Arch_Install/configs/ ~/.config/
# Move application config folders to .config
echo "Moving zsh dependecies to HOME directory..."
cp -r ~/Arch_Install/configs/.zshenv ~
cp -r ~/Arch_Install/configs/.zshrc ~
cp -r ~/Arch_Install/configs/.p10k.zsh ~
cp -r ~/Arch_Install/configs/.fzf.zsh ~
cp -r ~/Arch_Install/configs/.gtkrc-2.0 ~

# Cloning Neovim and tmux configurations
echo "Cloning Neovim configuration..."
git clone https://github.com/G00380316/nvim.git ~/.config/nvim
echo "Cloning tpm for tmux configuration..."
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
bash ./wallpapers.sh

echo "Installing some Coding languages(python and node) and reseting font cache"
pyenv install 3.11.4
pyenv global 3.11.4
pip install -U hyfetch
nvm install --lts
nvm use --lts
fc-cache -fv

printf "\e[1;32mYou can now reboot! Thank you. Consider running cleanup Script will tidy and configure some missing pieces\e[0m\n"
