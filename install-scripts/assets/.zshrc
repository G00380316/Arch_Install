# Powerlevel10k Instant Prompt (disabled if causing issues)
typeset -g POWERLEVEL9K_INSTANT_PROMPT=off

# Zinit Setup
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
[ ! -d $ZINIT_HOME ] && mkdir -p "$(dirname $ZINIT_HOME)"
[ ! -d $ZINIT_HOME/.git ] && git clone --depth=1 https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
source "$ZINIT_HOME/zinit.zsh"

# Init completion
autoload -Uz compinit && compinit -u

# Improve completion reliability
fpath+=($HOME/.zfunc)

# Plugins with Turbo Mode
zinit ice lucid
zinit light romkatv/powerlevel10k
[[ -f $HOME/.p10k.zsh ]] && source $HOME/.p10k.zsh

#zinit ice wait lucid
#zinit light zsh-users/zsh-completions

zinit ice wait lucid
zinit light zsh-users/zsh-autosuggestions

zinit ice wait lucid
zinit light zsh-users/zsh-syntax-highlighting

zinit ice wait lucid
zinit light Aloxaf/fzf-tab

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
bindkey '^I' fzf-file-widget # Hit TAB twice to activate
bindkey -e

# FZF-tab Completion Styles
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'ls --color $realpath'

# Terminal Styling
# cat .nf 2> /dev/null
# setsid neofetch >| ~/.nf
#
# Display Pokemon-colorscripts
# Project page: https://gitlab.com/phoneybadger/pokemon-colorscripts#on-other-distros-and-macos
# pokemon-colorscripts --no-title -s -r #without fastfetch
# pokemon-colorscripts --no-title -s -r | fastfetch -c $HOME/.config/fastfetch/config-pokemon.jsonc --logo-type file-raw --logo-height 10 --logo-width 5 --logo -
#
fastfetch -c $HOME/.config/fastfetch/config-compact.jsonc
# fastfetch. Will be disabled if above colorscript was chosen to install
# fastfetch -c $HOME/.config/fastfetch/config-compact.jsonc
# fastfetch --logo "$HYDE_CACHE_HOME/wall.quad" --logo-type kitty

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

# Editor
export EDITOR=nvim
[[ -n $SSH_CONNECTION ]] && export EDITOR=vim

# Default Exports #
export PATH=$PATH:~/.config/hypr/scripts
###
