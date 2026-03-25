#!/bin/bash

PID_FILE="/tmp/sing-box.pid"

echo "Stopping sing-box..."

if [ -f "$PID_FILE" ]; then
    PID=$(cat "$PID_FILE")
    sudo kill "$PID" 2>/dev/null
    sleep 2
    sudo kill -9 "$PID" 2>/dev/null
    rm -f "$PID_FILE"
fi

# Ensure no leftover processes
sudo pkill -9 sing-box 2>/dev/null || true

echo "sing-box stopped"
