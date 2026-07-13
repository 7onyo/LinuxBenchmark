#!/bin/bash

if [ "$EUID" -ne 0 ]; then
  echo "Please run with sudo: sudo ./record_macro.sh"
  exit 1
fi

TARGET_KBD="ITE Tech. Inc. ITE Device(8910) Keyboard"
OUTPUT_FILE="game_path.evemu"

EVENT_NODE=$(grep -A 4 "Name=\"$TARGET_KBD\"" /proc/bus/input/devices | grep -oE 'event[0-9]+' | head -n 1)

if [ -z "$EVENT_NODE" ]; then
    echo "Error: Could not find keyboard matching '$TARGET_KBD'."
    echo "Please verify the device name or check if it is connected."
    exit 1
fi

EVENT_PATH="/dev/input/$EVENT_NODE"

echo "Detected '$TARGET_KBD' at $EVENT_PATH"
echo "You have 5 seconds to switch to your game"
sleep 5

echo "Recording started! Capturing inputs to $OUTPUT_FILE..."


evemu-record "$EVENT_PATH" > "$OUTPUT_FILE"

echo "Recording saved to $OUTPUT_FILE"
