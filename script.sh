#!/bin/bash

if [ "$EUID" -ne 0 ]; then
  echo "Please run with sudo: sudo ./masterScript.sh"
  exit
fi

FILE="game_path.evemu"

evemu-device "$FILE" > /tmp/vdev_node.txt &
PID=$!

sleep 1

VDEV=$(grep -oE '/dev/input/event[0-9]+' /tmp/vdev_node.txt)

if [ -z "$VDEV" ]; then
    echo "Error: Could not find virtual device node. Check your .evemu file."
    kill $PID
    exit 1
fi

echo "Created virtual keyboard at $VDEV."
echo "You have 5 seconds to Alt+Tab into your game"
sleep 5

evemu-play "$VDEV" < "$FILE"

kill $PID
rm /tmp/vdev_node.txt
