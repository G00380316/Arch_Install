#!/bin/bash

USER=$(whoami)

if [[ "$EUID" -eq 0 ]]; then
    echo "❌ Do not run this script as root. Run it as your regular user."
    exit 1
fi

if [[ "$#" -lt 1 ]]; then
    echo "❌ Please provide at least one file or directory."
    echo "Usage: $0 /path/to/file_or_dir [more_paths...]"
    exit 1
fi

SUDOERS_D_FILE="/etc/sudoers.d/00_$USER"
TMP_FILE=$(mktemp)
chmod 600 "$TMP_FILE"

EXISTING_CONTENT=""
if sudo test -f "$SUDOERS_D_FILE"; then
    EXISTING_CONTENT=$(sudo cat "$SUDOERS_D_FILE")
    echo "$EXISTING_CONTENT" > "$TMP_FILE"
fi

# Replace existing broad ALL lines with passwordless version
sed -i "/^$USER ALL=(ALL) ALL$/d" "$TMP_FILE"
if ! grep -Fxq "$USER ALL=(ALL) NOPASSWD: ALL" "$TMP_FILE"; then
    echo "$USER ALL=(ALL) NOPASSWD: ALL" >> "$TMP_FILE"
    MODIFIED=true
fi

MODIFIED=false
for path in "$@"; do
    REAL_PATH=$(realpath "$path" 2>/dev/null)
    if [[ ! -e "$REAL_PATH" ]]; then
        echo "❌ Path does not exist: $path"
        continue
    fi

    # If directory, append wildcard
    [[ -d "$REAL_PATH" ]] && REAL_PATH="$REAL_PATH/*"

    LINE="$USER ALL=(ALL) NOPASSWD: $REAL_PATH"
    if ! grep -Fxq "$LINE" "$TMP_FILE"; then
        echo "$LINE" >> "$TMP_FILE"
        echo "✅ Adding: $REAL_PATH"
        MODIFIED=true
    else
        echo "ℹ️ Already allowed: $REAL_PATH"
    fi
done

if $MODIFIED; then
    echo "🛠️ Validating sudoers..."
    if sudo visudo -cf "$TMP_FILE"; then
        sudo cp "$TMP_FILE" "$SUDOERS_D_FILE"
        echo "✅ Sudoers rule saved to: $SUDOERS_D_FILE"
    else
        echo "❌ Syntax error in sudoers! No changes were applied."
    fi
else
    echo "👍 No changes made."
fi

rm -f "$TMP_FILE"

