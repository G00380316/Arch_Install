#!/usr/bin/env bash

default_dir=~/
default_session_base=$(basename "$default_dir" | tr . _)
existing_sessions=$(tmux list-sessions -F "#{session_name}" 2>/dev/null)

# Generate unique session name
i=1
unique_session="$default_session_base"
while echo "$existing_sessions" | grep -qx "$unique_session"; do
    unique_session="${default_session_base}_$i"
    ((i++))
done

if [[ -n $TMUX ]]; then
    # Inside tmux: Switch to a new session
    tmux new-session -ds "$unique_session" -c "$default_dir"
    tmux switch-client -t "$unique_session"
else
    # Outside tmux: Create or attach
    tmux new-session -s "$unique_session" -c "$default_dir"
fi

exit 0

