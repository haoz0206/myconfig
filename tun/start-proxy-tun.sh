#!/bin/bash
set -e

#######################
# 配置参数
#######################
SOCKS5_SERVER="127.0.0.1"        # 本地 SOCKS5 客户端监听地址
SOCKS5_PORT="12421"              # SOCKS5 端口
TUN_DEVICE="tun_proxy"
TUN_IP="10.10.0.1"
TUN_GATEWAY="10.10.0.2"

# !!! 重要：必须把本地代理客户端连接的远端 VPS IP 加入下面的列表 !!!
# 否则客户端访问远端的流量会被默认路由送回 TUN -> tun2socks -> 127.0.0.1:12421 -> 回环死循环
# 例:  "198.51.100.42/32"   # 远端代理服务器
REMOTE_PROXY_SERVERS=(
    # "1.2.3.4/32"         # <-- 填入你的远端服务器 IP
)

# 不走代理的网段（保持直连）
EXCLUDED_NETWORKS=(
    "${REMOTE_PROXY_SERVERS[@]}"
    "10.126.126.0/24"      # EasyTier 网段
    "10.71.106.0/24"       # EasyTier 另一个网段
    "172.29.128.0/20"      # 本地局域网
    "127.0.0.0/8"          # 本地回环
    "169.254.0.0/16"       # 链路本地
    "224.0.0.0/4"          # 组播
    "240.0.0.0/4"          # 保留
)

LOG_FILE="/tmp/tun2socks.log"
PID_FILE="/tmp/tun2socks.pid"
ADDED_ROUTES_FILE="/tmp/tun2socks_added_routes"

#######################
# 检查是否已运行
#######################
if [ -f "$PID_FILE" ]; then
    PID=$(cat "$PID_FILE")
    if kill -0 "$PID" 2>/dev/null; then
        echo "Error: tun2socks is already running (PID: $PID)"
        exit 1
    fi
    rm -f "$PID_FILE"
fi

#######################
# 创建 TUN 设备
#######################
echo "Creating TUN device: $TUN_DEVICE"
if ip link show $TUN_DEVICE &>/dev/null; then
    sudo ip link set dev $TUN_DEVICE down
    sudo ip tuntap del mode tun dev $TUN_DEVICE
fi

sudo ip tuntap add mode tun dev $TUN_DEVICE
sudo ip addr add $TUN_IP/24 dev $TUN_DEVICE
sudo ip link set dev $TUN_DEVICE up

if ! ip link show $TUN_DEVICE &>/dev/null; then
    echo "Error: Failed to create TUN device"
    exit 1
fi
echo "✓ TUN device created"

#######################
# 启动 tun2socks
#######################
echo "Starting tun2socks..."
> $LOG_FILE

TUN2SOCKS_BIN=$(command -v tun2socks 2>/dev/null || echo "$HOME/go/bin/tun2socks")
if [ ! -x "$TUN2SOCKS_BIN" ]; then
    echo "Error: tun2socks not found. Install it first (see README.md)"
    exit 1
fi

nohup sudo "$TUN2SOCKS_BIN" \
    -device "$TUN_DEVICE" \
    -proxy "socks5://$SOCKS5_SERVER:$SOCKS5_PORT" \
    -loglevel info \
    >> "$LOG_FILE" 2>&1 &

TUN2SOCKS_PID=$!
echo "$TUN2SOCKS_PID" > "$PID_FILE"
sleep 3

if ! kill -0 "$TUN2SOCKS_PID" 2>/dev/null; then
    echo "Error: tun2socks failed to start"
    cat "$LOG_FILE"
    exit 1
fi
echo "✓ tun2socks running (PID: $TUN2SOCKS_PID)"

#######################
# 配置路由
#######################
echo "Configuring global proxy routing..."

# 保存原始默认网关
ORIGINAL_GW=$(ip route show default | awk '/default/ {print $3}')
ORIGINAL_DEV=$(ip route show default | awk '/default/ {print $5}')

if [ -z "$ORIGINAL_GW" ]; then
    echo "Error: Cannot find default gateway"
    exit 1
fi

echo "Original gateway: $ORIGINAL_GW via $ORIGINAL_DEV"
echo "$ORIGINAL_GW" > /tmp/tun2socks_gw
echo "$ORIGINAL_DEV" > /tmp/tun2socks_dev
: > "$ADDED_ROUTES_FILE"

# SOCKS5 代理的流量直连（避免循环）
if [ "$SOCKS5_SERVER" != "127.0.0.1" ] && [ "$SOCKS5_SERVER" != "localhost" ]; then
    sudo ip route add $SOCKS5_SERVER/32 via $ORIGINAL_GW dev $ORIGINAL_DEV
    echo "$SOCKS5_SERVER/32" >> "$ADDED_ROUTES_FILE"
    echo "✓ SOCKS5 server route added"
fi

# 排除的网段保持原路由
for NETWORK in "${EXCLUDED_NETWORKS[@]}"; do
    # 检查该网段是否已有路由，如果有就跳过
    if ip route show exact $NETWORK | grep -q .; then
        echo "✓ Keeping existing route for $NETWORK"
    else
        if sudo ip route add $NETWORK via $ORIGINAL_GW dev $ORIGINAL_DEV 2>/dev/null; then
            echo "$NETWORK" >> "$ADDED_ROUTES_FILE"
            echo "✓ Added direct route for $NETWORK"
        fi
    fi
done

# 修改默认路由
sudo ip route del default
sudo ip route add default via $TUN_GATEWAY dev $TUN_DEVICE metric 1

# 添加备用路由（如果代理失败，可以回退）
sudo ip route add default via $ORIGINAL_GW dev $ORIGINAL_DEV metric 100

echo ""
echo "========================================"
echo "Global Proxy Enabled!"
echo "========================================"
echo "✓ All traffic goes through SOCKS5 proxy"
echo "✓ Excluded networks:"
for NETWORK in "${EXCLUDED_NETWORKS[@]}"; do
    echo "  - $NETWORK"
done
echo ""
echo "Commands:"
echo "  Status:  ./status-proxy-tun.sh"
echo "  Stop:    sudo ./stop-proxy-tun.sh"
echo "========================================"
