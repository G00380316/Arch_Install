#!/bin/bash

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

# 📁 Prepare working directory
mkdir -p hyde-themes-clones
cd hyde-themes-clones || exit 1

# 🚀 Process each theme
jq -c '.[]' "../$json_file" | while read -r theme; do
    name=$(echo "$theme" | jq -r '.THEME' | tr ' ' '-' | tr '[:upper:]' '[:lower:]')

    if [ -d "$name" ]; then
        echo "⚠️  Skipping $name (already cloned)"
        continue
    fi

    clone_url=$(echo "$theme" | jq -r '.LINK' | sed 's|/tree/.*||')
 
    #branch=$(echo "$theme" | jq -r '.LINK' | sed -n 's|.*/tree/\(.*\)$|\1|p')  

    if [ -n "$branch" ]; then
        git clone --depth=1 --branch "$branch" "$clone_url" "$name" || {
            echo "❌ Failed to clone $clone_url branch $branch"
                    continue
                }
        else
            git clone --depth=1 "$clone_url" "$name" || {
                echo "❌ Failed to clone $clone_url"
                            continue
                        }
    fi

    echo "📦 Processing: $name"

    cd "$name" || continue

    # 2. Delete the original repository's Git history
    echo "Removing original .git history..."
    rm -rf .git

    # 3. Initialize a new, clean Git repository
    echo "Initializing new repository..."
    git init -b main

    # Create the public GitHub repo
    echo "Creating public repo: $username/$name"
    gh repo create "$name" --public --confirm || {
        echo "❌ Failed to create GitHub repo: $name"
        cd ..
        continue
    }
    
    # 4. Add all files and create a fresh initial commit
    echo "Creating initial commit..."
    git add .
    git commit -m "Initial commit"

    # 5. Add the new remote and push the single commit
    git remote add origin "https://github.com/$username/$name.git"
    
    echo "Pushing new 'main' branch..."
    git push -u origin main || {
        echo "❌ Push failed for $name"
        cd ..
        continue
    }

    cd ..
    echo "✅ Done with $name"
done