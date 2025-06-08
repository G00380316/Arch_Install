#!/bin/bash

# Paths
CONSERVATION_MODE_PATH="/sys/bus/platform/drivers/ideapad_acpi/VPC2004:00/conservation_mode"
START_THRESH_PATH="/sys/class/power_supply/BAT0/charge_start_threshold"
STOP_THRESH_PATH="/sys/class/power_supply/BAT0/charge_stop_threshold"
BAT_PATH="/sys/class/power_supply/BAT1"
MONITOR_NAME="eDP-1"
LID_PATH="/proc/acpi/button/lid/LID0/state"


# Get current lid state
if [[ -f "$LID_PATH" ]]; then
    LID_STATE=$(awk '{print $2}' "$LID_PATH")
else
    echo "Lid state file not found"
    exit 1
fi

# Helper: Notify
notify() {
    command -v notify-send &>/dev/null && notify-send "Battery Manager" "$1"
}

# Helper: Pretty output
print_kv() {
    printf "  %-16s %s\n" "$1:" "$2"
}

# Show battery info
show_info() {
    echo ""
    echo ""
    echo "───────────────────────────────"
    echo "🔋 Battery Information"
    echo "───────────────────────────────"

    [[ -f "$BAT_PATH/model_name" ]] && print_kv "Model Name" "$(cat "$BAT_PATH/model_name")"
    [[ -f "$BAT_PATH/manufacturer" ]] && print_kv "Manufacturer" "$(cat "$BAT_PATH/manufacturer")"
    [[ -f "$BAT_PATH/cycle_count" ]] && print_kv "Cycle Count" "$(cat "$BAT_PATH/cycle_count")"
    [[ -f "$BAT_PATH/status" ]] && print_kv "Status" "$(cat "$BAT_PATH/status")"
    print_kv "Time" "$(date '+%Y-%m-%d %H:%M:%S')"
    echo

    if [[ -f "$BAT_PATH/energy_full_design" && -f "$BAT_PATH/energy_full" ]]; then
        design=$(cat "$BAT_PATH/energy_full_design")
        full=$(cat "$BAT_PATH/energy_full")
        full_pct=$(( 100 * full / design ))
        print_kv "Design Capacity" "$((design / 1000)) mWh"
        print_kv "Current Capacity" "$((full / 1000)) mWh ($full_pct%)"
    fi

    if [[ -f "$BAT_PATH/energy_now" && -f "$BAT_PATH/energy_full_design" ]]; then
        now=$(cat "$BAT_PATH/energy_now")
        design=$(cat "$BAT_PATH/energy_full_design")
        now_pct=$(( 100 * now / design ))
        print_kv "Current Charge" "$((now / 1000)) mWh ($now_pct%)"
    fi

    [[ -f "$BAT_PATH/capacity" ]] && print_kv "Charge Level" "$(cat "$BAT_PATH/capacity")%"

    echo

    if [[ -f "$CONSERVATION_MODE_PATH" ]]; then
        mode=$(cat "$CONSERVATION_MODE_PATH")
        print_kv "Conservation Mode" $([[ "$mode" -eq 1 ]] && echo "Enabled (limits to ~60%)" || echo "Disabled (charges to 100%)")
    else
        print_kv "Conservation Mode" "Not supported"
    fi

    if [[ -f "$START_THRESH_PATH" && -f "$STOP_THRESH_PATH" ]]; then
        print_kv "Start Threshold" "$(cat "$START_THRESH_PATH")%"
        print_kv "Stop Threshold" "$(cat "$STOP_THRESH_PATH")%"
    else
        print_kv "Custom Thresholds" "Not supported"
    fi
    echo
}

# Toggle Lenovo conservation mode
toggle_conservation() {
    if [[ -f "$CONSERVATION_MODE_PATH" ]]; then
        current=$(cat "$CONSERVATION_MODE_PATH")
        if [[ "$current" -eq 1 ]]; then
            echo 0 | sudo tee "$CONSERVATION_MODE_PATH"
            notify "Conservation Mode Disabled"
            echo
            echo "🛑 Disabled conservation mode (battery will charge to 100%)"
            echo
        else
            echo 1 | sudo tee "$CONSERVATION_MODE_PATH"
            notify "Conservation Mode Enabled"
            echo
            echo "✅ Enabled conservation mode (battery will stop around 60%)"
            echo
        fi
    else
        echo
        echo "⚠️  Conservation mode is not supported on this device."
        echo
    fi
}

# Set ThinkPad thresholds
set_thresholds() {
    if [[ -f "$START_THRESH_PATH" && -f "$STOP_THRESH_PATH" ]]; then
        echo
        read -rp "Enter START threshold (e.g., 40): " START
        read -rp "Enter STOP threshold (e.g., 80): " STOP

        echo "$START" | sudo tee "$START_THRESH_PATH"
        echo "$STOP"  | sudo tee "$STOP_THRESH_PATH"
        echo
        notify "Set thresholds: Start at $START%, Stop at $STOP%"
    else
        echo
        echo "⚠️  Custom charge thresholds are not supported on this device."
        echo
    fi
}

# Auto switch conservation mode
auto_switch() {
    if [[ ! -f "$CONSERVATION_MODE_PATH" ]]; then
        echo
        echo "⚠️  Conservation mode not supported for auto-switch."
        echo
        return
    fi

    charge=$(cat "$BAT_PATH/capacity")
    status=$(cat "$BAT_PATH/status")
    mode=$(cat "$CONSERVATION_MODE_PATH")

    MONITOR_ACTIVE=$(hyprctl monitors | grep -q "$MONITOR_NAME" && echo "yes" || echo "no")
    MONITOR_COUNT=$(hyprctl monitors | grep 'Monitor' | wc -l)

    # if [[ "$status" == "Charging" && "$charge" -ge 80 && "$mode" -ne 1 ]]; then
    #     echo 1 | sudo tee "$CONSERVATION_MODE_PATH"
    #     notify "Auto: Enabled conservation mode (battery at $charge%)"
    #     echo "🔁 Auto: Enabled conservation mode at $charge%"
    # elif [[ "$status" == "Discharging" && "$charge" -le 50 && "$mode" -ne 0 ]]; then
    #     echo 0 | sudo tee "$CONSERVATION_MODE_PATH"
    #     notify "Auto: Disabled conservation mode (battery at $charge%)"
    #     echo "🔁 Auto: Disabled conservation mode at $charge%"
    if [[ "$LID_STATE" == "closed" && "$MONITOR_COUNT" < 1 && "$mode" -ne 1 ]]; then
        echo 1 | sudo tee "$CONSERVATION_MODE_PATH"
        notify "Auto: Enabled conservation mode (battery at $charge%)"
        echo
        echo "🔁 Auto: Enabled conservation mode at $charge%"
        echo
    elif [[ "$LID_STATE" == "open" && "$MONITOR_COUNT" == 1 && "$mode" -ne 0 ]]; then
        echo 0 | sudo tee "$CONSERVATION_MODE_PATH"
        notify "Auto: Disabled conservation mode (battery at $charge%)"
        echo
        echo "🔁 Auto: Disabled conservation mode at $charge%"
        echo
    else
        echo
        echo "ℹ️  Auto: No change needed (Status: $status, Charge: $charge%)"
        echo
    fi
}

# Show help
print_help() {
    echo
    echo "───────────────────────────────"
    echo "Battery Manager – Usage"
    echo "───────────────────────────────"
    echo "  info             Show battery status and settings"
    echo "  toggle           Toggle conservation mode"
    echo "  set-thresholds   Set ThinkPad thresholds (if supported)"
    echo "  auto             Automatically switch conservation mode"
    echo
}

# Main entry
case "$1" in
    info|"")
        show_info
        ;;
    toggle)
        toggle_conservation
        ;;
    set-thresholds)
        set_thresholds
        ;;
    auto)
        auto_switch
        ;;
    *)
        print_help
        ;;
esac

