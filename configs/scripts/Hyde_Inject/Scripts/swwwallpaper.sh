#!/usr/bin/env bash
# shellcheck disable=SC2154

cat <<EOF
DEPRECATION: This script is deprecated, please use 'wallpaper.sh' instead."

-------------------------------------------------
example: 
wallpaper.sh ${@} --backend swww --global
-------------------------------------------------
EOF

scriptsDir="$HOME/.config/hypr/scripts"

"wallpaper.sh" "${@}" --backend swww --global
pid=$!
wait "$pid"

"${scriptsDir}"/Refresh.sh
