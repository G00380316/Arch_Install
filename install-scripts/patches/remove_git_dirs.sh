#!/bin/bash

# Default to current directory if no argument is given
TARGET_DIR="${1:-.}"

echo "Removing all .git directories under: $TARGET_DIR"

find "$TARGET_DIR" -type d -name ".git" -exec rm -rf {} +

echo "✅ All .git directories removed."

