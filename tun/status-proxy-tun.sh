#!/bin/bash
set -e

PID_FILE="/tmp/tun2socks.pid"
LOG_FILE="/tmp/tun2socks.log"
TUN_DEVICE="tun_proxy"
SOCKS5_SERVER="127.0.0.1"
SOCKS5_PORT="12421"

echo "========================================"
echo "Proxy TUN Status"
echo "========================================"

# 检查 tun2socks 进程
echo "1. tun2socks Process:"
if [ -f "$PID_FILE" ]; then
    PID=$(cat "$PID_FILE")
    if kill -0 "$PID" 2>/dev/null; then
        echo "   ✓ Running (PID: $PID)"
        echo "   Memory: $(ps -o rss= -p "$PID" | awk '{print int($1/1024) " MB"}')"
        echo "   CPU: $(ps -o %cpu= -p "$PID")%"
    else
        echo "   ✗ NOT running (stale PID file)"
    fi
else
    echo "   ✗ NOT running"
fi

# 检查 TUN 设备
echo ""
echo "2. TUN Devices:"
if ip link show "$TUN_DEVICE" &>/dev/null; then
    export PROXY=ON
    echo "   ✓ $TUN_DEVICE exists"
    ip addr show $TUN_DEVICE | grep -E "inet |state"
else
    echo "   ✗ $TUN_DEVICE not found"
fi

echo ""
echo "   EasyTier device (tun0):"
if ip link show tun0 &>/dev/null; then
    echo "   ✓ tun0 exists (EasyTier)"
    ip addr show tun0 | grep -E "inet |state"
else
    echo "   ✗ tun0 not found"
fi

# 检查路由
echo ""
echo "3. Proxy Routes:"
ip route show | grep "$TUN_DEVICE" | while read route; do
    echo "   → $route"
done

echo ""
echo "4. EasyTier Routes:"
ip route show | grep "tun0" | while read route; do
    echo "   → $route"
done

# 检查 SOCKS5 代理
echo ""
echo "5. SOCKS5 Proxy Connection:"
if nc -z "$SOCKS5_SERVER" "$SOCKS5_PORT" 2>/dev/null; then
    echo "   ✓ SOCKS5 proxy is reachable ($SOCKS5_SERVER:$SOCKS5_PORT)"
else
    echo "   ✗ SOCKS5 proxy is NOT reachable ($SOCKS5_SERVER:$SOCKS5_PORT)"
fi

# 显示最近日志
if [ -f "$LOG_FILE" ]; then
    echo ""
    echo "6. Recent Logs (last 10 lines):"
    echo "   ---"
    tail -10 "$LOG_FILE" | sed 's/^/   /'
    echo "   ---"
fi

echo ""
echo "========================================"
