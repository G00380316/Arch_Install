<p align="center"><br><br>
  <img width="100" src="https://raw.githubusercontent.com/prasanthrangan/hyprdots/main/Source/assets/hyde.png">
</p><br>

# 🚧 This Wiki is outdated. 🚧
## Theme Structure

To create/add new theme (for ex. `Synth-Wave`), here are the files required to theme the base [applications](#theming-applications)   

<br>

> [!IMPORTANT]
> The theme name `Synth-Wave` should be consistent for all config file name
> 
> ```shell
> ~
> |⟼ /.config/
> |    |
> |    |⟼ hypr/themes/
> |    |       ⮡ Synth-Wave.conf
> |    |
> |    |⟼ kitty/themes/
> |    |       ⮡ Synth-Wave.conf
> |    |
> |    |⟼ Kvantum/Synth-Wave/
> |    |       ⮡ Synth-Wave.kvconfig
> |    |       ⮡ Synth-Wave.svg
> |    |
> |    |⟼ qt5ct/colors/
> |    |       ⮡ Synth-Wave.conf
> |    |
> |    |⟼ qt6ct/colors/
> |    |       ⮡ Synth-Wave.conf
> |    |
> |    |⟼ rofi/themes/
> |    |       ⮡ Synth-Wave.rasi
> |    |
> |    |⟼ swww/
> |    |       ⮡ Synth-Wave/*               # place wallpapers here
> |    |
> |    |⟼ waybar/themes/
> |            ⮡ Synth-Wave.css
> | 
> |⟼ /.icons/
> |       ⮡ <icon-pack>/                    # for icons
> |       ⮡ <cursor-pack>/                  # for cursors
> | 
> |⟼ /.themes/
>         ⮡ Synth-Wave/                     # main theme for GTK apps
> ```

<br><br>


## Theming Applications

<div align = center><br>

&ensp;[<kbd> <br> Gtk Apps <br> </kbd>](#gtk-apps)&ensp;
&ensp;[<kbd> <br> Qt Apps <br> </kbd>](#qt-apps)&ensp;
&ensp;[<kbd> <br> Flatpak <br> </kbd>](#flatpaks)&ensp;
&ensp;[<kbd> <br> Hypr <br> </kbd>](#hypr)&ensp;
&ensp;[<kbd> <br> Kitty <br> </kbd>](#kitty)&ensp;
&ensp;[<kbd> <br> Rofi <br> </kbd>](#rofi)&ensp;
&ensp;[<kbd> <br> Walls <br> </kbd>](#wallpapers)&ensp;
&ensp;[<kbd> <br> Waybar <br> </kbd>](#waybar)&ensp;
&ensp;[<kbd> <br> Wlogout <br> </kbd>](#wlogout)&ensp;
<br><br><br></div>

> [!TIP]
> Please keep the color palette for your theme consistent across all the config files

<br>

### GTK apps
```shell
# target files
~/.themes/Synth-Wave/
```

Most applications like firefox follows GTK system theme.   
Download GTK3/4 theme pack and extract it to `~/.themes/`.   
Themes are available in https://www.gnome-look.org/browse?cat=135&ord=rating.   
You can also make your own gtk theme if you have time!   

<br>

### QT apps
```shell
# target files
~/.config/Kvantum/Synth-Wave/Synth-Wave.kvconfig
~/.config/Kvantum/Synth-Wave/Synth-Wave.svg
~/.config/qt5ct/colors/Synth-Wave.conf
~/.config/qt6ct/colors/Synth-Wave.conf
```

Theming for QT applications are handled by kvantum, qt5ct and qt6ct   
- for kvantum,   
    - refer [this](https://github.com/prasanthrangan/hyprdots-mod/blob/Synth-Wave/Configs/.config/Kvantum/Synth-Wave/Synth-Wave.kvconfig) file and modify the color codes as required   
    - refer [this](https://github.com/prasanthrangan/hyprdots-mod/blob/Synth-Wave/Configs/.config/Kvantum/Synth-Wave/Synth-Wave.svg) file and modify the color codes as required using a vector tool like inkscape   
- for qt5 apps the colors and kvantum theme is applied by qt5ct,   
    - refer [this](https://github.com/prasanthrangan/hyprdots-mod/blob/Synth-Wave/Configs/.config/qt5ct/colors/Synth-Wave.conf) file and modify the color codes as required   
- for qt6 apps the colors and kvantum theme is applied by qt6ct,   
    - just copy the qt5ct config file for your theme to qt6ct/colors    

<br>

### Flatpaks
```shell
# target files
~/.themes/Synth-Wave/
```

Flatpaks GTK apps automatically follows the GTK3/4 system theme, so no configuration is required.   

> [!NOTE]
> Flatpak QT apps currently does not support theming

<br>

### Hypr
```shell
# target files
~/.themes/Synth-Wave/
~/.icons/<icon-pack-name>
~/.icons/<cursor-pack-name>
~/.config/hypr/themes/Synth-Wave.conf
```

Refer [this](https://github.com/prasanthrangan/hyprdots-mod/blob/Synth-Wave/Configs/.config/hypr/themes/Synth-Wave.conf) file and set the following in `~/.config/hypr/themes/Synth-Wave.conf`   
- set gtk theme as `exec = gsettings set org.gnome.desktop.interface icon-theme 'Synth-Wave'`   
- set icons as `exec = gsettings set org.gnome.desktop.interface icon-theme '<icon-pack-name>'`   
- set cursor as `exec = gsettings set org.gnome.desktop.interface cursor-theme '<cursor-pack-name>'`   
- modify the window properties like gaps, border colors, shadows, rounding, blur etc.   

<br>

### Kitty
```shell
# target files
~/.config/kitty/themes/Synth-Wave.conf
```

refer [this](https://github.com/prasanthrangan/hyprdots-mod/blob/Synth-Wave/Configs/.config/kitty/themes/Synth-Wave.conf) file and modify the color codes as required   

<br>

### Rofi
```shell
# target files
~/.config/kitty/themes/Synth-Wave.conf
```

refer [this](https://github.com/prasanthrangan/hyprdots-mod/blob/Synth-Wave/Configs/.config/rofi/themes/Synth-Wave.rasi) file and modify the color codes as required   

<br>

### Wallpapers
```shell
# target files
~/.config/swww/Synth-Wave/
```

Place all wallpapers that fits the theme in `~/.config/swww/Synth-Wave/*` directory   
Currently `*.gif`, `*.jpg`, `*.jpeg`, `*.png` image formats are supported   

<br>

### Waybar
```shell
# target files
~/.config/waybar/themes/Synth-Wave.css
```

refer [this](https://github.com/prasanthrangan/hyprdots-mod/blob/Synth-Wave/Configs/.config/waybar/themes/Synth-Wave.css) file and modify the color codes as required   

<br>

### Wlogout
```shell
# target files
~/.config/waybar/themes/Synth-Wave.css
```

For wlogout, it imports the same colors from waybar, so no configuration is required   

<br>


## Activating Theme
Once you have the config files in place for all the [applications](#theming-applications), add an entry to [theme](https://github.com/prasanthrangan/hyprdots/blob/main/Configs/.config/hypr/theme.ctl) control file as below,   
```
0|Synth-Wave|robbowen.synthwave-vscode~SynthWave '84|~/.config/swww/Synth-Wave/beach.jpg
```
here the `theme.ctl` file is a `|` delimited file where column   
- <kbd>1</kbd> indicates current theme in use   
- <kbd>2</kbd> is the theme name   
- <kbd>3</kbd> is vscode extension name and theme in `<extension name>~<theme name>` format   
- <kbd>4</kbd> is the `/path/to/theme/wallpaper`   

The theme switcher ( <kbd>super</kbd> + <kbd>shift</kbd> + <kbd>T</kbd> ) should now show your new theme in the menu, just select it to apply!

<br><br>


## Theme Patcher

Once you have the config files for all the [applications](#theming-applications) ready, you can either place them in a local directory or maintain it in a git repo.   

<br>

https://github.com/prasanthrangan/hyprdots-mod/assets/106020512/0c7f12a8-11f2-4a16-890e-44f07a860636

<br>

### Local Structure

Create a local directory for example `$HOME/Patch` and structure it as below   

<p align="center">
<img align="center" src="https://github.com/prasanthrangan/hyprdots/assets/106020512/ce450966-7f35-4489-a42b-f2f1f44a19da"/>
</p><br>

Execute themepatcher as below to patch it from local directory: 
```
cd ~/HyDE/Scripts # HyDE clone directory
./themepatcher.sh "Synth-Wave" "$HOME/Patch/Synth-Wave" "robbowen.synthwave-vscode~SynthWave '84"
```

### Git Structure

you can follow this [repo](https://github.com/prasanthrangan/hyprdots-mod) structure or fork it

<p align="center">
<img align="center" width="300" src="https://github.com/prasanthrangan/hyprdots/assets/106020512/6bed8330-14c5-4601-9763-3683ae551b2a" />
&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;
<img align="center" width="300" src="https://github.com/prasanthrangan/hyprdots/assets/106020512/57f8d670-f508-4a9c-be19-86d5abdf82a2" />
</p><br>

Execute themepatcher as below to patch it from git repo: 
```
cd ~/HyDE/Scripts # HyDE clone directory
./themepatcher.sh "Synth-Wave" "https://github.com/prasanthrangan/hyprdots-mod/tree/Synth-Wave" "robbowen.synthwave-vscode~SynthWave '84"
```
