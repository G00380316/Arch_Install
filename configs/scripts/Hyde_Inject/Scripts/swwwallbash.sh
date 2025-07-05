#!/usr/bin/env bash
# shellcheck disable=SC2154

#// set variables

scrDir="$(dirname "$(realpath "$0")")"
export scrDir
# shellcheck disable=SC1091
source "${scrDir}/globalcontrol.sh"
wallbashImg="${1}"

# Parse arguments
dcol_colors=""
while [[ $# -gt 0 ]]; do
    case "$1" in
    --dcol)
        dcol_colors="$2"
        if [ -f "${dcol_colors}" ]; then
            echo "[Source] ${dcol_colors}"
            # shellcheck disable=SC1090
            source "${dcol_colors}"
            shift 2
        else
            dcol_colors="$(find "${dcolDir}" -type f -name "*.dcol" | shuf -n 1)"
            echo "[Dcol Colors] ${dcol_colors}"
            shift
        fi
        ;;
    --wall)
        wallbashImg="$2"
        shift 2
        ;;
    --single)
        [ -f "${wallbashImg}" ] || wallbashImg="${cacheDir}/wall.set"
        single_template="$2"
        echo "[wallbash] Single template: ${single_template}"
        echo "[wallbash] Wallpaper: ${wallbashImg}"
        shift 2
        #     ;;
        # --mode)
        #     enableWallDcol="$2"
        #     shift 2
        ;;
    -*)
        echo "Usage: $0 [--dcol <mode>] [--wall <image>] [--single] [--mode <mode>] [--help]"
        exit 0
        ;;
    *) break ;;
    esac
done

#// validate input

if [ -z "${wallbashImg}" ] || [ ! -f "${wallbashImg}" ]; then
    echo "Error: Input wallpaper not found!"
    exit 1
fi
# shellcheck disable=SC2154
wallbashOut="${dcolDir}/$(set_hash "${wallbashImg}").dcol"

if [ ! -f "${wallbashOut}" ]; then
    "${scrDir}/swwwallcache.sh" -w "${wallbashImg}" &>/dev/null
fi

set -a
# shellcheck disable=SC1090
source "${wallbashOut}"
# shellcheck disable=SC2154
if [ -f "${HYDE_THEME_DIR}/theme.dcol" ] && [ "${enableWallDcol}" -eq 0 ]; then
    # shellcheck disable=SC1091
    source "${HYDE_THEME_DIR}/theme.dcol"
    print_log -sec "wallbash" -stat "override" "dominant colors from ${HYDE_THEME} theme"
    print_log -sec "wallbash" -stat " NOTE" "Remove \"${HYDE_THEME_DIR}/theme.dcol\" to use wallpaper dominant colors"
fi
# shellcheck disable=SC2154
[ "${dcol_mode}" == "dark" ] && dcol_invt="light" || dcol_invt="dark"
set +a

if [ -z "$gtkTheme" ]; then
    if [ "${enableWallDcol}" -eq 0 ]; then
        gtkTheme="$(get_hyprConf "GTK_THEME")"
    else
        gtkTheme="Wallbash-Gtk"
    fi
fi
[ -z "$gtkIcon" ] && gtkIcon="$(get_hyprConf "ICON_THEME")"
[ -z "$cursorTheme" ] && cursorTheme="$(get_hyprConf "CURSOR_THEME")"
export gtkTheme gtkIcon cursorTheme

# --- MERGED: Functions from color.set.sh ---
# Function to dynamically create wallbash substitution strings for sed
create_wallbash_substitutions() {
    local use_inverted=$1
    local sed_script
    sed_script="s|<wallbash_mode>|$(${use_inverted} && printf "%s" "${dcol_invt:-light}" || printf "%s" "${dcol_mode:-dark}")|g;"

    # Add substitutions for all color variables
    for i in {1..4}; do
        # Determine if colors should be reversed for inverted mode
        if ${use_inverted}; then
            src_i=$((5 - i))
        else
            src_i=$i
        fi

        # Get values using indirect reference
        local pry_var="dcol_pry${src_i}"
        local txt_var="dcol_txt${src_i}"
        local pry_rgba_var="dcol_pry${src_i}_rgba"
        local txt_rgba_var="dcol_txt${src_i}_rgba"
        local pry_rgb_var="dcol_pry${src_i}_rgb"
        local txt_rgb_var="dcol_txt${src_i}_rgb"

        # If RGB vars don't exist but RGBA does, create RGB from RGBA
        if [[ -n "${!pry_rgba_var:-}" && -z "${!pry_rgb_var:-}" ]]; then
            declare -g "${pry_rgb_var}=$(sed -E 's/rgba\(([0-9]+,[0-9]+,[0-9]+),.*/\1/' <<<"${!pry_rgba_var}")"
            export "${pry_rgb_var?}"
        fi

        if [[ -n "${!txt_rgba_var:-}" && -z "${!txt_rgb_var:-}" ]]; then
            declare -g "${txt_rgb_var}=$(sed -E 's/rgba\(([0-9]+,[0-9]+,[0-9]+),.*/\1/' <<<"${!txt_rgba_var}")"
            export "${txt_rgb_var?}"
        fi

        # Add to sed script if variables exist
        [ -n "${!pry_var:-}" ] && sed_script+="s|<wallbash_pry${i}>|${!pry_var}|g;"
        [ -n "${!txt_var:-}" ] && sed_script+="s|<wallbash_txt${i}>|${!txt_var}|g;"
        [ -n "${!pry_rgba_var:-}" ] && sed_script+="s|<wallbash_pry${i}_rgba(\([^)]*\))>|${!pry_rgba_var}|g;"
        [ -n "${!txt_rgba_var:-}" ] && sed_script+="s|<wallbash_txt${i}_rgba(\([^)]*\))>|${!txt_rgba_var}|g;"
        [ -n "${!pry_rgb_var:-}" ] && sed_script+="s|<wallbash_pry${i}_rgb>|${!pry_rgb_var}|g;"
        [ -n "${!txt_rgb_var:-}" ] && sed_script+="s|<wallbash_txt${i}_rgb>|${!txt_rgb_var}|g;"

        # Add xa colors with direct variable expansion
        for j in {1..9}; do
            local xa_var="dcol_${src_i}xa${j}"
            local xa_rgba_var="dcol_${src_i}xa${j}_rgba"
            local xa_rgb_var="dcol_${src_i}xa${j}_rgb"

            # Create RGB from RGBA if needed
            if [[ -n "${!xa_rgba_var:-}" && -z "${!xa_rgb_var:-}" ]]; then
                declare -g "${xa_rgb_var}=$(sed -E 's/rgba\(([0-9]+,[0-9]+,[0-9]+),.*/\1/' <<<"${!xa_rgba_var}")"
                export "${xa_rgb_var?}"
            fi

            [ -n "${!xa_var:-}" ] && sed_script+="s|<wallbash_${i}xa${j}>|${!xa_var}|g;"
            [ -n "${!xa_rgba_var:-}" ] && sed_script+="s|<wallbash_${i}xa${j}_rgba(\([^)]*\))>|${!xa_rgba_var}|g;"
            [ -n "${!xa_rgb_var:-}" ] && sed_script+="s|<wallbash_${i}xa${j}_rgb>|${!xa_rgb_var}|g;"
        done
    done

    # Add home directory substitution
    sed_script+="s|<<HOME>>|${HOME}|g"

    printf "%s" "$sed_script"
}

# Preprocess sed scripts for both normal and inverted modes to run only once
preprocess_substitutions() {
    NORMAL_SED_SCRIPT=$(create_wallbash_substitutions false)
    INVERTED_SED_SCRIPT=$(create_wallbash_substitutions true)
    export NORMAL_SED_SCRIPT INVERTED_SED_SCRIPT
}
# --- END MERGED Functions ---

#// deploy wallbash colors

fn_wallbash() {
    local template="${1}"
    local temp_target_file exec_command
    WALLBASH_SCRIPTS="${template%%hyde/wallbash*}hyde/wallbash/scripts"
    if [[ "${template}" == *.theme ]]; then
        IFS=':' read -r -a wallbashDirs <<<"$WALLBASH_DIRS"
        template_name="${template##*/}"
        template_name="${template_name%.*}"
        dcolTemplate=$(find "${wallbashDirs[@]}" -type f -path "*/theme*" -name "${template_name}.dcol" 2>/dev/null | awk '!seen[substr($0, match($0, /[^/]+$/))]++')
        if [[ -n "${dcolTemplate}" ]]; then
            eval target_file="$(head -1 "${dcolTemplate}" | awk -F '|' '{print $1}')"
            exec_command="$(head -1 "${dcolTemplate}" | awk -F '|' '{print $2}')"
            WALLBASH_SCRIPTS="${dcolTemplate%%hyde/wallbash*}hyde/wallbash/scripts"
        fi
    fi

    # shellcheck disable=SC1091
    [ -f "$HYDE_STATE_HOME/state" ] && source "$HYDE_STATE_HOME/state"
    # shellcheck disable=SC1091
    [ -f "$HYDE_STATE_HOME/config" ] && source "$HYDE_STATE_HOME/config"
    if [[ -n "${WALLBASH_SKIP_TEMPLATE[*]}" ]]; then
        for skip in "${WALLBASH_SKIP_TEMPLATE[@]}"; do
            if [[ "${template}" =~ ${skip} ]]; then
                print_log -sec "wallbash" -warn "skip '$skip' template " "Template: ${template}"
                return 0
            fi
        done
    fi

    [ -z "${target_file}" ] && eval target_file="$(head -1 "${template}" | awk -F '|' '{print $1}')"
    [ ! -d "$(dirname "${target_file}")" ] && print_log -sec "wallbash" -warn "skip 'missing directory'" "${target_file} // Do you have the dependency installed?" && return 0
    export wallbashScripts="${WALLBASH_SCRIPTS}"
    export WALLBASH_SCRIPTS confDir hydeConfDir cacheDir thmbDir dcolDir iconsDir themesDir fontsDir wallbashDirs enableWallDcol HYDE_THEME_DIR HYDE_THEME gtkIcon gtkTheme cursorTheme
    export -f pkg_installed print_log
    exec_command="${exec_command:-"$(head -1 "${template}" | awk -F '|' '{print $2}')"}"
    temp_target_file="$(mktemp)"
    sed '1d' "${template}" >"${temp_target_file}"

    # --- MERGED: Replaced the static sed block with a dynamic one ---
    # Check if colors need to be inverted based on global flags
    if [[ "${revert_colors:-0}" -eq 1 ]] || [[ "${enableWallDcol}" -eq 2 && "${dcol_mode}" == "light" ]] || [[ "${enableWallDcol}" -eq 3 && "${dcol_mode}" == "dark" ]]; then
        sed -i "${INVERTED_SED_SCRIPT}" "${temp_target_file}"
    else
        sed -i "${NORMAL_SED_SCRIPT}" "${temp_target_file}"
    fi
    # --- END MERGED Block ---

    if [ -s "${temp_target_file}" ]; then
        mv "${temp_target_file}" "${target_file}"
    fi
    [ -z "${exec_command}" ] || bash -c "${exec_command}"
}

WALLBASH_DIRS=""
for dir in "${wallbashDirs[@]}"; do
    [ -d "${dir}" ] || wallbashDirs=("${wallbashDirs[@]//$dir/}")
    [ -d "$dir" ] && WALLBASH_DIRS+="$dir:"
done
WALLBASH_DIRS="${WALLBASH_DIRS%:}"

if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then PATH="$HOME/.local/bin:${PATH}"; fi
export WALLBASH_DIRS PATH

# --- MERGED: Added function exports and preprocessing call ---
export -f fn_wallbash print_log pkg_installed create_wallbash_substitutions preprocess_substitutions

# Preprocess substitutions once before any templates are processed for efficiency
preprocess_substitutions
print_log -sec "wallbash" -stat "preprocessed" "color substitutions"
# --- END MERGED Block ---

if [ -n "${dcol_colors}" ]; then
    set -a
    # shellcheck disable=SC1090
    source "${dcol_colors}"
    print_log -sec "wallbash" -stat "single instance" "Wallbash Colors: ${dcol_colors}"
    set +a
fi

# Single template mode
if [ -n "${single_template}" ]; then
    fn_wallbash "${single_template}"
    exit 0
fi

# Print to terminal the colors
[ -t 1 ] && "${scrDir}/wallbash.print.colors.sh"

#// switch theme <//> wall based colors

# shellcheck disable=SC2154
if [ "${enableWallDcol}" -eq 0 ] && [[ "${reload_flag}" -eq 1 ]]; then

    print_log -sec "wallbash" -stat "apply ${dcol_mode} colors" "${HYDE_THEME} theme"
    mapfile -d '' -t deployList < <(find "${HYDE_THEME_DIR}" -type f -name "*.theme" -print0)

    while read -r pKey; do
        fKey="$(find "${HYDE_THEME_DIR}" -type f -name "$(basename "${pKey%.dcol}.theme")")"
        [ -z "${fKey}" ] && deployList+=("${pKey}")
    done < <(find "${wallbashDirs[@]}" -type f -path "*/theme*" -name "*.dcol" 2>/dev/null | awk '!seen[substr($0, match($0, /[^/]+$/))]++')

    parallel fn_wallbash ::: "${deployList[@]}"

elif [ "${enableWallDcol}" -gt 0 ]; then
    print_log -sec "wallbash" -stat "apply ${dcol_mode} colors" "Wallbash theme"
    find "${wallbashDirs[@]}" -type f -path "*/theme*" -name "*.dcol" 2>/dev/null | awk '!seen[substr($0, match($0, /[^/]+$/))]++' | parallel fn_wallbash {}
fi

#  Theme mode: detects the color-scheme set in hypr.theme and falls back if nothing is parsed.
revert_colors=0
[ "${enableWallDcol}" -eq 0 ] && { grep -q "${dcol_mode}" <<<"$(get_hyprConf "COLOR_SCHEME")" || revert_colors=1; }
export revert_colors

find "${wallbashDirs[@]}" -type f -path "*/always*" -name "*.dcol" 2>/dev/null | sort | awk '!seen[substr($0, match($0, /[^/]+$/))]++' | parallel fn_wallbash {}

# Add post processing here
toml_write "${confDir}/kdeglobals" "Colors:View" "BackgroundNormal" "#${dcol_pry1:-000000}"

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
envsubst '$font_name' < ~/.config/waybar/style/Hyde.css > ~/.config/waybar/style.css.tmp && mv ~/.config/waybar/style.css.tmp ~/.config/waybar/style.css

envsubst '${i_theme}' < ~/.config/waybar/ModulesHyde > ~/.config/waybar/ModulesHyde.tmp && mv ~/.config/waybar/ModulesHyde.tmp ~/.config/waybar/ModulesHyde

pkill waybar
killall -SIGUSR2 waybar
kill -SIGUSR1 waybar
