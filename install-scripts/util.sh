#!/bin/bash

## WARNING: DO NOT EDIT BELOW UNLESS YOU KNOW WHAT YOU'RE DOING ##
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Source global functions
if ! source "$(dirname "$(readlink -f "$0")")/Global_functions.sh"; then
    echo "Failed to source Global_functions.sh"
    exit 1
fi

LOG="Install-Logs/install-$(date +%d-%H%M%S)_utils.log"

# Redirecting all output and errors to log file
exec > >(tee -a "$LOG") 2>&1

# Log the start of the script
echo "=== Script started at $(date) ==="
# Remove unwanted applications from the menu
echo "Removing unwanted applications from the menu..."

# Remove Avahi tools
echo "Removing Avahi tools..."
if ls /usr/share/applications | grep -q avahi; then
    sudo rm /usr/share/applications/avahi-discover.desktop && echo "Removed avahi-discover.desktop"
else
    echo "No Avahi tools found to remove."
fi

# Remove VNC applications
echo "Removing VNC applications..."
if ls /usr/share/applications | grep -q -i vnc; then
    sudo rm /usr/share/applications/bvnc.desktop && echo "Removed bvnc.desktop"
else
    echo "No VNC applications found to remove."
fi

# Remove SSH applications
echo "Removing SSH applications..."
if ls /usr/share/applications | grep -q -i ssh; then
    sudo rm /usr/share/applications/bssh.desktop && echo "Removed bssh.desktop"
else
    echo "No SSH applications found to remove."
fi

# Remove SSH applications
echo "Removing UserFeedback Console applications..."
if ls /usr/share/applications | grep -q -i userFeedback; then
    sudo rm -r  /usr/share/applications/org.kde.kuserfeedback-console.desktop  && echo "Removed UserFeedback Console"
else
    echo "No SSH applications found to remove."
fi

apps_to_hide=(
"jconsole-java-openjdk.desktop"
"jshell-java-openjdk.desktop"
"qvidcap.desktop"
"qv4l2.desktop"
"vim.desktop"
"org.gnupg.pinentry-qt5.desktop"
"org.gnupg.pinentry-qt.desktop"
"in.lsp_plug.lsp_plugins_ab_tester_x2_mono.desktop"
"in.lsp_plug.lsp_plugins_ab_tester_x2_stereo.desktop"
"in.lsp_plug.lsp_plugins_ab_tester_x4_mono.desktop"
"in.lsp_plug.lsp_plugins_ab_tester_x4_stereo.desktop"
"in.lsp_plug.lsp_plugins_ab_tester_x8_mono.desktop"
"in.lsp_plug.lsp_plugins_ab_tester_x8_stereo.desktop"
"in.lsp_plug.lsp_plugins_art_delay_mono.desktop"
"in.lsp_plug.lsp_plugins_art_delay_stereo.desktop"
"in.lsp_plug.lsp_plugins_autogain_mono.desktop"
"in.lsp_plug.lsp_plugins_autogain_stereo.desktop"
"in.lsp_plug.lsp_plugins_beat_breather_mono.desktop"
"in.lsp_plug.lsp_plugins_beat_breather_stereo.desktop"
"in.lsp_plug.lsp_plugins_chorus_mono.desktop"
"in.lsp_plug.lsp_plugins_chorus_stereo.desktop"
"in.lsp_plug.lsp_plugins_clipper_mono.desktop"
"in.lsp_plug.lsp_plugins_clipper_stereo.desktop"
"in.lsp_plug.lsp_plugins_comp_delay_mono.desktop"
"in.lsp_plug.lsp_plugins_comp_delay_stereo.desktop"
"in.lsp_plug.lsp_plugins_comp_delay_x2_stereo.desktop"
"in.lsp_plug.lsp_plugins_compressor_lr.desktop"
"in.lsp_plug.lsp_plugins_compressor_mono.desktop"
"in.lsp_plug.lsp_plugins_compressor_ms.desktop"
"in.lsp_plug.lsp_plugins_compressor_stereo.desktop"
"in.lsp_plug.lsp_plugins_crossover_lr.desktop"
"in.lsp_plug.lsp_plugins_crossover_mono.desktop"
"in.lsp_plug.lsp_plugins_crossover_ms.desktop"
"in.lsp_plug.lsp_plugins_crossover_stereo.desktop"
"in.lsp_plug.lsp_plugins_dyna_processor_lr.desktop"
"in.lsp_plug.lsp_plugins_dyna_processor_mono.desktop"
"in.lsp_plug.lsp_plugins_dyna_processor_ms.desktop"
"in.lsp_plug.lsp_plugins_dyna_processor_stereo.desktop"
"in.lsp_plug.lsp_plugins_expander_lr.desktop"
"in.lsp_plug.lsp_plugins_expander_mono.desktop"
"in.lsp_plug.lsp_plugins_expander_ms.desktop"
"in.lsp_plug.lsp_plugins_expander_stereo.desktop"
"in.lsp_plug.lsp_plugins_filter_mono.desktop"
"in.lsp_plug.lsp_plugins_filter_stereo.desktop"
"in.lsp_plug.lsp_plugins_flanger_mono.desktop"
"in.lsp_plug.lsp_plugins_flanger_stereo.desktop"
"in.lsp_plug.lsp_plugins_gate_lr.desktop"
"in.lsp_plug.lsp_plugins_gate_mono.desktop"
"in.lsp_plug.lsp_plugins_gate_ms.desktop"
"in.lsp_plug.lsp_plugins_gate_stereo.desktop"
"in.lsp_plug.lsp_plugins_gott_compressor_lr.desktop"
"in.lsp_plug.lsp_plugins_gott_compressor_mono.desktop"
"in.lsp_plug.lsp_plugins_gott_compressor_ms.desktop"
"in.lsp_plug.lsp_plugins_gott_compressor_stereo.desktop"
"in.lsp_plug.lsp_plugins_graph_equalizer_x16_lr.desktop"
"in.lsp_plug.lsp_plugins_graph_equalizer_x16_mono.desktop"
"in.lsp_plug.lsp_plugins_graph_equalizer_x16_ms.desktop"
"in.lsp_plug.lsp_plugins_graph_equalizer_x16_stereo.desktop"
"in.lsp_plug.lsp_plugins_graph_equalizer_x32_lr.desktop"
"in.lsp_plug.lsp_plugins_graph_equalizer_x32_mono.desktop"
"in.lsp_plug.lsp_plugins_graph_equalizer_x32_ms.desktop"
"in.lsp_plug.lsp_plugins_graph_equalizer_x32_stereo.desktop"
"in.lsp_plug.lsp_plugins_impulse_responses_mono.desktop"
"in.lsp_plug.lsp_plugins_impulse_responses_stereo.desktop"
"in.lsp_plug.lsp_plugins_impulse_reverb_mono.desktop"
"in.lsp_plug.lsp_plugins_impulse_reverb_stereo.desktop"
"in.lsp_plug.lsp_plugins_latency_meter.desktop"
"in.lsp_plug.lsp_plugins_limiter_mono.desktop"
"in.lsp_plug.lsp_plugins_limiter_stereo.desktop"
"in.lsp_plug.lsp_plugins_loud_comp_mono.desktop"
"in.lsp_plug.lsp_plugins_loud_comp_stereo.desktop"
"in.lsp_plug.lsp_plugins_mb_clipper_mono.desktop"
"in.lsp_plug.lsp_plugins_mb_clipper_stereo.desktop"
"in.lsp_plug.lsp_plugins_mb_compressor_lr.desktop"
"in.lsp_plug.lsp_plugins_mb_compressor_mono.desktop"
"in.lsp_plug.lsp_plugins_mb_compressor_ms.desktop"
"in.lsp_plug.lsp_plugins_mb_compressor_stereo.desktop"
"in.lsp_plug.lsp_plugins_mb_dyna_processor_lr.desktop"
"in.lsp_plug.lsp_plugins_mb_dyna_processor_mono.desktop"
"in.lsp_plug.lsp_plugins_mb_dyna_processor_ms.desktop"
)

applications_dir="/usr/share/applications"

for app in "${apps_to_hide[@]}"; do 
   desktop_file="$applications_dir/$app"
   if [ -f "$desktop_file" ]; then
      echo "Hiding $app"
      sudo sed -i '/^NoDisplay=/d' "$desktop_file" # Remove existing NoDisplay line
      echo "NoDisplay=true" | sudo tee -a "$desktop_file" > /dev/null
   else
      echo "$app not found"
   fi
done

echo "All done!"
