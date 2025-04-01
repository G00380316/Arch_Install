# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc. Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# If you come from bash you might have to change your $PATH.
#export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH

ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
[ ! -d $ZINIT_HOME ] && mkdir -p "$(dirname $ZINIT_HOME)"
[ ! -d $ZINIT_HOME/.git ] && git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
source "${ZINIT_HOME}/zinit.zsh"


# Add in Powerlevel10k
zinit ice depth=1; zinit light romkatv/powerlevel10k

# Path to your Oh My Zsh installation.
#export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time Oh My Zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
#ZSH_THEME="powerlevel10k/powerlevel10k"

# type p10k configure to open up wizard again
plugins=(
    git
    fzf
    archlinux
    zsh-autosuggestions
    zsh-syntax-highlighting
)
zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-autosuggestions
zinit light Aloxaf/fzf-tab

#source $ZSH/oh-my-zsh.sh

# User configuration


# Terminal Styling
# cat .nf 2> /dev/null
# setsid neofetch >| ~/.nf
# Display Pokemon-colorscripts
# Project page: https://gitlab.com/phoneybadger/pokemon-colorscripts#on-other-distros-and-macos
# pokemon-colorscripts --no-title -s -r #without fastfetch
pokemon-colorscripts --no-title -s -r | fastfetch -c $HOME/.config/fastfetch/config-pokemon.jsonc --logo-type file-raw --logo-height 10 --logo-width 5 --logo -

# fastfetch. Will be disabled if above colorscript was chosen to install
# fastfetch -c $HOME/.config/fastfetch/config-compact.jsonc
# fastfetch.sh

# History
HISTSIZE=10000
HISTFILE=~/.zsh_history
SAVEHIST=$HISTSIZE
HISTDUP=erase
setopt appendhistory
setopt sharehistory
setopt hist_ignore_space #ignores a command if there is a space before it
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_ignore_dups
setopt hist_find_no_dups
setopt correct

### Custom aliases and Keybinds ###
alias ls='lsd --color=auto'
alias q='exit'
alias qa='exit'
alias l='ls -l'
alias la='ls -a'
alias lla='ls -la'
alias lt='ls --tree'
alias q='exit'
alias e='exec zsh'
alias rs='reboot'
alias k='pkill'
alias search='rg'
alias n='nvim'
alias ni='nvim $(fzf --preview="bat --color=always {}")'
alias ss='shutdown -h now'
alias vp='zathura'
alias vi='feh'
alias yt='yt-dlp'
alias calc='bc'
alias f='find . \( -type f -o -type d \) -name ".*" -o \( -type f -o -type d \) | sed "s|^\./||" | fzf'
alias fp='fzf --preview="bat --color=always {}"'
alias vim='nvim'
alias c='clear'
alias tl='tmux attach-session -t "$(tmux ls | tail -n1 | cut -d: -f1)"'
alias t='tmux'
alias s='source'
alias lg='lazygit'
alias doc='~/.config/scripts/cht.sh'
alias i='~/.config/scripts/cht.sh'
alias urar='unrar x'
alias rar='rar a'
alias gz='gunzip'
alias bz2='bunzip2'
alias tr='tar -xvf'
alias trgz='tar -xzvf'
alias trbz2='tar -xjvf'
alias trxz='tar -xJvf'
alias uxz='unxz'
alias uzip='unzip'
alias gnome-disks='xhost +SI:localuser:root
sudo gnome-disks
'

# Add in snippets
zinit snippet OMZP::git
zinit snippet OMZP::sudo
zinit snippet OMZP::archlinux
zinit snippet OMZP::aws
zinit snippet OMZP::kubectl
zinit snippet OMZP::kubectx
zinit snippet OMZP::command-not-found

# Use fzf for history search
bindkey '^R' fzf-history-widget
bindkey '^E' fzf-file-widget
bindkey '^p' history-search-backward
bindkey '^n' history-search-forward
bindkey -e

### Useful functions ###
#
# Add color support for ls and other commands
if [ -x /usr/bin/dircolors ]; then
    eval "$(dircolors -b ~/.dircolors)"
    # alias ls='ls --color=auto'
    alias grep='grep --color=auto'
fi

# Preferred editor for local and remote sessions
 if [[ -n $SSH_CONNECTION ]]; then
   export EDITOR='vim'
 else
   export EDITOR='nvim'
 fi

mkcd() { mkdir -p "$1" && cd "$1"; }
extract() {
    if [ -f $1 ]; then
        case $1 in
            *.tar.bz2) tar xvjf "$1" ;;
            *.tar.gz) tar xvzf "$1" ;;
            *.zip) unzip "$1" ;;
            *) echo "Unsupported file type: $1" ;;
        esac
    else
        echo "$1 not found!"
    fi
}

### Terminal Styling ###
#
# Set terminal title
precmd() {
  if [[ -n "$NVIM" ]]; then
    # In Neovim
    echo -ne "\033]0;Neovim: ${PWD##*/}\007"
  elif [[ "$TERM" =~ screen* ]]; then
    # In tmux or screen
    echo -ne "\033k${HOST%%.*}: ${PWD##*/}\033\\"
  else
    # Default behavior for normal terminal
    echo -ne "\033]0;${HOST%%.*}: ${PWD##*/}\007"
  fi
}

# Completion styling
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'ls --color $realpath'

# Oh My Posh Terminal Styling
# eval "$(oh-my-posh init zsh --config ~/.poshthemes/tokyonight_storm.omp.json)"

### Coding Languages Setup ###
#
# Pyenv configuration
export PATH="$HOME/.pyenv/bin:$PATH"
eval "$(pyenv init --path)"
eval "$(pyenv init -)"

# NVM configuration
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# Go and Cargo
export PATH=$PATH:/usr/local/go/bin
source "$HOME/.cargo/env"

### Tools ###
#
# FZF Configuration

# Define the fzf installation path
FZF_HOME="${HOME}/.fzf"

# Check if fzf is installed; if not, clone and install it
if [ ! -d "$FZF_HOME" ]; then
  echo "fzf not found. Installing fzf..."
  git clone --depth 1 https://github.com/junegunn/fzf.git "$FZF_HOME"
  "$FZF_HOME/install" --all
fi

# Source fzf key bindings and fuzzy completion if it exists
#[ -f "$FZF_HOME/fzf.zsh" ] && source "$FZF_HOME/fzf.zsh"

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh


# Enable fzf tab completion
# export FZF_TMUX=0  # Optional: disable tmux integration if you don't use it
export FZF_COMPLETION_TRIGGER='**'
export FZF_DEFAULT_OPTS='--height 40% --reverse --border'
export FZF_DEFAULT_COMMAND='fd --type f'  # Example using fd for fuzzy search

# Zoxide Setup
eval "$(zoxide init --cmd cd zsh)"

# Rust Waybar module
export PATH="$HOME/.config/waybar/waybar-module-pomodoro/target/release:$PATH"
export PATH="$HOME/.config/waybar/waybar-module-pomodoro/target/debug:$PATH"

# SideLoader
export PATH="/home/enoch/Documents/Applications/Sideloader/Working Binaries:$PATH"
alias sideloader='sideloader-cli-x86_64-linux-gnu'
export PATH="/home/enoch/.config/waybar/scripts:$PATH"
alias blueman="rofi-bluetooth"

# Flutter
export PATH="$PATH:/opt/flutter/bin"
export PATH=$PATH:/sbin
export CHROME_EXECUTABLE=$(which google-chrome-stable)
export ANDROID_SDK_ROOT="/opt/android-sdk"
export PATH="$PATH:$ANDROID_SDK_ROOT/cmdline-tools/bin"
export PATH=$ANDROID_HOME/tools:$ANDROID_HOME/platform-tools:$PATH

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

## [Completion]
## Completion scripts setup. Remove the following line to uninstall
[[ -f /home/enoch/.dart-cli-completion/zsh-config.zsh ]] && . /home/enoch/.dart-cli-completion/zsh-config.zsh || true
## [/Completion]
export PATH="$HOME/.dotnet/tools:$PATH"

PATH=~/.console-ninja/.bin:$PATH
