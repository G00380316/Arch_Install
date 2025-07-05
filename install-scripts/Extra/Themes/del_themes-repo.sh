#!/bin/bash

# Log into Git with gh auth command using personal token

json_file="hyde-themes.json"

# Check required tools
for cmd in git gh jq; do
    if ! command -v "$cmd" &>/dev/null; then
        echo "❌ '$cmd' is not installed."
        exit 1
    fi
done

# Get GitHub username
username=$(gh api user --jq .login)

# Build a list of all theme repo names from JSON
echo "🔍 Extracting theme names..."
theme_names=()
while IFS= read -r name; do
    theme_names+=("$name")
done < <(jq -r '.[].THEME' "$json_file" | tr ' ' '-' | tr '[:upper:]' '[:lower:]')

# 🧹 Clean up repos created by this script (public or private)
echo "🧹 Cleaning up existing repos that match theme names..."

gh repo list "$username" --limit 500 --json name,visibility --jq '.[] | .name + " " + .visibility' |
while read -r line; do
    repo=$(echo "$line" | awk '{print $1}')
    visibility=$(echo "$line" | awk '{print $2}')
    
    for theme in "${theme_names[@]}"; do
        if [[ "$repo" == "$theme" ]]; then
            echo "🗑️  Deleting $visibility repo: $repo"
            gh repo delete "$username/$repo" --yes
        fi
    done
done