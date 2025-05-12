# Setup fzf
# ---------
if [[ ! "$PATH" == */home/enoch/.fzf/bin* ]]; then
  PATH="${PATH:+${PATH}:}/home/enoch/.fzf/bin"
fi

source <(fzf --zsh)
