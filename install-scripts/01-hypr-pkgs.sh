#!/bin/bash

# Hyprland Packages #

# edit your packages desired here.
# WARNING! If you remove packages here, dotfiles may not work properly.
# and also, ensure that packages are present in AUR and official Arch Repo

# add packages wanted here
Extra=(
  acpi                                                   # show battery and thermal info
  acpid                                                  # acpi daemon, for power events
  avahi                                                  # network discovery (mDNS, useful for local networking)
  base-devel                                             # essential build tools (make, gcc, etc.)
  curl                                                   # data transfer tool
  dialog                                                 # terminal UI menus/dialogs (some scripts need it)
  dosfstools                                             # FAT32 support
  gettext                                                # essential for localization/build tools
  gvfs                                                   # mounting/special drives support (esp. in file managers)
  mtools                                                 # access MS-DOS disks
  parted                                                 # partition manager
  gptfdisk                                               # GPT disk manager
  exfatprogs                                             # exFAT support
  ntfs-3g                                                # NTFS support
  util-linux                                             # essential utilities (fdisk, mount, etc.)
  e2fsprogs                                              # ext4 tools
  usbutils                                               # lsusb and USB info
  rsync                                                  # syncing and backup tool
  pv                                                     # pipe viewer (shows progress in terminal during file transfer)
  bat                                                    # `cat` alternative with syntax highlighting  
  tofi                                                   # Lightweight application launcher for Wayland (alternative to rofi-wayland)  
  easyeffects
  lsp-plugins 
  ladspa 
  calf
  gdm                                                    # alt display Manager for Gnome
  firefoxpwa                                             # firefox Extenstion for Browser Apps
  zoxide
  tmux
  fd
  feh
  gnome-disk-utility
  xdg-desktop-portal-wlr
  unrar
  usbmuxd
  ifuse
  libimobiledevice
  vlc
  obs-studio
  kodi
  bleachbit
  zathura
  zathura-pdf-mupdf
  qbittorrent
  neofetch
  papirus-icon-theme
  ttf-font-awesome
  terminus-font
  ttf-dejavu
  ttf-freefont
  xdotool
  geany
  geany-plugins
  arc-gtk-theme
  bluetui
  tilix
  redshift
  file-roller
  php
  lua
  cmake
  gcc
  jdk-openjdk
  ruby
  pyenv
  nvm
  rust
  dotnet-runtime
  aspnet-runtime
  dotnet-sdk
  ttf-jetbrains-mono
  ttf-jetbrains-mono-nerd
  betterbird-bin
  onedrive-abraunegg
  microsoft-edge-stable-bin
  google-chrome
  anki-bin
  qimgv
  moneymanagerex
  filebot
  android-studio
  vesktop
  blanket
  flatseal
  lazygit
  github-cli
  code
)

hypr_package=(
  #aylurs-gtk-shell
  bc
  cliphist
  curl
  grim
  gvfs
  gvfs-mtp
  hyprpolkitagent
  imagemagick
  inxi
  jq
  kitty
  kvantum
  nano
  network-manager-applet
  pamixer
  pavucontrol
  playerctl
  python-requests
  python-pyquery
  qt5ct
  qt6ct
  qt6-svg
  rofi-wayland
  slurp
  swappy
  swaync
  swww
  unzip # needed later
  wallust
  waybar
  ollama-cuda
  wget
  wl-clipboard
  wlogout
  xdg-user-dirs
  xdg-utils
  yad
)

# the following packages can be deleted. however, dotfiles may not work properly
hypr_package_2=(
  brightnessctl
  btop
  cava
  loupe
  fastfetch
  gnome-system-monitor
  mousepad
  mpv
  mpv-mpris
  nvtop
  nwg-look
  nwg-displays
  pacman-contrib
  qalculate-gtk
  yt-dlp
)

# List of packages to uninstall as it conflicts some packages
uninstall=(
  aylurs-gtk-shell
  mako
  cachyos-hyprland-settings
  rofi
  wallust-git
  rofi-lbonn-wayland
  rofi-lbonn-wayland-git
)

## WARNING: DO NOT EDIT BEYOND THIS LINE IF YOU DON'T KNOW WHAT YOU ARE DOING! ##
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Source the global functions script
if ! source "$(dirname "$(readlink -f "$0")")/Global_functions.sh"; then
  echo "Failed to source Global_functions.sh"
  exit 1
fi



# Set the name of the log file to include the current date and time
LOG="Install-Logs/install-$(date +%d-%H%M%S)_hypr-pkgs.log"

# conflicting packages removal
overall_failed=0
printf "\n%s - ${SKY_BLUE}Removing some packages${RESET} as it conflicts with  Hyprland Dots \n" "${NOTE}"
for PKG in "${uninstall[@]}"; do
  uninstall_package "$PKG" 2>&1 | tee -a "$LOG"
  if [ $? -ne 0 ]; then
    overall_failed=1
  fi
done

if [ $overall_failed -ne 0 ]; then
  echo -e "${ERROR} Some packages failed to uninstall. Please check the log."
fi

printf "\n%.0s" {1..1}

# Installation of main components
printf "\n%s - Installing ${SKY_BLUE} Hyprland necessary packages${RESET} .... \n" "${NOTE}"

for PKG1 in "${hypr_package[@]}" "${hypr_package_2[@]}" "${Extra[@]}"; do
  install_package "$PKG1" "$LOG"
done

printf "\n%.0s" {1..2}
