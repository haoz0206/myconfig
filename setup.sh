#!/bin/bash
set -e

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
DEPLOY_DIR="$HOME/.myconfig"

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
        # Remove old source lines pointing to this repo or previous deploy dir
        if [ -f "$rcfile" ]; then
            sed -i.bak '/source.*myconfig/d' "$rcfile"
            rm -f "$rcfile.bak"
        fi
        echo "$line" >> "$rcfile"
        echo "  [add] source line -> $rcfile"
    fi
}

# ====================================
# Main
# ====================================
echo "myconfig setup ($SCRIPT_DIR -> $DEPLOY_DIR)"
echo ""

# -- Deploy config files --
echo "[1/5] Deploying config files to $DEPLOY_DIR..."
mkdir -p "$DEPLOY_DIR"
for f in zshrc shell_common.sh starship.toml tmux.conf; do
    if [ ! -f "$SCRIPT_DIR/$f" ]; then
        echo "  [error] Missing required file: $f"
        exit 1
    fi
    cp "$SCRIPT_DIR/$f" "$DEPLOY_DIR/$f"
    echo "  [copy] $f"
done
if [ -d "$SCRIPT_DIR/s-box" ]; then
    cp -r "$SCRIPT_DIR/s-box" "$DEPLOY_DIR/s-box"
    chmod +x "$DEPLOY_DIR/s-box/"*.sh
    echo "  [copy] s-box/"
fi

# -- Symlinks from standard locations --
echo "[2/5] Linking config files..."
mkdir -p ~/.config
link_file "$DEPLOY_DIR/starship.toml" ~/.config/starship.toml
link_file "$DEPLOY_DIR/tmux.conf" ~/.tmux.conf

# -- Shell integration --
echo "[3/5] Shell integration..."
inject_source "source $DEPLOY_DIR/zshrc"  ~/.zshrc

# -- Machine-specific local.sh --
echo "[4/5] Machine-specific config..."
if [ ! -f "$DEPLOY_DIR/local.sh" ]; then
    read -p "  Proxy IP [127.0.0.1]: " proxy_ip
    proxy_ip="${proxy_ip:-127.0.0.1}"
    read -p "  Proxy port [12421]: " proxy_port
    proxy_port="${proxy_port:-12421}"
    if ! [[ "$proxy_ip" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        echo "  [error] Invalid IP address: $proxy_ip"
        exit 1
    fi
    if ! [[ "$proxy_port" =~ ^[0-9]+$ ]] || [ "$proxy_port" -gt 65535 ]; then
        echo "  [error] Invalid port: $proxy_port (must be 1-65535)"
        exit 1
    fi
    sed "s/PROXY_IP=.*/PROXY_IP=${proxy_ip}/" "$SCRIPT_DIR/local.sh.example" \
      | sed "s/PROXY_PORT=.*/PROXY_PORT=${proxy_port}/" \
      > "$DEPLOY_DIR/local.sh"
    echo "  [new] Created local.sh (proxy=${proxy_ip}:${proxy_port})"
else
    echo "  [ok] local.sh exists (preserved)"
fi

# -- Optional tool installs --
echo "[5/5] Optional tools..."

# Zinit
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
if [ -d "$ZINIT_HOME" ]; then
    echo "  [ok] zinit installed"
else
    echo "  [install] Cloning zinit..."
    mkdir -p "$(dirname "$ZINIT_HOME")"
    git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
    echo "  [ok] zinit installed (plugins will load on first zsh launch)"
fi

# Starship
if ! command -v starship &>/dev/null; then
    read -p "  Install starship? (y/n) " -n 1 -r; echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        mkdir -p "$HOME/.local/bin"
        curl -sS https://starship.rs/install.sh | sh -s -- --bin-dir "$HOME/.local/bin" -y
    fi
else
    echo "  [ok] starship installed"
fi

# uv
if ! command -v uv &>/dev/null; then
    read -p "  Install uv? (y/n) " -n 1 -r; echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        curl -LsSf https://astral.sh/uv/install.sh | sh
    fi
else
    echo "  [ok] uv installed"
fi

# fzf
if ! command -v fzf &>/dev/null; then
    read -p "  Install fzf? (y/n) " -n 1 -r; echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        if command -v brew &>/dev/null; then
            brew install fzf
        else
            git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf && ~/.fzf/install --no-bash --no-fish --key-bindings --completion --update-rc
        fi
    fi
else
    echo "  [ok] fzf installed"
fi

# zoxide
if ! command -v zoxide &>/dev/null; then
    read -p "  Install zoxide? (y/n) " -n 1 -r; echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        if command -v brew &>/dev/null; then
            brew install zoxide
        else
            curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh
        fi
    fi
else
    echo "  [ok] zoxide installed"
fi

echo ""
echo "Done! Config deployed to $DEPLOY_DIR"
echo "Restart your shell or run: source ~/.zshrc"
