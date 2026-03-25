#!/bin/bash
set -e

# ====================================
# Install sing-box as a systemd user service
# Runs as root (TUN requires elevated privileges)
# ====================================

CONFIG_DIR="$HOME/.config/sing-box"
SINGBOX_BIN=$(command -v sing-box 2>/dev/null || echo "$HOME/.local/bin/sing-box")

if [ ! -x "$SINGBOX_BIN" ]; then
    echo "Error: sing-box not found. Run install.sh first."
    exit 1
fi

if [ ! -f "$CONFIG_DIR/config.json" ]; then
    echo "Error: Config not found at $CONFIG_DIR/config.json"
    exit 1
fi

# Validate config first
if ! "$SINGBOX_BIN" check -c "$CONFIG_DIR/config.json"; then
    echo "Error: Invalid config"
    exit 1
fi

REAL_USER=$(logname 2>/dev/null || echo "$SUDO_USER")
REAL_HOME=$(eval echo "~$REAL_USER")

echo "Installing systemd service..."

sudo tee /etc/systemd/system/sing-box.service > /dev/null <<EOF
[Unit]
Description=sing-box proxy client
After=network.target
Wants=network-online.target

[Service]
Type=simple
ExecStart=$SINGBOX_BIN run -c $CONFIG_DIR/config.json
ExecReload=/bin/kill -HUP \$MAINPID
Restart=on-failure
RestartSec=5
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable sing-box
sudo systemctl start sing-box

sleep 2

if systemctl is-active --quiet sing-box; then
    echo ""
    echo "sing-box service installed and running!"
    echo ""
    echo "Commands:"
    echo "  sudo systemctl status sing-box    # status"
    echo "  sudo systemctl restart sing-box   # restart"
    echo "  sudo systemctl stop sing-box      # stop"
    echo "  sudo systemctl disable sing-box   # disable auto-start"
    echo "  journalctl -u sing-box -f         # follow logs"
else
    echo ""
    echo "Error: Service failed to start"
    echo "Check: sudo journalctl -u sing-box -n 20"
    exit 1
fi
