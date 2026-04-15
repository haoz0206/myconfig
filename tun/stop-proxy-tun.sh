#!/bin/bash
set -e

TUN_DEVICE="tun_proxy"
PID_FILE="/tmp/tun2socks.pid"
ADDED_ROUTES_FILE="/tmp/tun2socks_added_routes"

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
    sudo ip route del default via "$GW" dev "$DEV" 2>/dev/null
    sudo ip route add default via "$GW" dev "$DEV"

    rm -f /tmp/tun2socks_gw /tmp/tun2socks_dev
    echo "✓ Default route restored"
fi

# 清理启动时添加的直连路由
if [ -f "$ADDED_ROUTES_FILE" ]; then
    while IFS= read -r NETWORK; do
        [ -z "$NETWORK" ] && continue
        sudo ip route del "$NETWORK" 2>/dev/null && \
            echo "✓ Removed route $NETWORK"
    done < "$ADDED_ROUTES_FILE"
    rm -f "$ADDED_ROUTES_FILE"
fi

# 删除 TUN 设备
if ip link show "$TUN_DEVICE" &>/dev/null; then
    sudo ip link set dev "$TUN_DEVICE" down
    sudo ip tuntap del mode tun dev "$TUN_DEVICE"
    echo "✓ TUN device removed"
fi

echo "✓ Global proxy stopped"
ip route show default
