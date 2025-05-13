#!/bin/bash

# For Rofi Beats to play online Music or Locally save media files

# Variables
mDIR="$HOME/Music/"
iDIR="$HOME/.config/swaync/icons"
rofi_theme="$HOME/.config/rofi/config-rofi-Beats.rasi"
rofi_theme_1="$HOME/.config/rofi/config-rofi-Beats-menu.rasi"

# Online Stations. Edit as required
declare -A online_music=(
["YT - Top 50 Global 🎶"]="https://music.youtube.com/playlist?list=PLmtas71NLwTf_F24T3mnj6nGbY81HnKu_&si=To7OISoqjt-eO7Dn"
["YT - Top 50 Nigeria 🎶"]="https://music.youtube.com/playlist?list=PLmtas71NLwTfyDGaZmjH35WeTCIM68Amn&si=508mDpoYzGrqJ7P4"
["YT - Top 50 USA 🎶"]="https://music.youtube.com/playlist?list=PLmtas71NLwTdOkxObFRH1EM569GlRIQdM&si=KSzAxS1KVhqTG4Fv"
["YT - Top 50 United Kingdom 🎶"]="https://music.youtube.com/playlist?list=PLmtas71NLwTeW6eXnXX5NKM-yaxj1_vD9&si=r2Py7S6o43gQthHe"
["YT - Relaxing Piano Music 🎹🎶"]="https://youtu.be/6H7hXzjFoVU?si=nZTPREC9lnK1JJUG"
["YT - Thunder Rnb Mix 📹🎶"]="https://youtu.be/pWCUKN0RLYg?si=PrQVeA0npX1ekV7o"
["YT - R&B/Soul Mix Rnb Mix 📹🎶"]="https://www.youtube.com/watch?v=Mip7jRCvIRE"
["YT - Korean Drama OST 📹🎶"]="https://youtube.com/playlist?list=PLUge_o9AIFp4HuA-A3e3ZqENh63LuRRlQ"
["YT - Korean Cafe Music 📹🎶"]="https://youtube.com/playlist?list=PLmtas71NLwTfioQrNKNYika4Tcao7CDbc&si=fAdYdhs1IGPkvUAa"
["YT - lofi hip hop radio beats 📹🎶"]="https://www.youtube.com/live/jfKfPfyJRdk?si=PnJIA9ErQIAw6-qd"
["YT - Relaxing Piano Jazz Music 🎹🎶"]="https://youtu.be/85UEqRat6E4?si=jXQL1Yp2VP_G6NSn"
["YT - Spontaneous Worship 🎶"]="https://www.youtube.com/watch?v=n5wkNJt3lGY&t=2653s"
["YT - Worship (Elevation Worship & Maverick City) 🎶"]="https://www.youtube.com/watch?v=33mVFWQyTno"
["YT - Kenny G (All-Time Hits) 🎶"]="https://youtu.be/A_2XpZDzWnY?si=IDwls7LaisraRlp2"
["YT - Jireh Mix 🎶"]="https://youtube.com/playlist?list=PLGvkktFFaDOMQS0vAWVGGzF7846GCKf3G&si=bz4FE9L0UuF1qCP_"
["YT - Tiny Desk Favourites 🎶"]="https://youtube.com/playlist?list=PLmtas71NLwTfLDvQfo5dG5ggF771YuoOo&si=5ZtiB1OqGoNLwbrx"
["YT - Favourite Worship Right Now!!!🎶"]="https://youtube.com/playlist?list=PLmtas71NLwTdV8sKDLYTShavvJk4OWq3p&si=9ZEAcwFe-djT1_oN"
["YT - Favourite Songs Right Now!!!🎶"]="https://youtube.com/playlist?list=PLmtas71NLwTfW4FWFbsbb4I9YFwxhUc79&si=iXG0Er3c-Z69aNt1"
["FM - Easy Rock 96.3 📻🎶"]="https://radio-stations-philippines.com/easy-rock"
["FM - Easy Rock - Baguio 91.9 📻🎶"]="https://radio-stations-philippines.com/easy-rock-baguio"
["FM - Love Radio 90.7 📻🎶"]="https://radio-stations-philippines.com/love"
["FM - WRock - CEBU 96.3 📻🎶"]="https://onlineradio.ph/126-96-3-wrock.html"
["FM - Fresh Philippines 📻🎶"]="https://onlineradio.ph/553-fresh-fm.html"
["Radio - Lofi Girl 🎧🎶"]="https://play.streamafrica.net/lofiradio"
["Radio - Chillhop 🎧🎶"]="http://stream.zeno.fm/fyn8eh3h5f8uv"
["Radio - Ibiza Global 🎧🎶"]="https://filtermusic.net/ibiza-global"
["Radio - Metal Music 🎧🎶"]="https://tunein.com/radio/mETaLmuSicRaDio-s119867/"
)
# Populate local_music array with files from music directory and subdirectories
populate_local_music() {
  local_music=()
  filenames=()
  while IFS= read -r file; do
    local_music+=("$file")
    filenames+=("$(basename "$file")")
  done < <(find -L "$mDIR" -type f \( -iname "*.mp3" -o -iname "*.flac" -o -iname "*.wav" -o -iname "*.ogg" -o -iname "*.mp4" \))
}

# Function for displaying notifications
notification() {
  notify-send -u normal -i "$iDIR/music.png" " Now Playing:" " $@"
}

# Main function for playing local music
play_local_music() {
  populate_local_music

  # Prompt the user to select a song
  choice=$(printf "%s\n" "${filenames[@]}" | rofi -i -dmenu -config $rofi_theme)

  if [ -z "$choice" ]; then
    exit 1
  fi

  # Find the corresponding file path based on user's choice and set that to play the song then continue on the list
  for (( i=0; i<"${#filenames[@]}"; ++i )); do
    if [ "${filenames[$i]}" = "$choice" ]; then

	    notification "$choice"

      # Play the selected local music file using mpv
      mpv --playlist-start="$i" --loop-playlist --vid=no  "${local_music[@]}"

      break
    fi
  done
}

# Main function for shuffling local music
shuffle_local_music() {
  notification "Shuffle Play local music"

  # Play music in $mDIR on shuffle
  mpv --shuffle --loop-playlist --vid=no "$mDIR"
}

# Main function for playing online music
play_online_music() {
  choice=$(for online in "${!online_music[@]}"; do
      echo "$online"
    done | sort | rofi -i -dmenu -config "$rofi_theme")

  if [ -z "$choice" ]; then
    exit 1
  fi

  link="${online_music[$choice]}"

  notification "$choice"

  # Play the selected online music using mpv
  mpv --shuffle --vid=no "$link"
}


# Check if an online music process is running and send a notification, otherwise run the main function
pkill mpv && notify-send -u low -i "$iDIR/music.png" "Music stopped" || {

# Check if rofi is already running
if pidof rofi > /dev/null; then
  pkill rofi
fi


# Prompt the user to choose between local and online music
user_choice=$(printf "Play from Online Stations\nPlay from Music Folder\nShuffle Play from Music Folder" | rofi -dmenu -config $rofi_theme_1)

  case "$user_choice" in
    "Play from Music Folder")
      play_local_music
      ;;
    "Play from Online Stations")
      play_online_music
      ;;
    "Shuffle Play from Music Folder")
      shuffle_local_music
      ;;
    *)
      echo "Invalid choice"
      ;;
  esac
}
