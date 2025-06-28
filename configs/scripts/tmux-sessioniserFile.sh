#!/usr/bin/env bash

default_dir=~/
allowed_dirs=(.config)
allowed_files=(.zshrc)

# Handle input arguments
if [[ $# -eq 1 ]]; then
    selected=$1
else
    selected=$(find ~/ -mindepth 1 -maxdepth 3 \( -type d -name '.*' $(printf "! -name %s " "${allowed_dirs[@]}") -prune -o -type d -print \) -o \( -type f -name '.*' $(printf "! -name %s " "${allowed_files[@]}") -prune -o -type f -print \) | \
        sed 's|^/home/enoch/||' | sort | uniq | fzf)
fi

# If no selection, fall back to default directory
if [[ -z $selected ]]; then
    if [[ -n $TMUX ]]; then
        # Inside tmux: Switch to the last session if it exists
        last_session=$(tmux list-sessions -F "#{session_name}" 2>/dev/null | grep -v "$(tmux display-message -p '#S')" | head -n 1)
        if [[ -n $last_session ]]; then
            tmux switch-client -t "$last_session"
        else
            echo "No other tmux session to switch to."
        fi
    else
        # Outside tmux: Attach to the last session or create a default one
        last_session=$(tmux list-sessions -F "#{session_name}" 2>/dev/null | head -n 1)
        if [[ -n $last_session ]]; then
            tmux attach-session -t "$last_session"
        else
            default_session_name=$(basename "$default_dir" | tr . _)
            tmux new-session -s "$default_session_name" -c "$default_dir"
        fi
    fi
    exit 0
fi

selected_path="$HOME/$selected"
selected_name=$(basename "$selected" | tr . _)

# Handle the selected item (directory or file)
if [[ -d "$selected_path" ]]; then
    # Directory case
    if [[ -z $TMUX ]]; then
        if ! tmux has-session -t="$selected_name" 2>/dev/null; then
            tmux new-session -ds "$selected_name" -c "$selected_path"
        fi
        tmux attach-session -t "$selected_name"
    else
        tmux new-session -c "$selected_path" -n "$selected_name"
    fi
else
    # File case
    if ! tmux has-session -t="$selected_name" 2>/dev/null; then
        tmux new-session -ds "$selected_name" -c "$(dirname "$selected_path")" "nvim '$selected_path'"
    fi
    if [[ -z $TMUX ]]; then
        tmux attach-session -t "$selected_name"
    else
        tmux switch-client -t "$selected_name"
    fi
fi
