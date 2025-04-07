# Powerlevel10k Instant Prompt
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Init completion
autoload -Uz compinit && compinit -u
zstyle ':completion:*' file-patterns '*(.)' '.*(.)'
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"

# Improve completion reliability
fpath+=($HOME/.zfunc)

# Zinit Setup (unchanged)
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
# Remove once installed (next two lines)
[ ! -d $ZINIT_HOME ] && mkdir -p "$(dirname $ZINIT_HOME)"
[ ! -d $ZINIT_HOME/.git ] && git clone --depth=1 https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
source "$ZINIT_HOME/zinit.zsh"

# Plugins with Turbo Mode
zinit ice wait lucid
zinit light romkatv/powerlevel10k
[[ -f $HOME/.p10k.zsh ]] && source $HOME/.p10k.zsh

zinit ice wait lucid
zinit light zsh-users/zsh-completions

zinit ice wait lucid
zinit light zsh-users/zsh-autosuggestions

zinit ice wait lucid
zinit light zsh-users/zsh-syntax-highlighting

zinit ice wait lucid
zinit light Aloxaf/fzf-tab

# OMZ Plugin Snippets with Turbo Mode
zinit ice wait lucid
zinit snippet OMZP::git
zinit snippet OMZP::sudo
zinit snippet OMZP::archlinux
zinit snippet OMZP::command-not-found

# Zoxide with Turbo Mode
zinit ice wait lucid
zinit light ajeetdsouza/zoxide
eval "$(zoxide init zsh --cmd cd)"

# History
HISTSIZE=10000
HISTFILE=$HOME/.zsh_history
SAVEHIST=$HISTSIZE
setopt appendhistory sharehistory
setopt hist_ignore_all_dups hist_ignore_dups hist_ignore_space hist_save_no_dups hist_find_no_dups
setopt correct

# FZF
FZF_HOME="$HOME/.fzf"
[ ! -d "$FZF_HOME" ] && git clone --depth 1 https://github.com/junegunn/fzf.git "$FZF_HOME" && "$FZF_HOME/install" --all
[ -f $HOME/.fzf.zsh ] && source $HOME/.fzf.zsh
export FZF_COMPLETION_TRIGGER='**'
export FZF_DEFAULT_OPTS='--height 40% --reverse --border'
export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'

# Bindkeys
bindkey '^R' fzf-history-widget
bindkey '^E' fzf-file-widget
bindkey '^p' history-search-backward
bindkey '^n' history-search-forward
bindkey -e

# Zoxide
zinit light ajeetdsouza/zoxide
eval "$(zoxide init zsh --cmd cd)"

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

# Aliases
alias ls='lsd --color=auto'
alias l='ls -l'
alias la='ls -a'
alias lla='ls -la'
alias lt='ls --tree'
alias c='clear'
alias q='exit'
alias qa='exit'
alias e='exec zsh'
alias rs='reboot'
alias ss='shutdown -h now'
alias vp='zathura'
alias vi='feh'
alias yt='yt-dlp'
alias calc='bc'
alias n='nvim'
alias ni='nvim $(fzf --preview="bat --color=always {}")'
alias t='tmux'
alias tl='tmux attach-session -t "$(tmux ls | tail -n1 | cut -d: -f1)"'
alias lg='lazygit'
alias doc="$HOME/.config/scripts/cht.sh"
alias i="$HOME/.config/scripts/cht.sh"
alias search='rg'
alias sideloader='sideloader-cli-x86_64-linux-gnu'
alias blueman='rofi-bluetooth'

# Archive utils
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

# Functions
mkcd() { mkdir -p "$1" && cd "$1"; }
extract() {
  case "$1" in
    *.tar.bz2) tar xvjf "$1" ;;
    *.tar.gz)  tar xvzf "$1" ;;
    *.zip)     unzip "$1" ;;
    *)         echo "Unsupported file: $1" ;;
  esac
}

# Terminal title
precmd() {
  [[ -n "$NVIM" ]] && echo -ne "\033]0;Neovim: ${PWD##*/}\007"
  [[ "$TERM" == screen* ]] && echo -ne "\033k${HOST%%.*}: ${PWD##*/}\033\\" || echo -ne "\033]0;${HOST%%.*}: ${PWD##*/}\007"
}

# FZF-tab Completion Styles
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'ls --color $realpath'

# Editor
export EDITOR=nvim
[[ -n $SSH_CONNECTION ]] && export EDITOR=vim

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && source "$NVM_DIR/nvm.sh"

export PATH="$PATH:/usr/local/go/bin:/sbin:/opt/flutter/bin:$HOME/.dotnet/tools:$HOME/.config/waybar/waybar-module-pomodoro/target/release:$HOME/.config/waybar/scripts:$HOME/Documents/Applications/Sideloader/Working Binaries"
source "$HOME/.cargo/env"

# Android
export ANDROID_SDK_ROOT="/opt/android-sdk"
export PATH="$PATH:$ANDROID_SDK_ROOT/cmdline-tools/bin:$ANDROID_SDK_ROOT/tools:$ANDROID_SDK_ROOT/platform-tools"

# Dart completion
[[ -f $HOME/.dart-cli-completion/zsh-config.zsh ]] && source $HOME/.dart-cli-completion/zsh-config.zsh

# Chrome executable
export CHROME_EXECUTABLE=$(which google-chrome-stable)

# Pyenv configuration
export PATH="$HOME/.pyenv/bin:$PATH"
eval "$(pyenv init --path)"
eval "$(pyenv init -)"
export PATH=$PATH:/usr/local/go/bin
export PATH="$HOME/.dotnet/tools:$PATH"

