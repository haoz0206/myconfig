#!/bin/bash
set -e

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

# ====================================
# Helpers
# ====================================
link_file() {
    local src="$1" dst="$2"
    if [ -L "$dst" ]; then
        local current
        current=$(readlink "$dst" 2>/dev/null || true)
        if [ "$current" = "$src" ]; then
            echo "  [ok] $dst -> $src"
            return
        fi
        echo "  [update] $dst -> $src (was $current)"
        ln -sf "$src" "$dst"
    elif [ -e "$dst" ]; then
        echo "  [skip] $dst already exists (not a symlink, backup manually)"
    else
        ln -s "$src" "$dst"
        echo "  [link] $dst -> $src"
    fi
}

inject_source() {
    local line="$1" rcfile="$2"
    if [ -f "$rcfile" ] && grep -qF "$line" "$rcfile"; then
        echo "  [ok] $rcfile already sources config"
    else
        echo "$line" >> "$rcfile"
        echo "  [add] source line -> $rcfile"
    fi
}

# ====================================
# Main
# ====================================
echo "myconfig setup ($SCRIPT_DIR)"
echo ""

# -- Symlinks --
echo "[1/4] Linking config files..."
mkdir -p ~/.config
link_file "$SCRIPT_DIR/starship.toml" ~/.config/starship.toml
link_file "$SCRIPT_DIR/tmux.conf" ~/.tmux.conf

# -- Shell integration --
echo "[2/4] Shell integration..."
inject_source "source $SCRIPT_DIR/zshrc"  ~/.zshrc
inject_source "source $SCRIPT_DIR/bashrc" ~/.bashrc

# -- Machine-specific local.sh --
echo "[3/4] Machine-specific config..."
if [ ! -f "$SCRIPT_DIR/local.sh" ]; then
    read -p "  Proxy IP [127.0.0.1]: " proxy_ip
    proxy_ip="${proxy_ip:-127.0.0.1}"
    read -p "  Proxy port [12421]: " proxy_port
    proxy_port="${proxy_port:-12421}"
    sed "s/PROXY_IP=.*/PROXY_IP=${proxy_ip}/" "$SCRIPT_DIR/local.sh.example" \
      | sed "s/PROXY_PORT=.*/PROXY_PORT=${proxy_port}/" \
      > "$SCRIPT_DIR/local.sh"
    echo "  [new] Created local.sh (proxy=${proxy_ip}:${proxy_port})"
else
    echo "  [ok] local.sh exists"
fi

# -- Optional tool installs --
echo "[4/4] Optional tools..."

if ! command -v starship &>/dev/null; then
    read -p "  Install starship? (y/n) " -n 1 -r; echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        curl -sS https://starship.rs/install.sh | sh
    fi
else
    echo "  [ok] starship installed"
fi

if ! command -v uv &>/dev/null; then
    read -p "  Install uv? (y/n) " -n 1 -r; echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        curl -LsSf https://astral.sh/uv/install.sh | sh
    fi
else
    echo "  [ok] uv installed"
fi

echo ""
echo "Done! Restart your shell or run: source ~/.zshrc"
