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
echo "[1/5] Linking config files..."
mkdir -p ~/.config
link_file "$SCRIPT_DIR/starship.toml" ~/.config/starship.toml
link_file "$SCRIPT_DIR/tmux.conf" ~/.tmux.conf

# -- Shell integration --
echo "[2/5] Shell integration..."
inject_source "source $SCRIPT_DIR/zshrc"  ~/.zshrc
inject_source "source $SCRIPT_DIR/bashrc" ~/.bashrc

# -- Machine-specific local.sh --
echo "[3/5] Machine-specific config..."
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

# -- Zinit (zsh plugin manager) --
echo "[4/5] Zinit plugin manager..."
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
if [ -d "$ZINIT_HOME" ]; then
    echo "  [ok] zinit installed"
else
    echo "  [install] Cloning zinit..."
    mkdir -p "$(dirname "$ZINIT_HOME")"
    git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
    echo "  [ok] zinit installed (plugins will load on first zsh launch)"
fi

# -- Optional tool installs --
echo "[5/5] Optional tools..."

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
echo "Done! Restart your shell or run: source ~/.zshrc"
