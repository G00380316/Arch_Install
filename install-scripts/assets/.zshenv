function command_not_found_handler {
    local purple='\e[1;35m' bright='\e[0;1m' green='\e[1;32m' reset='\e[0m'
    printf "${green}zsh${reset}: command ${purple}NOT${reset} found: ${bright}'%s'${reset}\n" "$1"

    PM="pm.sh"

    # Check if pm.sh is in PATH
    if ! command -v "$PM" &>/dev/null; then
        # Check common locations
        if [[ -x "$HOME/.config/scripts/pm.sh" ]]; then
            PM="$HOME/.config/scripts/pm.sh"
        else
            unset PM
        fi
    fi

    if ! command -v "${PM}" &>/dev/null; then
        printf "${bright}${red}We cannot find package manager script (${purple}pm.sh${red}) from ${green}HyDE${reset}\n"
        return 127
    fi

    if ! "${PM}" fq "/usr/bin/$1"; then
        printf "${bright}${green}[ ${1} ]${reset} ${purple}NOT${reset} found in the system and no package provides it.\n"
        return 127
    else
        printf "${green}[ ${1} ] ${reset} might be provided by the above packages.\n"
        for entry in $entries; do
            # Assuming the entry already has ANSI color codes, we don't add more colors
            printf "  %s\n" "${entry}"
        done

    fi
    return 127
}

# Function to display a slow load warning
function slow_load_warning {
    local lock_file="/tmp/.hyde_slow_load_warning.lock"
    local load_time=$SECONDS

    # Check if the lock file exists
    if [[ ! -f $lock_file ]]; then
        # Create the lock file
        touch $lock_file

        # Display the warning if load time exceeds the limit
        time_limit=3
        if ((load_time > time_limit)); then
            cat <<EOF
    ⚠️ Warning: Shell startup took more than ${time_limit} seconds. Consider optimizing your configuration.
        1. This might be due to slow plugins, slow initialization scripts.
        2. Duplicate plugins initialization.
            - navigate to ~/.zshrc and remove any 'source ZSH/oh-my-zsh.sh' or
                'source ~/.oh-my-zsh/oh-my-zsh.sh' lines.
            - HyDE already sources the oh-my-zsh.sh file for you.
            - It is important to remove all HyDE related
                configurations from your .zshrc file as HyDE will handle it for you.
            - Check the '.zshrc' file from the repo for a clean configuration.
        4. Check the '~/.p10k.zsh' file for any slow initialization scripts.
EOF
        fi
    fi
}

# best fzf aliases ever
_fuzzy_change_directory() {
    local initial_query="$1"
    local selected_dir
    local fzf_options=('--preview=ls -p {}' '--preview-window=right:60%')
    fzf_options+=(--height "80%" --layout=reverse --preview-window right:60% --cycle)
    local max_depth=7

    if [[ -n "$initial_query" ]]; then
        fzf_options+=("--query=$initial_query")
    fi

    #type -d
    selected_dir=$(find . -maxdepth $max_depth \( -name .git -o -name node_modules -o -name .venv -o -name target -o -name .cache \) -prune -o -type d -print 2>/dev/null | fzf "${fzf_options[@]}")

    if [[ -n "$selected_dir" && -d "$selected_dir" ]]; then
        cd "$selected_dir" || return 1
    else
        return 1
    fi
}

_fuzzy_edit_search_file_content() {
    # [f]uzzy [e]dit  [s]earch [f]ile [c]ontent
    local selected_file
    selected_file=$(grep -irl "${1:-}" ./ | fzf --height "80%" --layout=reverse --preview-window right:60% --cycle --preview 'cat {}' --preview-window right:60%)

    if [[ -n "$selected_file" ]]; then
        if command -v "$EDITOR" &>/dev/null; then
            "$EDITOR" "$selected_file"
        else
            echo "EDITOR is not specified. using vim.  (you can export EDITOR in ~/.zshrc)"
            vim "$selected_file"
        fi

    else
        echo "No file selected or search returned no results."
    fi
}

_fuzzy_edit_search_file() {
    local initial_query="$1"
    local selected_file
    local fzf_options=()
    fzf_options+=(--height "80%" --layout=reverse --preview-window right:60% --cycle)
    local max_depth=5

    if [[ -n "$initial_query" ]]; then
        fzf_options+=("--query=$initial_query")
    fi

    # -type f: only find files
    selected_file=$(find . -maxdepth $max_depth -type f 2>/dev/null | fzf "${fzf_options[@]}")

    if [[ -n "$selected_file" && -f "$selected_file" ]]; then
        if command -v "$EDITOR" &>/dev/null; then
            "$EDITOR" "$selected_file"
        else
            echo "EDITOR is not specified. using vim.  (you can export EDITOR in ~/.zshrc)"
            vim "$selected_file"
        fi
    else
        return 1
    fi
}

_df() {
    if [[ $# -ge 1 && -e "${@: -1}" ]]; then
        duf "${@: -1}"
    else
        duf
    fi
}

# Function to handle initialization errors
function handle_init_error {
    if [[ $? -ne 0 ]]; then
        echo "Error during initialization. Please check your configuration."
    fi
}

# Function to remove the lock file on exit
function cleanup {
    rm -f /tmp/.hyde_slow_load_warning.lock
}

function no_such_file_or_directory_handler {
    local red='\e[1;31m' reset='\e[0m'
    printf "${red}zsh: no such file or directory: %s${reset}\n" "$1"
    return 127
}

# cleaning up home folder
XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.config/scripts/Hyde_Inject/share}"
XDG_DATA_DIRS="${XDG_DATA_DIRS:-$XDG_DATA_HOME:/usr/local/share:/usr/share}"
XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.config/scripts/Hyde_Inject/state}"
XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
XDG_DESKTOP_DIR="${XDG_DESKTOP_DIR:-$HOME/Desktop}"
XDG_DOWNLOAD_DIR="${XDG_DOWNLOAD_DIR:-$HOME/Downloads}"
XDG_TEMPLATES_DIR="${XDG_TEMPLATES_DIR:-$HOME/Templates}"
XDG_PUBLICSHARE_DIR="${XDG_PUBLICSHARE_DIR:-$HOME/Public}"
XDG_DOCUMENTS_DIR="${XDG_DOCUMENTS_DIR:-$HOME/Documents}"
XDG_MUSIC_DIR="${XDG_MUSIC_DIR:-$HOME/Music}"
XDG_PICTURES_DIR="${XDG_PICTURES_DIR:-$HOME/Pictures}"
XDG_VIDEOS_DIR="${XDG_VIDEOS_DIR:-$HOME/Videos}"
LESSHISTFILE=${LESSHISTFILE:-/tmp/less-hist}
PARALLEL_HOME="$XDG_CONFIG_HOME/parallel"
SCREENRC="$XDG_CONFIG_HOME"/screen/screenrc

export XDG_CONFIG_HOME XDG_DATA_HOME XDG_STATE_HOME XDG_CACHE_HOME XDG_DESKTOP_DIR XDG_DOWNLOAD_DIR \
    XDG_TEMPLATES_DIR XDG_PUBLICSHARE_DIR XDG_DOCUMENTS_DIR XDG_MUSIC_DIR XDG_PICTURES_DIR XDG_VIDEOS_DIR SCREENRC
export PATH="$HOME/.config/waybar/waybar-module-pomodoro/target/release:$PATH"
export PATH="$HOME/.config/waybar/waybar-module-pomodoro/target/debug:$PATH"
export PATH="$HOME/.config/waybar/scripts:$PATH"
export PATH="$HOME/Documents/Applications/Sideloader/Working Binaries:$PATH"
export PATH="$HOME/.config/scripts:$PATH"
export GTK_THEME=Adwaita:dark
export QT_QPA_PLATFORM=wayland
export QT_QPA_PLATFORM=xcb

if [ -t 1 ]; then
    # We are loading the prompt on start so users can see the prompt immediately
    # Powerlevel10k theme path
    P10k_THEME=${P10k_THEME:-/usr/share/zsh-theme-powerlevel10k/powerlevel10k.zsh-theme}
    [[ -r $P10k_THEME ]] && source $P10k_THEME

    # To customize prompt, run `p10k configure` or edit ~/.p10k.zsh
    [[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

    PM="pm.sh"
    # Check if pm.sh is in PATH
    if ! command -v "$PM" &>/dev/null; then
        # Check common locations
        if [[ -x "$HOME/.config/scripts/pm.sh" ]]; then
            PM="$HOME/.config/scripts/pm.sh"
        else
            unset PM
        fi
    fi

    # Helpful aliases
    alias c='clear' \
        in='$PM install' \
        un='$PM remove' \
        up='$PM upgrade' \
        pl='$PM search installed' \
        pa='$PM search all' \
        vc='code' \
        fastfetch='fastfetch --logo-type kitty' \
        ..='cd ..' \
        ...='cd ../..' \
        .3='cd ../../..' \
        .4='cd ../../../..' \
        .5='cd ../../../../..' \
        mkdir='mkdir -p'\
        ffec='_fuzzy_edit_search_file_content' \
        ffcd='_fuzzy_change_directory' \
        ffe='_fuzzy_edit_search_file' \
        df='_df'
    # TODO: add handlers in pm.sh
    # for these aliases please manually add the following lines to your .zshrc file.(Using yay as the aur helper)
    # pc='yay -Sc' # remove all cached packages
    # po='yay -Qtdq | $PM -Rns -' # remove orphaned packages

    # Warn if the shell is slow to load
    autoload -Uz add-zsh-hook
    add-zsh-hook -Uz precmd slow_load_warning
    # add-zsh-hook zshexit cleanup
fi
