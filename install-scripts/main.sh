#!/bin/bash

set -euo pipefail
IFS=$'\n\t'

# === Helpers ===
log() { echo -e "[`date '+%F %T'`] $*"; }
err() { echo -e "[`date '+%F %T'`] ERROR: $*" >&2; }

require_command() {
  if ! command -v "$1" >/dev/null 2>&1; then
    err "Required command '$1' not found. Please install it before running this script."
    exit 1
  fi
}

prompt_yes_no() {
  local prompt="$1"
  local default="${2:-N}" # default N
  local reply
  while true; do
    read -r -p "$prompt (y/n) [default: $default]: " reply
    reply="${reply:-$default}"
    case "$reply" in
      [yY]) return 0 ;;
      [nN]) return 1 ;;
      *) echo "Please answer y or n." ;;
    esac
  done
}

safe_clone() {
  local repo="$1"
  local dest="$2"
  if [[ -d "$dest" ]]; then
    log "Directory $dest already exists; skipping clone."
    return 0
  fi
  if git clone "$repo" "$dest"; then
    log "Cloned $repo to $dest"
  else
    err "Failed to clone $repo"
    return 1
  fi
}

# === Environment Detection ===
IS_ROOT=false
if [[ "$EUID" -eq 0 ]]; then
  IS_ROOT=true
  log "Running as root."
else
  log "Not running as root; some operations may require sudo."
fi

# === Logging Setup ===
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
TIMESTAMP="$(date +%d-%H%M%S)"
LOG_DIR="Install-Logs"
mkdir -p "$LOG_DIR"
LOG="$LOG_DIR/install-$TIMESTAMP-cleanup.log"
FAILED_LOG="$LOG_DIR/failed-$TIMESTAMP.log"
touch "$FAILED_LOG"

exec > >(tee -a "$LOG") 2>&1

log "=== Script started ==="

# === Preconditions ===
require_command git
require_command fc-cache  # used later
require_command theme.patch.sh || true  # might not be in PATH; will be conditionally guarded
require_command theme.import.py || true

# Only require yay if user intends to install AUR packages later; check before using.

# === Package Arrays (deduplicated) ===
aur_packages=(
  "visual-studio-code-bin" "microsoft-edge-stable-bin" "google-chrome"
  "onlyoffice-bin" "obsidian" "flatseal" "blanket" "vesktop"
  "keypunch-git" "openai-chatgpt-nativefier" "downgrade" "youtube-music-bin"
  "onedrive-abraunegg" "dbgate-beta-bin" "postman-bin" "wayland-pipewire-idle-inhibit"
  "filebot" "obs-studio" "7zip" "github-desktop-bin"
  "fzf" "bat" "tofi" "bluetui" "pokemon-colorscripts-git"
  "spotify-adblock-git" "hypnotix-wayland" "pwvucontrol"
  "arc-gtx-theme" "papirus-icon-theme" "whyq" "freetube"
  "swww" "sof-bin" "zathura" "spicetify-cli" "quickemu-git"
  "iwmenu" "bzmenu" "setzer-git" "winegui"
)

pacman_packages=(
  "terminus-font" "ttf-font-awesome" "ttf-dejavu" "ttf-freefont" "papirus-icon-theme" "gnome-settings-daemon"
  "acpi" "acpid" "avahi" "base-devel" "curl" "dialog" "dosfstools" "exa" "file-roller" "gettext" "mtools" "pv"
  "unzip" "usbutils" "xdotool" "util-linux" "pipewire-libcamera" "ripgrep" "wf-recorder" "duf" "uwsm" "libnewt"
  "grim" "kitty" "libnotify" "redshift" "slurp" "konsole" "fish" "eza" "starship" "wl-clip-persist"
  "thunar" "thunar-archive-plugin" "thunar-media-tags-plugin" "thunar-volman" "gnome-disk-utility"
  "xfce4-power-manager" "networkmanager" "network-manager-applet"
  "parted" "gptfdisk" "exfatprogs" "ntfs-3g" "e2fsprogs" "usbmuxd" "ifuse" "libimobiledevice"
  "kodi" "unrar" "qbittorrent" "feh" "mousepad" "audacity"
  "rsync" "lazygit"
  "dolphin" "nwg-look" "btop" "gparted" "flatpak"
  "pipewire" "pipewire-pulse" "pipewire-jack" "pavucontrol-qt"
  "qt5-declarative" "qt5-quickcontrols" "qt5-quickcontrols2" "qt5-graphicaleffects"
  "firefox" "inotify-tools"
  "neovim" "zoxide"
  "systemd-resolvconf" "systemd" "systemd-sysvcompat"
  "nitrogen" "numlockx" "galculator" "cpu-x" "udns-utils"
  "whois" "tree" "htop" "i7z" "v4l2loopback-dkms" "lm_sensors"
)

# Deduplicate pacman_packages (just in case)
mapfile -t pacman_packages < <(printf '%s\n' "${pacman_packages[@]}" | awk '!seen[$0]++')

aur_failures=()
pacman_failures=()

# === Functions ===

install_aur_packages() {
  if ! command -v yay &>/dev/null; then
    err "yay not found; skipping AUR installation."
    aur_failures+=("yay-missing")
    return
  fi

  for pkg in "${aur_packages[@]}"; do
    log "⏳ Installing AUR package: $pkg"
    if ! yay -S --noconfirm --needed "$pkg"; then
      err "FAILED: $pkg"
      echo "❌ FAILED: $pkg" | tee -a "$FAILED_LOG"
      aur_failures+=("$pkg")
    else
      log "✅ $pkg installed successfully."
    fi
  done
}

install_pacman_packages() {
  for pkg in "${pacman_packages[@]}"; do
    log "⏳ Installing Pacman package: $pkg"
    if ! sudo pacman -S --noconfirm --needed "$pkg"; then
      err "FAILED: $pkg"
      echo "❌ FAILED: $pkg" | tee -a "$FAILED_LOG"
      pacman_failures+=("$pkg")
    else
      log "✅ $pkg installed successfully."
    fi
  done
}

verify_packages() {
  log "🔍 Verifying AUR installed packages..."
  for pkg in "${aur_packages[@]}"; do
    if ! pacman -Q "$pkg" &>/dev/null && ! yay -Q "$pkg" &>/dev/null; then
      echo "❌ Missing AUR package: $pkg"
    fi
  done

  log "🔍 Verifying Pacman installed packages..."
  for pkg in "${pacman_packages[@]}"; do
    if ! pacman -Q "$pkg" &>/dev/null && ! yay -Q "$pkg" &>/dev/null; then
      echo "❌ Missing Pacman package: $pkg"
    fi
  done
}

remove_orphans() {
  log "Removing orphaned packages..."
  mapfile -t orphans < <(pacman -Qdtq 2>/dev/null || true)
  if (( ${#orphans[@]} )); then
    sudo pacman -Rns --noconfirm "${orphans[@]}"
  fi

  if command -v yay &>/dev/null; then
    mapfile -t yay_orphans < <(yay -Qdtq 2>/dev/null || true)
    if (( ${#yay_orphans[@]} )); then
      yay -Rns --noconfirm "${yay_orphans[@]}"
    fi
  fi
}

install_easyeffects_presets() {
  log "Importing Easyeffect presets..."
  local tmp
  tmp="$(mktemp)"
  if curl -fsSL "https://raw.githubusercontent.com/JackHack96/PulseEffects-Presets/master/install.sh" -o "$tmp"; then
    echo "1" | bash "$tmp" || err "EasyEffects preset installer failed."
    rm -f "$tmp"
  else
    err "Failed to download EasyEffects presets installer."
  fi
}

build_weather_module() {
  log "Building Weather Module Plugins..."
  local script_path="$HOME/.config/hypr/UserScripts/Weather.py"
  if python3 "$script_path"; then
    log "Weather Module built successfully!"
    return
  fi

  log "Weather build failed; setting up isolated environment..."
  local venv_dir="$HOME/.local/venvs/weather"
  python3 -m venv "$venv_dir"
  # shellcheck source=/dev/null
  source "$venv_dir/bin/activate"
  pip install --upgrade pip pyquery requests

  if python3 "$script_path"; then
    log "Weather Module built successfully after installing dependencies!"
  else
    err "Failed to build Weather Module even after installing dependencies."
  fi
  deactivate
}

# === Main Interactive Flow ===

if prompt_yes_no "Do you want to run Dev.sh and Wallust.sh to make sure key dependencies are installed?" "Y"; then
  log "Running Dev.sh and Wallust.sh..."
  bash "${SCRIPT_DIR}"/devs.sh || err "devs.sh failed"
  bash "${SCRIPT_DIR}"/wallust.sh || err "wallust.sh failed"
else
  log "Skipping Dev.sh and Wallust.sh."
fi

if prompt_yes_no "Are you using a Laptop?" "N"; then
  sudo pacman -S --noconfirm --needed tlp tlp-rdw || err "Failed to install tlp"
  sudo systemctl enable --now tlp
  sudo cp ./Extra/etc/logind.conf /etc/systemd/ || err "Failed to copy logind.conf"
  ~/.config/hypr/scripts/Battery-manager.sh || log "Battery manager script executed (or missing)."
  log "Please use Battery-manager script in ~/.config/hypr/scripts/ to configure Battery Usage for tlp"
else
  log "No additional Laptop configuration for Power Saving"
fi

if prompt_yes_no "Do you want all of G00380316 Scripts to be passwordless (e.g., setting sdm theme, changing Battery Mode to Threshold mode)?" "N"; then
  if command -v enable-passwordless.sh &>/dev/null; then
    enable-passwordless.sh ~/.config || err "enable-passwordless.sh failed"
  else
    err "enable-passwordless.sh not found in PATH."
  fi
else
  log "Did not grant scripts root privileges."
fi

if prompt_yes_no "Do you want to swap Wireplumber for pipewire-media-session?" "N"; then
  sudo pacman -Rdd --noconfirm wireplumber || true
  sudo pacman -S --noconfirm --needed pipewire-media-session
else
  log "Retaining Wireplumber."
fi

# Fixes Chaotic-AUR (refresh file database)
if sudo pacman -Fy; then
  log "Refreshed file database."
else
  err "pacman -Fy failed."
fi

log "Automating some tasks for you..."

# Clean up unwanted files
log "Removing temporary files and folders..."
rm -rf ~/go ~/JetBrainsMono ~/install.sh ~/clone.sh ~/Clone
log "Cleanup complete."

# Service configuration
log "Configuring services..."
xdg-mime default thunar.desktop inode/directory application/x-gnome-saved-search

sudo cp ~/Arch_Install/install-scripts/assets/Hyprlock-main/ttyclock.ttf /usr/share/fonts/ || true
sudo cp ~/Arch_Install/install-scripts/assets/Hyprlock-main/Anurati-Regular.otf /usr/share/fonts/ || true

# Refresh font cache
fc-cache -fv || true

# Add themes
log "Adding Extra Hyprlock Theme..."
sudo cp -r ~/Arch_Install/install-scripts/Extra/Candy_Modified /usr/share/sddm/themes || true
log "Ensuring SDDM config for Kool Script..."
sudo cp -r ~/Arch_Install/install-scripts/Extra/etc/sddm.conf /etc/ || true

# Theme patching
THEME_PATCH_BASE="$HOME/.cache/hyde/themepatcher"
mkdir -p "$THEME_PATCH_BASE"
cd "$THEME_PATCH_BASE" || true

safe_clone "https://github.com/Maroc02/Moonlight.git" "./Moonlight" && theme.patch.sh "Moonlight" ./Moonlight || err "Moonlight patch failed"
safe_clone "https://github.com/cyb3rgh0u1/Another-World.git" "./Another-World" && theme.patch.sh "Another World" ./Another-World || err "Another World patch failed"

cd "$HOME/Arch_Install/install-scripts/Extra/Themes" || true
theme.patch.sh "Hack the Box" ./HackTheBox || true
theme.patch.sh "Windows 11" ./Windows11 || true
cp -r ~/Pictures/wallpapers ./G00380316/Configs/.config/hyde/themes/G00380316 || true
theme.patch.sh "G00380316" ./G00380316 || true
theme.patch.sh "Piece Of Mind" ./Piece_Of_Mind || true
theme.patch.sh "Crimson-Blue" ./Crimson-Blue || true
theme.patch.sh "Obsidian-Purple" ./Obsidian-Purple || true
theme.patch.sh "Eternal Arctic" ./Eternal_Arctic || true
theme.patch.sh "Electra" ./Electra || true
theme.patch.sh "Nightbrew" ./Nightbrew || true
theme.patch.sh "Tundra" ./Tundra || true
theme.patch.sh "LimeFrenzy" ./LimeFrenzy || true
theme.patch.sh "Amethyst-Aura" ./Amethyst-Aura || true

# Import and remote patch
theme.import.py --fetch all &

echo '1' | theme.patch.sh "Abyssal-Wave" "https://github.com/Itz-Abhishek-Tiwari/Abyssal-Wave" || err "Abyssal-Wave patch failed"

# Hyde wallbash scripts
chmod +x ~/.config/hyde/wallbash/scripts/* || true
bash ~/.config/hyde/wallbash/scripts/cava.sh || true
bash ~/.config/hyde/wallbash/scripts/code.sh || true
bash ~/.config/hyde/wallbash/scripts/chrome.sh || true
bash ~/.config/hypr/wallbash/scripts/discord.sh || true || bash ~/.config/hypr/wallbash/scripts/discord.sh || true
bash ~/.config/hyde/wallbash/scripts/spotify.sh || true

# Build Waybar plugin
log "Building Waybar Plugins..."
if [[ -d "$HOME/.config/waybar/waybar-module-pomodoro" ]]; then
  cd "$HOME/.config/waybar/waybar-module-pomodoro/" || true
  if command -v cargo &>/dev/null; then
    cargo build || err "Waybar plugin build failed."
    log "Waybar Plugins built!"
  else
    err "cargo not found; skipping Waybar plugin build."
  fi
else
  err "Waybar module directory missing."
fi

log "Applying GTK and icon themes..."
bash ~/Arch_Install/colorschemes/purple.sh || true
bash ~/Arch_Install/colorschemes/blue.sh || true

# Weather module
build_weather_module

# Daemon activation
log "Activating user services..."
systemctl --user daemon-reexec || true
systemctl --user daemon-reload || true
systemctl --user enable --now lid-manager.service || true
systemctl --user enable pipewire-pulse.service || true

systemctl --user start wallust-manager.service || true
systemctl --user start easyeffects-manager.service || true
systemctl --user start waybar-manager.service || true
systemctl --user start lid-manager.service || true

if loginctl show-user "$USER" | grep -q 'Linger=yes'; then
  log "Disabling lingering for $USER"
  sudo loginctl disable-linger "$USER" || true
  loginctl show-user "$USER" | grep Linger || true
fi

# Additional packages prompt
if prompt_yes_no "Do you want to install an Additional set of packages? (Recommended if first install)" "Y"; then
  log "Installing the additional packages..."
  install_aur_packages
  install_pacman_packages

  # Flatpak installs (ensure flatpak exists)
  if command -v flatpak &>/dev/null; then
    flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    flatpak install flathub org.gnome.Boxes -y || true
    flatpak install flathub info.febvre.Komikku -y || true
    flatpak install flathub org.cvfosammmm.Setzer -y || true
  else
    err "flatpak not installed; skipping flathub installs."
  fi
else
  log "No additional packages will be installed."
fi

verify_packages
remove_orphans
install_easyeffects_presets

log "Running final cleanup..."
sudo pacman -Sc --noconfirm || true

# === Summary Report ===
echo -e "\n========== INSTALLATION SUMMARY =========="
if (( ${#aur_failures[@]} )); then
  echo "❌ AUR packages failed (${#aur_failures[@]}):"
  printf '  - %s\n' "${aur_failures[@]}"
fi
if (( ${#pacman_failures[@]} )); then
  echo "❌ Pacman packages failed (${#pacman_failures[@]}):"
  printf '  - %s\n' "${pacman_failures[@]}"
fi
if (( ${#aur_failures[@]} == 0 && ${#pacman_failures[@]} == 0 )); then
  echo "✅ All packages installed successfully."
fi
echo -e "Failures log: $FAILED_LOG"
echo "🎉 Automation complete! Your system should now be fully configured and tidy!"

# Exit with non-zero if any package failures occurred
if (( ${#aur_failures[@]} || ${#pacman_failures[@]} )); then
  exit 1
fi

exit 0
