#!/bin/bash

# Function to remove blocking dependencies and install packages
install_packages() {
    local packages=("$@")

    for package in "${packages[@]}"; do
        echo "Processing $package..."
        # Remove conflicting dependencies
        local blocking_deps=()
        for dep in $(pactree -r "$package" 2>/dev/null | tail -n +2); do
            if pacman -Qi "$dep" &>/dev/null; then
                blocking_deps+=("$dep")
            fi
        done

        if [ ${#blocking_deps[@]} -gt 0 ]; then
            echo "Removing blocking dependencies: ${blocking_deps[*]}"
            sudo pacman -Rns --noconfirm "${blocking_deps[@]}"
        fi

        # Install the package
        echo "Installing $package..."
        if ! sudo pacman -S --noconfirm "$package"; then
            echo "Failed to install $package. Skipping..."
            continue
        fi

        # Reinstall previously removed dependencies
        if [ ${#blocking_deps[@]} -gt 0 ]; then
            echo "Reinstalling dependencies: ${blocking_deps[*]}"
            sudo pacman -S --noconfirm "${blocking_deps[@]}"
        fi
    done
}

# Main list of packages
file_managers=("thunar" "pcmanfm" "krusader" "nautilus" "nemo" "dolphin" "ranger" "nnn" "lf")

echo "Choose File Managers to install (space-separated list, e.g., 1 6 7):"
for i in "${!file_managers[@]}"; do
    echo "$((i+1)). ${file_managers[i]}"
done
read -rp "Selection: " file_manager_selection

selected_file_managers=()
for index in $file_manager_selection; do
    selected_file_managers+=("${file_managers[index-1]}")
done

# Graphics
graphics=("gimp" "flameshot" "eog" "sxiv" "inkscape" "scrot" "feh")

echo "Choose graphics applications to install (space-separated list, e.g., 1 4 7):"
for i in "${!graphics[@]}"; do
    echo "$((i+1)). ${graphics[i]}"
done
read -rp "Selection: " graphics_selection

selected_graphics=()
for index in $graphics_selection; do
    selected_graphics+=("${graphics[index-1]}")
done

# Terminals
terminals=("alacritty" "gnome-terminal" "konsole" "terminator" "xfce4-terminal")

echo "Choose Terminals to install (space-separated list, e.g., 1 3):"
for i in "${!terminals[@]}"; do
    echo "$((i+1)). ${terminals[i]}"
done
read -rp "Selection: " terminal_selection

selected_terminals=()
for index in $terminal_selection; do
    selected_terminals+=("${terminals[index-1]}")
done

# Text Editors
text_editors=("geany" "kate" "gedit" "l3afpad" "mousepad" "pluma")

echo "Choose Text Editors to install (space-separated list, e.g., 1 3 5):"
for i in "${!text_editors[@]}"; do
    echo "$((i+1)). ${text_editors[i]}"
done
read -rp "Selection: " text_editor_selection

selected_text_editors=()
for index in $text_editor_selection; do
    selected_text_editors+=("${text_editors[index-1]}")
done

# Multimedia
multimedia=("mpv" "kodi" "vlc" "audacity" "kdenlive" "obs-studio" "rhythmbox" "ncmpcpp" "mkvtoolnix-gui" "ffmpeg" "yt-dlp")

echo "Choose Multimedia applications to install (space-separated list, e.g., 1 3 5), or type 'all' to install all):"
for i in "${!multimedia[@]}"; do
    echo "$((i+1)). ${multimedia[i]}"
done
read -rp "Selection: " multimedia_selection

selected_multimedia=()
if  [[ "$multimedia_selection" == "all" ]]; then
    selected_multimedia=("${multimedia[@]}")
else
    for index in $multimedia_selection; do
        selected_multimedia+=("${multimedia[index-1]}")
    done
fi

# Utilities
utilities=( \
    "gparted" "gnome-disk-utility" "neofetch" "nitrogen" "numlockx" "galculator" "cpu-x" "udns-utils" \
    "whois" "tree" "btop" "htop" "brightnessctl" "i7z" "bleachbit" \
    "xdg-desktop-portal-wlr" "v4l2loopback-dkms" "lm_sensors" "fd" "ripgrep" \
    "pavucontrol" "wl-clipboard" "bc"
)

echo "Choose utilities applications to install (space-separated list, e.g., 1 3 5, or type 'all' to install all):"
for i in "${!utilities[@]}"; do
    echo "$((i+1)). ${utilities[i]}"
done
read -rp "Selection: " utilities_selection

selected_utilities=()
if  [[ "$utilities_selection" == "all" ]]; then
    selected_utilities=("${utilities[@]}")
else
    for index in $utilities_selection; do
        selected_utilities+=("${utilities[index-1]}")
    done
fi

# Other Packages
other_packages=( \
    "unrar" "freetype2" "harfbuzz" "cairo" "pango" "libxkbcommon" "meson" "scdoc" "wayland-protocols" \
    "dhclient" "usbmuxd" "ifuse" "libimobiledevice" "gvfs-mtp" "mtpfs" "zathura" "zathura-pdf-mupdf" \
    "wlr-randr" "qbittorrent"
)

echo "Choose other packages to install (space-separated list, e.g., 1 3 5, or type 'all' to install all):"
for i in "${!other_packages[@]}"; do
    echo "$((i+1)). ${other_packages[i]}"
done
read -rp "Selection: " other_packages_selection

selected_other_packages=()
if [[ "$other_packages_selection" == "all" ]]; then
    selected_other_packages=("${other_packages[@]}")
else
    for index in $other_packages_selection; do
        selected_other_packages+=("${other_packages[index-1]}")
    done
fi

# Install selected packages
install_packages "${selected_file_managers[@]}" "${selected_graphics[@]}" "${selected_terminals[@]}" \
    "${selected_text_editors[@]}" "${selected_multimedia[@]}" "${selected_utilities[@]}" "${selected_other_packages[@]}"
