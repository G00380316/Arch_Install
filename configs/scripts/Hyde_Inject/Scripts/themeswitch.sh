#!/usr/bin/env bash

echo "This script will be deprecated. Please use theme.switch.sh instead."
scrDir="$(dirname "$(realpath "$0")")"
scriptsDir="$HOME/.config/hypr/scripts"

"${scrDir}"/theme.switch.sh "$@"
pid=$!
wait "$pid"

"${scriptsDir}"/Refresh.sh
