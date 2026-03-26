# ====================================
# Shared shell config (sourced by zshrc)
# ====================================

# -- PATH --
export PATH="$HOME/.local/bin:$PATH"

# -- 真彩色支持 --
# SSH 不会传递 COLORTERM，导致远程 TUI 工具降级到 256 色
if [ -n "$SSH_TTY" ] && [ -z "$COLORTERM" ]; then
  case "$TERM" in
    xterm-ghostty|xterm-256color|alacritty) export COLORTERM=truecolor ;;
  esac
fi

# -- 代理 --
export PROXY=OFF
proxy() {
    local addr="${PROXY_IP:-127.0.0.1}:${PROXY_PORT:-12421}"
    export https_proxy="http://$addr" http_proxy="http://$addr" all_proxy="socks5://$addr"
    export PROXY=ON
}
noproxy() {
    unset https_proxy http_proxy all_proxy
    export PROXY=OFF
}

# -- 镜像源 --
export tsmirror=https://pypi.tuna.tsinghua.edu.cn/simple
export zju=https://mirrors.zju.edu.cn/pypi/web/simple
export HF_ENDPOINT=https://hf-mirror.com

# -- sing-box TUN toggle (Linux only) --
MYCONFIG_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"
if [ "$(uname)" = "Linux" ] && [ -f "$MYCONFIG_DIR/s-box/toggle.sh" ]; then
    alias tun="$MYCONFIG_DIR/s-box/toggle.sh"
fi

# -- Machine-specific overrides --
if [ -f "$MYCONFIG_DIR/local.sh" ]; then
    source "$MYCONFIG_DIR/local.sh"
fi
