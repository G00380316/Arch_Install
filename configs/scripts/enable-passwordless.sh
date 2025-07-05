#!/bin/bash

USER=$(whoami)
TMP_FILE=$(mktemp)
MODIFIED=false
SUDOERS_D_FILE="/etc/sudoers.d/00_$USER"

if [[ "$EUID" -eq 0 ]]; then
    echo "❌ Do not run this script as root. Run it as your regular user."
    exit 1
fi

# Load existing sudoers file if present
EXISTING_CONTENT=""
if sudo test -f "$SUDOERS_D_FILE"; then
    EXISTING_CONTENT=$(sudo cat "$SUDOERS_D_FILE")
fi

# Start fresh with existing content
echo "$EXISTING_CONTENT" > "$TMP_FILE"

# Remove non-NOPASSWD entries and ensure NOPASSWD: ALL is added
sed -i "/^$USER ALL=(ALL) ALL$/d" "$TMP_FILE"
if ! grep -Fxq "$USER ALL=(ALL) NOPASSWD: ALL" "$TMP_FILE"; then
    echo "$USER ALL=(ALL) NOPASSWD: ALL" >> "$TMP_FILE"
    echo "✅ Added default: NOPASSWD: ALL"
    MODIFIED=true
fi

sudo -k

# Process extra paths, if any
if [[ "$#" -lt 1 ]]; then
    echo "ℹ️ No paths provided. Only default NOPASSWD: ALL added."
else
    for path in "$@"; do
        REAL_PATH=$(realpath "$path" 2>/dev/null)
        if [[ ! -e "$REAL_PATH" ]]; then
            echo "❌ Path does not exist: $path"
            continue
        fi

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
fi

chmod 600 "$TMP_FILE"

# Apply changes if modified
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

sudo -k