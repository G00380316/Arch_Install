#!/usr/bin/env bash

default_dir=~/
base_name=$(basename "$default_dir" | tr . _)

# Get all existing sessions
mapfile -t sessions < <(tmux list-sessions -F "#{session_name}" 2>/dev/null)

# Find the lowest available session (not attached)
i=0
while true; do
    session_candidate="${base_name}"
    [[ $i -ne 0 ]] && session_candidate="${base_name}_$i"

    if printf '%s\n' "${sessions[@]}" | grep -qx "$session_candidate"; then
        # Check if session has clients
        attached=$(tmux list-clients -t "$session_candidate" 2>/dev/null | wc -l)
        if (( attached == 0 )); then
            # Session exists but no clients — reuse it
            if [[ -n $TMUX ]]; then
                tmux switch-client -t "$session_candidate"
            else
                tmux attach-session -t "$session_candidate"
            fi
            exit 0
        fi
    else
        # Session doesn't exist — create and attach
        if [[ -n $TMUX ]]; then
            tmux new-session -ds "$session_candidate" -c "$default_dir"
            tmux switch-client -t "$session_candidate"
        else
            tmux new-session -s "$session_candidate" -c "$default_dir"
        fi
        exit 0
    fi

    ((i++))
done

