## Wayland compositor

Assuming you have already installed at least the minimal Arch-based system.
The series of shell scripts are intended to facilitate installing popular window managers.

Within the install.sh file, you can install the following window managers:

- Hyprland
- Sway
- Gnome

**User can select with multiple choices throughout the configuration what they want to include in their new system**

# Installation

```
sudo pacman -S wget

# More Animations

wget https://github.com/G00380316/Arch_Install/raw/main/install.sh

chmod +x install.sh

./install.sh

or

# Minimal Animations and Configurations

wget https://github.com/G00380316/Arch_Install/raw/old/install.sh

chmod +x install.sh

./install.sh
```

## Post-Install

```
After the installation is complete reboot and then run "util.sh" and "main.sh"
once more, And any other scripts in the install-scripts directory if needs be.

This will tidy up the Installation a bit and make sure some plugin,
packages are built (Run multiple times to make sure all is well)

~/Arch_Install/install-scripts/main.sh

Some packages may be missing but just use the "in <package>" to install any
packages you would like.

Example: "in wlogout" or just run "in" for install in your terminal and it will do a fzf (fuzzy find) of the available packages across different package managers. If you would like to uninstall any of my apps you can do so with "un" in ther terminal

Any troubles navigating the system press "SUPER"(Windows Key) + "H" for all the keybinds

In the "~/.config/hypr/Monitor_Profiles" please edit all the profiles to work with your specific monitors, My device is a Leveno Aura Yogi 7i Gen 10 so it has a 4k display and I have two 1080p monitors that I usually connect with so making Profiles that I can just switch to by press "Windows Key" + 5 is so handy you can use Nwg-displays to help you configure and then just copy monitor.conf to Monitor_Profiles folder to add it to the options.

If you want to check out more available themes and make sure all the themes are properly configured then in any terminal type "theme.import.py --select" and then hit enter to choose new themes and then once that is done run "theme.import.py --fetch all" to refresh, fix and update your themes !!!

To get the rofi styling activated "CTRL" + "Windows" + "R" and then just press enter to select the default style

Lastly I recommend using uwsm hyprland it feels cleaner to use then the primary Hyprland or maybe is just me !!!😅
```

NOTE: The recommended login manager will be sddm for cool configuration.
NOTE: Sway configuration is basic as I don't really use Sway but still a great
starting point for those that need one
NOTE: If there is any issues or Questions please write it as a issue or discussion in the repo I will get back to you as soon as possible
NOTE: That this Arch-Install is infused with my initial config then built upon with both HYDE and JaKoolit Arch Config allowing both to work together.
