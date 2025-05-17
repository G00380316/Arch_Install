#!/bin/bash

# Define your themes list
themes=(
  "Catppuccin Mocha https://github.com/HyDE-Project/hyde-themes/tree/Catppuccin-Mocha"
  "Catppuccin Latte https://github.com/HyDE-Project/hyde-themes/tree/Catppuccin-Latte"
  "Rosé Pine https://github.com/HyDE-Project/hyde-themes/tree/Rose-Pine"
  "Tokyo Night https://github.com/HyDE-Project/hyde-themes/tree/Tokyo-Night"
  "Material Sakura https://github.com/HyDE-Project/hyde-themes/tree/Material-Sakura"
  "Graphite Mono https://github.com/HyDE-Project/hyde-themes/tree/Graphite-Mono"
  "Decay Green https://github.com/HyDE-Project/hyde-themes/tree/Decay-Green"
  "Edge Runner https://github.com/HyDE-Project/hyde-themes/tree/Edge-Runner"
  "Frosted Glass https://github.com/HyDE-Project/hyde-themes/tree/Frosted-Glass"
  "Gruvbox Retro https://github.com/HyDE-Project/hyde-themes/tree/Gruvbox-Retro"
  "Synth Wave https://github.com/HyDE-Project/hyde-themes/tree/Synth-Wave"
  "Nordic Blue https://github.com/HyDE-Project/hyde-themes/tree/Nordic-Blue"
  "Cat Latte https://github.com/rishav12s/Cat-Latte"
  "Green Lush https://github.com/abenezerw/Green-Lush"
  "Ice Age https://github.com/saber-88/Ice-Age"
  "Red Stone https://github.com/mahaveergurjar/Theme-Gallery/tree/Red_Stone"
  "Cosmic Blue https://github.com/Maroc02/Cosmic-Blue"
  "Sci-fi https://github.com/KaranRaval123/Sci-fi"
  "Paranoid Sweet https://github.com/rishav12s/Paranoid-Sweet"
  "Monterey Frost https://github.com/rishav12s/Monterey-Frost"
  "BlueSky https://github.com/richen604/BlueSky"
  "AbyssGreen https://github.com/Itz-Abhishek-Tiwari/AbyssGreen"
  "Solarized Dark https://github.com/rishav12s/Solarized-Dark"
  "One Dark https://github.com/RAprogramm/HyDe-Themes/tree/One-Dark"
  "Crimson Blade https://github.com/cyb3rgh0u1/Crimson-Blade"
  "Monokai https://github.com/mahaveergurjar/Theme-Gallery/tree/Monokai"
  "Pixel Dream https://github.com/rishav12s/Pixel-Dream"
  "Rain Dark https://github.com/rishav12s/Rain-Dark"
  "Oxo Carbon https://github.com/rishav12s/Oxo-Carbon"
  "Greenify https://github.com/mahaveergurjar/Theme-Gallery/tree/Greenify"
  "Bad Blood https://github.com/HyDE-Project/hyde-gallery/tree/Bad-Blood"
  "Vanta Black https://github.com/rishav12s/Vanta-Black"
  "Code Garden https://github.com/jacobfranco/Code-Garden"
  "DoomBringers https://github.com/xaicat/DoomBringers"
  "Ever Blushing https://github.com/rishav12s/Ever-Blushing"
)

mkdir -p hyde-themes
cd hyde-themes || exit 1

for entry in "${themes[@]}"; do
  name="${entry%% https://*}"
  url="${entry#*https://}"
  full_url="https://${url}"

  # Extract base repo and optional branch
  if [[ "$full_url" =~ github\.com/([^/]+/[^/]+)(/tree/([^/]+))? ]]; then
    repo="${BASH_REMATCH[1]}"
    branch="${BASH_REMATCH[3]}"

    clone_url="https://github.com/$repo.git"
    folder_name="${name// /_}"  # Replace spaces with underscores

    echo "Cloning $name..."
    if [ -n "$branch" ]; then
      git clone --depth 1 --branch "$branch" --single-branch "$clone_url" "$folder_name"
    else
      git clone --depth 1 "$clone_url" "$folder_name"
    fi
  else
    echo "Failed to parse URL for $name"
  fi
done

