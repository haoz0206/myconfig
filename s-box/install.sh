#!/bin/bash
set -e

# ====================================
# sing-box installer (Linux only)
# Downloads the latest release and sets up systemd service
# ====================================

INSTALL_DIR="$HOME/.local/bin"
CONFIG_DIR="$HOME/.config/sing-box"
SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

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
# Get latest version
# ====================================
echo "[1/4] Fetching latest sing-box version..."
LATEST=$(curl -sL "https://api.github.com/repos/SagerNet/sing-box/releases/latest" \
    | grep '"tag_name"' | head -1 | sed 's/.*"v\(.*\)".*/\1/')

if [ -z "$LATEST" ]; then
    echo "Error: Failed to fetch latest version"
    echo "You can specify a version manually: SINGBOX_VERSION=1.11.0 $0"
    exit 1
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
        echo "  Run: $SCRIPT_DIR/setup.sh to configure"
        exit 0
    fi
    echo "  Upgrading: $CURRENT -> $VERSION"
fi

# ====================================
# Download and install
# ====================================
echo "[2/4] Downloading sing-box $VERSION (linux/$ARCH)..."
TARBALL="sing-box-${VERSION}-linux-${ARCH}.tar.gz"
URL="https://github.com/SagerNet/sing-box/releases/download/v${VERSION}/${TARBALL}"

TMPDIR=$(mktemp -d)
trap "rm -rf $TMPDIR" EXIT

curl -sL -o "$TMPDIR/$TARBALL" "$URL"

if [ ! -s "$TMPDIR/$TARBALL" ]; then
    echo "Error: Download failed"
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
echo "sing-box $VERSION installed!"
echo "========================================"
echo ""
echo "Next steps:"
echo "  1. Edit config:   vim $CONFIG_DIR/config.json"
echo "  2. Test config:   sing-box check -c $CONFIG_DIR/config.json"
echo "  3. Start:         $SCRIPT_DIR/start.sh"
echo "  4. Status:        $SCRIPT_DIR/status.sh"
echo "  5. Stop:          $SCRIPT_DIR/stop.sh"
echo ""
echo "For systemd service (auto-start on boot):"
echo "  sudo $SCRIPT_DIR/install-service.sh"
echo "========================================"
