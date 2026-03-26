# TUN Proxy via tun2socks

A clean implementation of global traffic proxying through a TUN device on Linux.
Routes all network traffic through a SOCKS5 proxy at the kernel level using
[tun2socks](https://github.com/xjasonlyu/tun2socks).

> **Note:** For most use cases, the `s-box/` (sing-box) approach is recommended
> instead, as it handles TUN creation, routing, and DNS automatically. This
> directory is kept as a reference implementation for manual TUN device setup.

## Prerequisites

- Linux with `ip` (iproute2) installed
- A running SOCKS5 proxy server
- Root access (sudo)

## Install tun2socks

### Option 1: Download prebuilt binary

```bash
# Check latest release at https://github.com/xjasonlyu/tun2socks/releases
VERSION="2.5.2"
ARCH="amd64"  # or arm64

curl -Lo tun2socks.gz \
    "https://github.com/xjasonlyu/tun2socks/releases/download/v${VERSION}/tun2socks-linux-${ARCH}.gz"
gunzip tun2socks.gz
chmod +x tun2socks
mv tun2socks ~/.local/bin/
```

### Option 2: Build from source (requires Go)

```bash
go install github.com/xjasonlyu/tun2socks/v2@latest
# Binary will be at ~/go/bin/tun2socks
```

### Verify

```bash
tun2socks --version
```

## Configuration

Edit the variables at the top of `start-proxy-tun.sh`:

```bash
SOCKS5_SERVER="10.126.126.6"   # Your SOCKS5 proxy address
SOCKS5_PORT="12421"            # Your SOCKS5 proxy port
TUN_DEVICE="tun_proxy"         # TUN device name
TUN_IP="10.10.0.1"             # TUN device IP
TUN_GATEWAY="10.10.0.2"        # TUN gateway IP
```

Add any networks that should bypass the proxy to `EXCLUDED_NETWORKS`.

## Usage

```bash
# Start global proxy
sudo ./start-proxy-tun.sh

# Check status
./status-proxy-tun.sh

# Stop and restore original routing
sudo ./stop-proxy-tun.sh
```

## How It Works

1. Creates a TUN device (`tun_proxy`)
2. Starts `tun2socks` to forward TUN traffic to the SOCKS5 proxy
3. Saves the original default gateway
4. Adds direct routes for excluded networks (local, proxy server itself)
5. Replaces the default route to go through the TUN device
6. On stop: kills tun2socks, restores original routes, removes TUN device
