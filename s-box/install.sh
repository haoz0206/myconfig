#!/bin/bash
set -e

# ====================================
# sing-box installer (Linux only)
# Downloads the latest release and sets up systemd service
# Tries GitHub first, falls back to Chinese mirrors
# ====================================

INSTALL_DIR="$HOME/.local/bin"
CONFIG_DIR="$HOME/.config/sing-box"
SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

# GitHub mirror list (tried in order if GitHub is blocked)
MIRRORS=(
    "https://github.com"
    "https://ghgo.xyz/https://github.com"
    "https://mirror.ghproxy.com/https://github.com"
    "https://gh-proxy.com/https://github.com"
)

# ====================================
# Detect platform
# ====================================
OS=$(uname -s | tr '[:upper:]' '[:lower:]')
ARCH=$(uname -m)

if [ "$OS" != "linux" ]; then
    echo "Error: This script is for Linux only"
    exit 1
fi

case "$ARCH" in
    x86_64)  ARCH="amd64" ;;
    aarch64) ARCH="arm64" ;;
    armv7l)  ARCH="armv7" ;;
    *)
        echo "Error: Unsupported architecture: $ARCH"
        exit 1
        ;;
esac

# ====================================
# Helper: download with mirror fallback
# ====================================
download() {
    local path="$1" dest="$2"
    for base in "${MIRRORS[@]}"; do
        local url="${base}${path}"
        echo "  Trying: $url"
        if curl -sL --connect-timeout 10 --max-time 120 -o "$dest" "$url" && [ -s "$dest" ]; then
            echo "  [ok] Downloaded from $base"
            return 0
        fi
        rm -f "$dest"
    done
    return 1
}

# ====================================
# Get latest version
# ====================================
echo "[1/4] Fetching latest sing-box version..."

# Try GitHub API first, then fall back to mirrors
for base in "${MIRRORS[@]}"; do
    api_url="${base}/SagerNet/sing-box/releases/latest"
    LATEST=$(curl -sL --connect-timeout 10 "$api_url" \
        | grep '"tag_name"' | head -1 | sed 's/.*"v\(.*\)".*/\1/')
    if [ -n "$LATEST" ]; then
        break
    fi
done

if [ -z "$LATEST" ]; then
    echo "  Warning: Cannot fetch latest version from any source"
    if [ -z "$SINGBOX_VERSION" ]; then
        echo "  Specify manually: SINGBOX_VERSION=1.11.0 $0"
        exit 1
    fi
fi

VERSION="${SINGBOX_VERSION:-$LATEST}"
echo "  Version: $VERSION"

# ====================================
# Check if already installed
# ====================================
if command -v sing-box &>/dev/null; then
    CURRENT=$(sing-box version 2>/dev/null | head -1 | awk '{print $NF}')
    if [ "$CURRENT" = "$VERSION" ]; then
        echo "  [ok] sing-box $VERSION already installed"
        exit 0
    fi
    echo "  Upgrading: $CURRENT -> $VERSION"
fi

# ====================================
# Download and install
# ====================================
echo "[2/4] Downloading sing-box $VERSION (linux/$ARCH)..."
TARBALL="sing-box-${VERSION}-linux-${ARCH}.tar.gz"
RELEASE_PATH="/SagerNet/sing-box/releases/download/v${VERSION}/${TARBALL}"

TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPDIR"' EXIT

if ! download "$RELEASE_PATH" "$TMPDIR/$TARBALL"; then
    echo "Error: Download failed from all sources"
    echo "You can download manually and place it at: $INSTALL_DIR/sing-box"
    exit 1
fi

echo "[3/4] Installing to $INSTALL_DIR..."
mkdir -p "$INSTALL_DIR"
tar -xzf "$TMPDIR/$TARBALL" -C "$TMPDIR"
cp "$TMPDIR/sing-box-${VERSION}-linux-${ARCH}/sing-box" "$INSTALL_DIR/sing-box"
chmod +x "$INSTALL_DIR/sing-box"

# Verify
if ! "$INSTALL_DIR/sing-box" version &>/dev/null; then
    echo "Error: Installation verification failed"
    exit 1
fi

echo "  [ok] sing-box installed to $INSTALL_DIR/sing-box"

# ====================================
# Setup config directory
# ====================================
echo "[4/4] Setting up config directory..."
mkdir -p "$CONFIG_DIR"

if [ ! -f "$CONFIG_DIR/config.json" ]; then
    cp "$SCRIPT_DIR/config.json.example" "$CONFIG_DIR/config.json"
    echo "  [new] Created $CONFIG_DIR/config.json from template"
    echo "  >>> Edit $CONFIG_DIR/config.json with your server details <<<"
else
    echo "  [ok] $CONFIG_DIR/config.json exists (preserved)"
fi

echo ""
echo "========================================"
echo " sing-box $VERSION installed successfully"
echo "========================================"
echo ""
echo " IMPORTANT: You must edit the config before starting!"
echo ""
echo " The default config is a TEMPLATE. You need to replace it"
echo " with your actual sing-box client config (outbound server,"
echo " protocol, ports, etc.)."
echo ""
echo " Step 1 - Edit config:"
echo ""
echo "   vim $CONFIG_DIR/config.json"
echo ""
echo "   Key fields to update:"
echo "     - outbounds[0].server      -> your server IP"
echo "     - outbounds[0].server_port -> your server port"
echo "     - outbounds[0].type        -> your protocol (socks/shadowsocks/vmess/...)"
echo "     - Add auth fields as needed (password, uuid, etc.)"
echo ""
echo " Step 2 - Validate config:"
echo ""
echo "   sing-box check -c $CONFIG_DIR/config.json"
echo ""
echo " Step 3 - Start sing-box (pick one):"
echo ""
echo "   $SCRIPT_DIR/start.sh                 # manual start"
echo "   sudo $SCRIPT_DIR/install-service.sh  # systemd (auto-start on boot)"
echo ""
echo " After starting:"
echo ""
echo "   $SCRIPT_DIR/status.sh                # check status"
echo "   tun                                  # quick toggle on/off"
echo ""
echo "========================================"
