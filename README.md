## Wayland compositor

Assuming you have already installed a minimal Arch-based system.
The series of shell scripts are intended to facilitate installing popular window managers.

Within the install.sh file, you can choose to install the following window managers:

- hyprland
- sway

**User can select between vanilla(non-customized) and completely customized (my personal customization)**

# Installation

```
sudo pacman -S wget

# More Animations
wget https://github.com/G00380316/Arch_Install/raw/main/install.sh

or

# Minimal Animations
wget https://github.com/G00380316/Arch_Install/raw/old/install.sh

chmod +x install.sh

./install.sh
```

## Post-Install

```
After the installation is complete reboot and then run "cleanup.sh"
this will tidy up the Installation a bit and make sure some plugin
packages are built (Run multiple times to make sure all is well)

~/Arch_Install/install-scripts/cleanup.sh

after install please make sure wallust was installed run the script in the
install script directory (The wallust waybar config should be changing colours)
Some packages may be missing but just use the "in <package>" to install any
packages you would like.

Example: "in wlogout"

there is a good chance that this package wasnt installed

Any troubles navigating the system press "SUPER"(Windows Key) + "H"

Any themes that fail to install look at this file for them and run this script base on the name and repo "~/Arch_Install/install-scripts/themepatcher.lst"

theme.patch.sh "Green Lush" "https://github.com/abenezerw/Green-Lush"

Hit "Windows" + "h" for keybinds pressing enter will execute them

To get the rofi styling activated "CTRL" + "Windows" + "R" and then just press enter to select the default style

If you want pwa apps just install the plugin in extensions in firefox the package should be already installed
after go to the configuration of the extension and click update web apps option
```

NOTE: The recommended login manager will be sddm for cool configuration.
NOTE: Sway configuration is basic as I don't really use Sway but still a great
      starting point for those that need one
