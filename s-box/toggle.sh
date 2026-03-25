#!/bin/bash

# Quick toggle for sing-box TUN proxy
# Usage: ./toggle.sh [on|off]

PID_FILE="/tmp/sing-box.pid"
SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

is_running() {
    if systemctl is-active --quiet sing-box 2>/dev/null; then
        return 0
    elif [ -f "$PID_FILE" ] && kill -0 "$(cat "$PID_FILE")" 2>/dev/null; then
        return 0
    fi
    return 1
}

case "${1:-}" in
    on)  ACTION="on" ;;
    off) ACTION="off" ;;
    "")
        # No argument: toggle
        if is_running; then
            ACTION="off"
        else
            ACTION="on"
        fi
        ;;
    *)
        echo "Usage: $0 [on|off]"
        exit 1
        ;;
esac

if [ "$ACTION" = "on" ]; then
    if is_running; then
        echo "sing-box already running"
        exit 0
    fi
    if systemctl is-enabled --quiet sing-box 2>/dev/null; then
        sudo systemctl start sing-box
    else
        "$SCRIPT_DIR/start.sh"
    fi
    echo "TUN proxy ON"
else
    if ! is_running; then
        echo "sing-box already stopped"
        exit 0
    fi
    if systemctl is-enabled --quiet sing-box 2>/dev/null; then
        sudo systemctl stop sing-box
    else
        "$SCRIPT_DIR/stop.sh"
    fi
    echo "TUN proxy OFF"
fi
