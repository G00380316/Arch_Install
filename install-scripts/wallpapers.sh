#!/bin/bash

# Set some colors for output messages
OK="$(tput setaf 2)[OK]$(tput sgr0)"
ERROR="$(tput setaf 1)[ERROR]$(tput sgr0)"
NOTE="$(tput setaf 3)[NOTE]$(tput sgr0)"
INFO="$(tput setaf 4)[INFO]$(tput sgr0)"
WARN="$(tput setaf 1)[WARN]$(tput sgr0)"
CAT="$(tput setaf 6)[ACTION]$(tput sgr0)"
MAGENTA="$(tput setaf 5)"
ORANGE="$(tput setaf 214)"
WARNING="$(tput setaf 1)"
YELLOW="$(tput setaf 3)"
GREEN="$(tput setaf 2)"
LUE="$(tput setaf 4)"
SKY_BLUE="$(tput setaf 6)"
RESET="$(tput sgr0)"

wallpaper=$HOME/Pictures/wallpapers/Gear5luffy.jpg

# Check if running as root. If root, script will exit
if [[ $EUID -eq 0 ]]; then
    echo "${ERROR}  This script should ${WARNING}NOT${RESET} be executed as root!! Exiting......."
    printf "\n%.0s" {1..2} 
    exit 1
fi

# Create Directory for Copy Logs
if [ ! -d Copy-Logs ]; then
    mkdir Copy-Logs
fi

# Function to print colorful text
print_color() {
    printf "%b%s%b\n" "$1" "$2" "$CLEAR"
}

# Set the name of the log file to include the current date and time
LOG="Copy-Logs/install-$(date +%d-%H%M%S)_dotfiles.log"

# wallpaper stuff
mkdir -p $HOME/Pictures/wallpapers
if rsync -a --progress ./wallpapers $HOME/Pictures ; then
echo "${OK} Some ${MAGENTA}wallpapers${RESET} copied successfully!" | tee -a "$LOG"
else
echo "${ERROR} Failed to copy some ${YELLOW}wallpapers${RESET}" | tee -a "$LOG"
fi

# additional wallpapers
printf "\n%.0s" {1..1}
echo "${MAGENTA}By default only a few wallpapers are copied${RESET}..."

while true; do
read -rp "${CAT} Would you like to download additional wallpapers? ${WARN} This is more than 800 MB (y/n)" WALL
case $WALL in
    [Yy])
    echo "${NOTE} Downloading additional wallpapers..."
    if git clone "https://github.com/G00380316/Wallpaper-Bank.git"; then
        echo "${OK} Wallpapers downloaded successfully." 2>&1 | tee -a "$LOG"

        # Check if wallpapers directory exists and create it if not
        if [ ! -d "$HOME/Pictures/wallpapers" ]; then
            mkdir -p "$HOME/Pictures/wallpapers"
            echo "${OK} Created wallpapers directory." 2>&1 | tee -a "$LOG"
        fi

        if rsync -a --progress ./Wallpaper-Bank/* "$HOME/Pictures/" >> "$LOG" 2>&1; then
            echo "${OK} Wallpapers copied successfully." 2>&1 | tee -a "$LOG"
            rm -rf ./Wallpaper-Bank 2>&1 # Remove cloned repository after copying wallpapers
            break
        else
            echo "${ERROR} Copying wallpapers failed" 2>&1 | tee -a "$LOG"
        fi
    else
        echo "${ERROR} Downloading additional wallpapers failed" 2>&1 | tee -a "$LOG"
        rm -rf ./Wallpaper-Bank
        echo "${INFO} Try Again..." 2>&1 | tee -a "$LOG"
    fi
    ;;
[Nn])
    echo "${NOTE} You chose not to download additional wallpapers." 2>&1 | tee -a "$LOG"
    break
    ;;
*)
    echo "Please enter 'y' or 'n' to proceed."
    ;;
esac
done

# initialize wallust to avoid config error on hyprland
wallust run -s $wallpaper 2>&1 | tee -a "$LOG"
