#!/bin/bash
set -e

CONFIG_DIR="$HOME/.config/sing-box"
PID_FILE="/tmp/sing-box.pid"
LOG_FILE="/tmp/sing-box.log"

if [ ! -f "$CONFIG_DIR/config.json" ]; then
    echo "Error: Config not found at $CONFIG_DIR/config.json"
    echo "Run install.sh first or copy config.json.example"
    exit 1
fi

# Check if already running
if [ -f "$PID_FILE" ]; then
    PID=$(cat "$PID_FILE")
    if kill -0 "$PID" 2>/dev/null; then
        echo "sing-box is already running (PID: $PID)"
        exit 1
    fi
    rm -f "$PID_FILE"
fi

# Validate config
echo "Checking config..."
if ! sing-box check -c "$CONFIG_DIR/config.json"; then
    echo "Error: Invalid config"
    exit 1
fi

# TUN requires root
echo "Starting sing-box (TUN mode requires root)..."
sudo sing-box run -c "$CONFIG_DIR/config.json" > "$LOG_FILE" 2>&1 &
SBOX_PID=$!
echo "$SBOX_PID" > "$PID_FILE"

sleep 2

if ! kill -0 "$SBOX_PID" 2>/dev/null; then
    echo "Error: sing-box failed to start"
    echo "Last log:"
    tail -20 "$LOG_FILE"
    rm -f "$PID_FILE"
    exit 1
fi

echo "sing-box started (PID: $SBOX_PID)"
echo "Log: $LOG_FILE"
