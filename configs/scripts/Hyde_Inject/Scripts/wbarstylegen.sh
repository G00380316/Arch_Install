#!/usr/bin/env bash

template_file="$HOME/.config/waybar/ModulesHyde.template"
output_file="$HOME/.config/waybar/ModulesHyde"
theme_file="$HOME/.config/hypr/themes/wallbash.conf"

# Initialize empty variables
i_theme=""
font_name=""

# Read wallbash.conf manually
while IFS='=' read -r key value; do
    # Skip empty lines or comments
    [[ -z "$key" || "$key" == \#* ]] && continue

    # Remove leading $ from key
    key="${key#\$}"

    # Trim whitespace and quotes from value
    value="${value//\"/}"       # Remove quotes
    value="$(echo "$value" | xargs)"  # Trim

    case "$key" in
        ICON_THEME) i_theme="$value" ;;
        FONT)       font_name="$value" ;;
    esac
done < "$theme_file"

# Export for envsubst
export i_theme font_name

# Debug
echo "Icon Theme: $i_theme"
echo "Font Name: $font_name"

if [[ "$1" == "--restore" ]]; then
    echo "Restoring original template to $output_file"
    cp "$template_file" "$output_file"
    exit 0
fi

cp "$template_file" "$output_file"

# Replace in Waybar CSS
envsubst '$font_name' < ~/.config/waybar/style/Hyde.css > ~/.config/waybar/style.css.tmp &&
    mv ~/.config/waybar/style.css.tmp ~/.config/waybar/style.css

envsubst '${i_theme}' < ~/.config/waybar/ModulesHyde > ~/.config/waybar/ModulesHyde.tmp &&
    mv ~/.config/waybar/ModulesHyde.tmp ~/.config/waybar/ModulesHyde