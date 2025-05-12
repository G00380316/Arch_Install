#!/usr/bin/env bash

# Set up paths
scrDir=$(dirname "$(realpath "$0")")
# shellcheck disable=SC1091
source "${scrDir}/globalcontrol.sh"

waybar_dir="${confDir}/waybar"
in_file="$waybar_dir/modules/style.css"
out_file="$waybar_dir/style.css"

# Set default bar height (use env var if set)
b_height=${WAYBAR_SCALE:-30}

# Fallback: try to calculate height from monitor resolution if b_height is 0
if [ "$b_height" -eq 0 ]; then
    y_monres=$(hyprctl -j monitors | jq '.[] | select(.focused == true) | (.height / .scale)')
    b_height=$((y_monres * 3 / 100))
fi

# Derived style values
export b_radius=$((b_height * 70 / 100))
export c_radius=$((b_height * 25 / 100))
export t_radius=$((b_height * 25 / 100))
export e_margin=$((b_height * 30 / 100))
export e_paddin=$((b_height * 10 / 100))
export g_margin=$((b_height * 14 / 100))
export g_paddin=$((b_height * 15 / 100))
export w_radius=$((b_height * 30 / 100))
export w_margin=$((b_height * 10 / 100))
export w_paddin=$((b_height * 10 / 100))
export w_padact=$((b_height * 40 / 100))
export s_fontpx=$((b_height * 34 / 100))

# Min padding and font size
[ "$b_height" -lt 30 ] && export e_paddin=0
[ "$s_fontpx" -lt 10 ] && export s_fontpx=10

# Set default position if not using config.ctl
w_position="top"
export w_position

# Layout based on position
case "$w_position" in
  top | bottom)
    export x1g_margin=$g_margin
    export x2g_margin=0
    export x3g_margin=$g_margin
    export x4g_margin=0

    export x1rb_radius=0
    export x2rb_radius=$b_radius
    export x3rb_radius=$b_radius
    export x4rb_radius=0

    export x1lb_radius=$b_radius
    export x2lb_radius=0
    export x3lb_radius=0
    export x4lb_radius=$b_radius

    export x1rc_radius=0
    export x2rc_radius=$c_radius
    export x3rc_radius=$c_radius
    export x4rc_radius=0

    export x1lc_radius=$c_radius
    export x2lc_radius=0
    export x3lc_radius=0
    export x4lc_radius=$c_radius

    export x1="top"
    export x2="bottom"
    export x3="left"
    export x4="right"
    ;;
  left | right)
    export x1g_margin=0
    export x2g_margin=$g_margin
    export x3g_margin=0
    export x4g_margin=$g_margin

    export x1rb_radius=0
    export x2rb_radius=0
    export x3rb_radius=$b_radius
    export x4rb_radius=$b_radius

    export x1lb_radius=$b_radius
    export x2lb_radius=$b_radius
    export x3lb_radius=0
    export x4lb_radius=0

    export x1rc_radius=0
    export x2rc_radius=$c_radius
    export x3rc_radius=$c_radius
    export x4rc_radius=0

    export x1lc_radius=$c_radius
    export x2lc_radius=0
    export x3lc_radius=0
    export x4lc_radius=$c_radius

    export x1="left"
    export x2="right"
    export x3="top"
    export x4="bottom"
    ;;
esac

# Font fallback
font_name=${WAYBAR_FONT:-$(get_hyprConf "WAYBAR_FONT")}
export font_name=${font_name:-"JetBrainsMono Nerd Font"}

envsubst <"$in_file" >"$out_file"

