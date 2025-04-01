#!/bin/bash

# Get the power state of Bluetooth
power_state=$(bluetoothctl show | grep "Powered:" | awk '{print $2}')

# Get the names of connected devices
connected_devices=$(bluetoothctl devices | grep "Device" | awk '{print $3, $4, $5}')

# Format the output
if [ "$power_state" == "yes" ]; then
    echo "Bluetooth: Powered On"
else
    echo "Bluetooth: Powered Off"
fi

if [ -n "$connected_devices" ]; then
    echo "Connected Devices: $connected_devices"
else
    echo "No devices connected"
fi

