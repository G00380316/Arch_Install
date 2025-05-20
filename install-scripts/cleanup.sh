#!/bin/bash

## WARNING: DO NOT EDIT BELOW UNLESS YOU KNOW WHAT YOU'RE DOING ##
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Source global functions
if ! source "$(dirname "$(readlink -f "$0")")/Global_functions.sh"; then
    echo "Failed to source Global_functions.sh"
    exit 1
fi

    aur_packages=( "geany" "geany-plugins" "code" "zed"
      "microsoft-edge-stable-bin" "google-chrome"
      "zen-browser-bin" "bluemail"
      "onlyoffice-bin" "anki-bin" "obsidian" "flatseal" "blanket" "vesktop"
      "keypunch-git" "openai-chatgpt-nativefier"
      "onedrive-abraunegg" "dbgate-beta-bin" "postman-bin"
      "filebot" "obs-studio" "7zip"
      "fzf" "bat" "tofi" "boxes" "foot" "bluetui" "pokemon-colorscripts-git"
      "spotube"
      "arc-gtx-theme" "papirus-icon-theme"
      "swww" "bleachbit" "sof-bin" "zathura" "spicetify-cli"
      "iwmenu" "bzmenu" "setzer-git" )

    pacman_packages=( 
      # ── Fonts & themes
      "terminus-font" "ttf-font-awesome" "ttf-dejavu" "ttf-freefont" "papirus-icon-theme" "gnome-settings-daemon"

      # ── System & shell utilities
      "acpi" "acpid" "avahi" "base-devel" "curl" "dialog" "dosfstools" "exa" "file-roller" "gettext" "mtools" "pv" "unzip" "usbutils" "xdotool" "util-linux"

      # ── Terminal & clipboard tools
      "grim" "kitty" "libnotify" "redshift" "slurp" "konsole"

      # ── File management
      "thunar" "thunar-archive-plugin" "thunar-media-tags-plugin" "thunar-volman" "gnome-disk-utility"

      # ── Power & networking
      "xfce4-power-manager" "networkmanager" "network-manager-applet"

      # ── File systems & drives
      "parted" "gptfdisk" "exfatprogs" "ntfs-3g" "e2fsprogs" "usbmuxd" "ifuse" "libimobiledevice"

      # ── Media & extras
      "vlc" "kodi" "unrar" "qbittorrent" "feh"

      # ── Dev tools
      "rsync" "lazygit" "firefoxpwa"

      # ── Desktop environment tools
      "dolphin" "nwg-look" "btop" "gparted" "flatpak"

      # ── Pipewire (audio stack)
      "pipewire" "pipewire-pulse" "pipewire-jack" "pavucontrol"

      # ── Qt libraries
      "qt5-declarative" "qt5-quickcontrols" "qt5-quickcontrols2" "qt5-graphicaleffects"

      # ── Browsers again (from pacman)
      "firefox" "inotify-tools"

      # ── Dev
      "tmux" "neovim" "zoxide"

      # ── Fixing Suspend & Hibernate
      "systemd-resolvconf" "systemd" "systemd-sysvcompat"
    )

    aur_failures=()
    pacman_failures=()

    LOG="Install-Logs/install-$(date +%d-%H%M%S)_cleanup.log"
    FAILED_LOG="Install-Logs/failed-$(date +%d-%H%M%S).log"
    touch "$FAILED_LOG"

    # Redirecting all output and errors to log file
    exec > >(tee -a "$LOG") 2>&1

    # Log the start of the script
    echo "=== Script started at $(date) ==="

    echo "Do you want to run Dev.sh and Wallust.sh to make sure key dependencies are installed? (y/n)"
    read -r answer1

    if [[ "$answer1" == "y" || "$answer1" == "Y" ]]; then
        echo "running Dev.sh and Wallust.sh..."

        bash "${SCRIPT_DIR}"/devs.sh
        bash "${SCRIPT_DIR}"/wallust.sh

    else
        echo "No additional packages will be installed."
    fi

    echo "Are you using a Laptop? (y/n)"
    read -r answer2

    if [[ "$answer2" == "y" || "$answer2" == "Y" ]]; then

        sudo pacman -S --noconfirm --needed tlp tlp-rdw
        sudo systemctl enable --now tlp

    else
        echo "No additional Laptop."
    fi

    # Fixes Chaotic-Aur
    sudo pacman -Fy
    echo "Automating some tasks for you..."

    ### Clean Up Unwanted Files ###
    echo "Removing temporary files and folders..."
    rm -rf ~/go ~/JetBrainsMono ~/install.sh ~/clone.sh ~/Clone
    echo "Cleanup complete."

    ### Service Configuration ###
    echo "Configuring services..."

    xdg-mime default thunar.desktop inode/directory application/x-gnome-saved-search

    sudo cp ~/Arch_Install/install-scripts/assets/Hyprlock-main/ttyclock.ttf /usr/share/fonts/
    sudo cp ~/Arch_Install/install-scripts/assets/Hyprlock-main/Anurati-Regular.otf /usr/share/fonts/

    # Caching fonts once again
    fc-cache -fv

    echo "Configuring FireFoxPWA"
    cp -r ~/Arch_Install/install-scripts/Extra/firefoxpwa ~/.local/share/
    echo "Configuring for FireFoxPWA is complete (Please enable plugins in the Apps {Youtube , Youtube Music and Timetree})"
    echo "For the best experience Shortkeys to open them should be working straight away!!"

    ### Add Themes ###
    echo "Adding Extra Hyprlock Theme..."
    sudo cp -r ~/Arch_Install/install-scripts/Extra/Candy_Modified /usr/share/sddm/themes

    cd ~/.cache/hyde/themepatcher/
    git clone https://github.com/Maroc02/Moonlight.git
    theme.patch.sh "Moonlight" ./Moonlight

    cd ~/.cache/hyde/themepatcher/
    git clone https://github.com/cyb3rgh0u1/Another-World.git
    theme.patch.sh "Another World" ./Another-World

    echo '1' | theme.patch.sh "Abyssal-Wave" "https://github.com/Itz-Abhishek-Tiwari/Abyssal-Wave"

    cd ~/Arch_Install/install-scripts/Extra/Themes
    theme.patch.sh "Hack the Box" ./HackTheBox
    theme.patch.sh "MacOs" ./MacOs
    theme.patch.sh "Windows 11" ./Windows11
    cp -r ~/Pictures/wallpapers ./G00380316/Configs/.config/hyde/themes/G00380316
    theme.patch.sh "G00380316" ./G00380316
    theme.patch.sh "Piece Of Mind" ./Piece_Of_Mind
    theme.patch.sh "Crimson-Blue" ./Crimson-Blue
    theme.patch.sh "Obsidian-Purple" ./Obsidian-Purple
    theme.patch.sh "Eternal Arctic" ./Eternal_Arctic
    theme.patch.sh "Electra" ./Electra
    theme.patch.sh "Grukai" ./Grukai

    # Enabling some wallbash features
    bash ~/.config/hyde/wallbash/scripts/cava.sh
    bash ~/.config/hyde/wallbash/scripts/code.sh
    bash ~/.config/hyde/wallbash/scripts/chrome.sh
    bash ~/.config/hyde/wallbash/scripts/discord.sh
    bash ~/.config/hyde/wallbash/scripts/spotify.sh

    ### Build Waybar Plugin ###
    echo "Building Waybar Plugins..."
    cd ~/.config/waybar/waybar-module-pomodoro/
    cargo build
    echo "Waybar Plugins built!"

    ### Build Neovim Plugins ###
    echo "Building Neovim plugins..."
    cd ~/.local/share/nvim/lazy/command-t/lua/wincent/commandt/lib
    make clean && make
    echo "Neovim plugins built!"

    echo "Applying GTK and icon themes..."
    bash ~/Arch_Install/colorschemes/purple.sh
    bash ~/Arch_Install/colorschemes/blue.sh

    ### Build Weather Module ###
    echo "Building Weather Module Plugins..."
    if python3 ~/Arch_Install/config/hypr/UserScripts/Weather.py; then
        echo "Weather Module built successfully!"
    else
        echo "Error occurred. Installing pyquery..."
        python -m venv path/to/venv
        source path/to/venv/bin/activate
        sudo pacman --noconfirm --needed -S python-pyquery
        sudo pacman --noconfirm --needed -S python-requests

        if python3 ~/.config/hypr/UserScripts/Weather.py; then
            echo "Weather Module built successfully after installing pyquery!"
        else
            echo "Failed to build Weather Module. Please check the script."
        fi
    fi

    # Activate daemon for Wallust
    systemctl --user daemon-reexec
    systemctl --user daemon-reload
    systemctl --user enable --now wallust-manager.service
    systemctl --user enable --now easyeffects-manager.service

    # Ask the user if they want to install the Additional packages
    echo "Do you want to install an Additonal set of packages? (y/n)(Recommended if it is first install)"
    read -r answer

    if [[ "$answer" == "y" || "$answer" == "Y" ]]; then
        echo "Installing the additonal packages..."

        for pkg in "${aur_packages[@]}"; do
          echo -e "\n⏳Installing AUR package: $pkg"
          if ! yay -S --noconfirm --needed "$pkg"; then
            echo "❌ FAILED: $pkg" | tee -a "$FAILED_LOG"
            aur_failures+=("$pkg")
          fi
            echo "✅ $pkg installed successfully."
        done

        # Pacman installs
        for pkg in "${pacman_packages[@]}"; do
          echo -e "\n⏳Installing Pacman package: $pkg"
          if ! sudo pacman -S --noconfirm --needed "$pkg"; then
            echo "❌ FAILED: $pkg" | tee -a "$FAILED_LOG"
            pacman_failures+=("$pkg")
          fi
            echo "✅ $pkg installed successfully."
        done

        zsh -c "flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo"
        
        zsh -c "
     flatpak install flathub org.gnome.Boxes -y
        flatpak install flathub info.febvre.Komikku -y
        flatpak install flathub org.cvfosammmm.Setzer -y"

    else
        echo "No additional packages will be installed."
    fi

    echo "🔍 Verifying Aur installed packages..."
    for pkg in "${aur_packages[@]}"; do
      if ! pacman -Q "$pkg" &>/dev/null && ! yay -Q "$pkg" &>/dev/null; then
        echo "❌ $pkg is missing"
      fi
    done

    echo "🔍 Verifying Pacman installed packages..."
    for pkg in "${pacman_packages[@]}"; do
      if ! pacman -Q "$pkg" &>/dev/null && ! yay -Q "$pkg" &>/dev/null; then
        echo "❌ $pkg is missing"
      fi
    done

    ### Remove Orphaned Packages ###
    echo "Removing orphaned packages..."
    if pacman -Qdtq &> /dev/null; then
        sudo pacman -Rns $(pacman -Qdtq)
    fi
    if command -v yay &> /dev/null && yay -Qdtq &> /dev/null; then
        yay -Rns $(yay -Qdtq)
    fi
    echo "Unwanted packages removed!"

    ### Easy Effect Presets ###
    echo "Importing Easyeffect presets..."
    echo "1" | bash -c "$(curl -fsSL https://raw.githubusercontent.com/JackHack96/PulseEffects-Presets/master/install.sh)"

    ### Final Cleanup ###
    echo "Running final cleanup..."
    sudo pacman -Sc --noconfirm
    
    # Report
    echo -e "\n========== INSTALLATION SUMMARY =========="

    if [[ ${#aur_failures[@]} -gt 0 ]]; then
      echo -e "❌ AUR packages failed:"
      printf '  - %s\n' "${aur_failures[@]}"
    fi

    if [[ ${#pacman_failures[@]} -gt 0 ]]; then
      echo -e "❌ Pacman packages failed:"
      printf '  - %s\n' "${pacman_failures[@]}"
    fi

    if [[ ${#aur_failures[@]} -eq 0 && ${#pacman_failures[@]} -eq 0 ]]; then
      echo "✅ All packages installed successfully."
    fi

    echo -e "Failures log: $FAILED_LOG"

    echo "🎉 Automation complete! Your system should now be fully configured and tidy!"
