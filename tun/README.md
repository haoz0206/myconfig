# TUN Proxy via tun2socks

Experimental Linux scripts for routing IPv4 traffic through a TUN device and
[tun2socks](https://github.com/xjasonlyu/tun2socks). This is a reference, not a
fully automated or production-ready network setup.

> **Warning:** These scripts are experimental and modify the system default route.
> They do not reliably restore every routing configuration or recover from every
> failure. Do not run them on a remote machine without independent console access.
> They are not installed or run by the main setup script.

## Prerequisites

- Linux with `ip` (iproute2) installed
- A running SOCKS5 proxy server
- Root access (sudo)

## tun2socks dependency

The scripts require an existing `tun2socks` executable. Homebrew does not
currently provide a core formula for it; the main setup does not install it.
Choose and verify a suitable installation method before experimenting.

## Configuration

Edit the variables at the top of `start-proxy-tun.sh`:

```bash
SOCKS5_SERVER="127.0.0.1"      # Your SOCKS5 proxy address
SOCKS5_PORT="12421"            # Your SOCKS5 proxy port
TUN_DEVICE="tun_proxy"         # TUN device name
TUN_IP="10.10.0.1"             # TUN device IP
TUN_GATEWAY="10.10.0.2"        # TUN gateway IP
```

Add any networks that should bypass the proxy to `EXCLUDED_NETWORKS`. For a local SOCKS5 client, populate `REMOTE_PROXY_SERVERS` with its upstream server addresses; the start script refuses to run without them.

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
6. On stop: attempts to stop the recorded process, restore routes, and remove the TUN device; manual recovery may be required
