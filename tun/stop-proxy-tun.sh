#!/bin/bash
set -e

TUN_DEVICE="tun_proxy"
PID_FILE="/tmp/tun2socks.pid"

echo "Stopping global proxy..."

# 停止 tun2socks
if [ -f "$PID_FILE" ]; then
    PID=$(cat "$PID_FILE")
    sudo kill "$PID" 2>/dev/null
    sleep 2
    sudo kill -9 "$PID" 2>/dev/null
    rm -f "$PID_FILE"
fi
sudo pkill -9 tun2socks

# 恢复路由
if [ -f /tmp/tun2socks_gw ] && [ -f /tmp/tun2socks_dev ]; then
    GW=$(cat /tmp/tun2socks_gw)
    DEV=$(cat /tmp/tun2socks_dev)

    sudo ip route del default 2>/dev/null
    sudo ip route add default via "$GW" dev "$DEV"

    rm -f /tmp/tun2socks_gw /tmp/tun2socks_dev
    echo "✓ Default route restored"
fi

# 删除 TUN 设备
if ip link show "$TUN_DEVICE" &>/dev/null; then
    sudo ip link set dev "$TUN_DEVICE" down
    sudo ip tuntap del mode tun dev "$TUN_DEVICE"
    echo "✓ TUN device removed"
fi

echo "✓ Global proxy stopped"
ip route show default
