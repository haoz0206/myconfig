#!/bin/bash

PID_FILE="/tmp/sing-box.pid"
LOG_FILE="/tmp/sing-box.log"
CONFIG_DIR="$HOME/.config/sing-box"

echo "========================================"
echo "sing-box Status"
echo "========================================"

# Process
echo "1. Process:"
if [ -f "$PID_FILE" ]; then
    PID=$(cat "$PID_FILE")
    if kill -0 "$PID" 2>/dev/null; then
        echo "   Running (PID: $PID)"
        echo "   Memory: $(ps -o rss= -p "$PID" | awk '{print int($1/1024) " MB"}')"
    else
        echo "   NOT running (stale PID file)"
    fi
else
    # Check if running via systemd
    if systemctl is-active --quiet sing-box 2>/dev/null; then
        echo "   Running (via systemd)"
        systemctl status sing-box --no-pager -l 2>/dev/null | head -5 | sed 's/^/   /'
    else
        echo "   NOT running"
    fi
fi

# TUN device
echo ""
echo "2. TUN Device:"
if ip link show sing-box-tun 2>/dev/null | grep -q UP; then
    echo "   sing-box-tun: UP"
elif ip link 2>/dev/null | grep -q "tun"; then
    echo "   TUN interfaces found:"
    ip link 2>/dev/null | grep "tun" | sed 's/^/   /'
else
    echo "   No TUN device found"
fi

# Routes
echo ""
echo "3. Routes via TUN:"
ip route 2>/dev/null | grep -i "sing-box\|172\.19\.0" | while read -r route; do
    echo "   $route"
done

# DNS
echo ""
echo "4. DNS Test:"
if command -v dig &>/dev/null; then
    RESULT=$(dig +short +timeout=3 google.com 2>/dev/null | head -1)
    if [ -n "$RESULT" ]; then
        echo "   google.com -> $RESULT"
    else
        echo "   DNS resolution failed"
    fi
else
    echo "   (dig not installed, skipping)"
fi

# Connectivity
echo ""
echo "5. Connectivity:"
if curl -s --connect-timeout 5 -o /dev/null -w "%{http_code}" https://www.google.com 2>/dev/null | grep -q "200\|301\|302"; then
    echo "   Proxy working (google.com reachable)"
else
    echo "   Cannot reach google.com"
fi

# Config
echo ""
echo "6. Config: $CONFIG_DIR/config.json"
if [ -f "$CONFIG_DIR/config.json" ]; then
    echo "   [ok] exists"
else
    echo "   [missing]"
fi

# Recent logs
if [ -f "$LOG_FILE" ]; then
    echo ""
    echo "7. Recent Logs:"
    tail -5 "$LOG_FILE" | sed 's/^/   /'
fi

echo ""
echo "========================================"
