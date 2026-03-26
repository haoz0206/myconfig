# myconfig

One-command setup for my development shell environment across Linux and macOS machines.

## Quick Start

```bash
git clone https://github.com/haoz0206/myconfig.git
cd myconfig
bash setup.sh
```

Then restart your shell or run `source ~/.zshrc`.

## Architecture

```
~/workspace/myconfig/          # git repo (source of truth)
        |  setup.sh copies
        v
~/.myconfig/                   # deployed config (what your shell uses)
├── zshrc                      #   <- ~/.zshrc sources this
├── bashrc                     #   <- ~/.bashrc sources this
├── shell_common.sh            #   shared config for both shells
├── starship.toml              #   <- ~/.config/starship.toml symlinks here
├── tmux.conf                  #   <- ~/.tmux.conf symlinks here
├── local.sh                   #   machine-specific overrides (not in git)
└── s-box/                     #   sing-box proxy scripts
```

Edit the repo freely during development. Run `bash setup.sh` again to redeploy.

## What setup.sh Does

1. **Copies** config files to `~/.myconfig/`
2. **Symlinks** starship and tmux configs to standard locations
3. **Injects** `source ~/.myconfig/zshrc` into `~/.zshrc` (and bashrc)
4. **Creates** `local.sh` from template (prompts for proxy IP/port)
5. **Installs** tools (all optional, interactive prompts):

| Tool | Purpose |
|------|---------|
| [zinit](https://github.com/zdharma-continuum/zinit) | Zsh plugin manager (turbo mode) |
| [starship](https://starship.rs) | Cross-shell prompt (One Dark theme) |
| [fzf](https://github.com/junegunn/fzf) | Fuzzy finder (Ctrl+R, Ctrl+T, Alt+C) |
| [zoxide](https://github.com/ajeetdsouza/zoxide) | Smart `cd` (`z foo` jumps to best match) |
| [uv](https://github.com/astral-sh/uv) | Fast Python package manager |

## Shell Features

### Proxy Toggle

```bash
proxy        # set http_proxy/https_proxy/all_proxy (reads from local.sh)
noproxy      # unset all proxy env vars
```

Proxy status shows in the starship prompt as `PROXY.ON` / `PROXY.OFF`.

### Zsh Plugins (via zinit, turbo-loaded)

- **zsh-autosuggestions** -- fish-like inline suggestions
- **zsh-completions** -- extra tab-completion definitions
- **fzf-tab** -- fuzzy Tab completion powered by fzf
- **fast-syntax-highlighting** -- real-time command coloring

### Chinese Mirrors (pre-configured)

```bash
pip install foo -i $tsmirror    # Tsinghua PyPI mirror
pip install foo -i $zju         # ZJU PyPI mirror
# HF_ENDPOINT is auto-set for huggingface-cli
```

### Other

- **Truecolor over SSH** -- auto-detects Ghostty/Alacritty/xterm-256color and sets `COLORTERM`
- **`~/.local/bin` in PATH** -- user-local binaries work without root

## Machine-Specific Config (local.sh)

Generated during setup, preserved across redeploys. Example:

```bash
PROXY_IP=127.0.0.1
PROXY_PORT=12421
proxy                           # enable proxy on shell startup
# export UV_CACHE_DIR=/data/cache/uv
```

## sing-box Proxy (Linux)

The `s-box/` directory manages [sing-box](https://github.com/SagerNet/sing-box) as a TUN proxy client:

```bash
# Install (tries GitHub, falls back to Chinese mirrors)
~/.myconfig/s-box/install.sh

# Edit config with your server details
vim ~/.config/sing-box/config.json

# Quick toggle
tun          # toggle on/off
tun on       # force on
tun off      # force off

# Or use systemd for auto-start
sudo ~/.myconfig/s-box/install-service.sh
```

### sing-box Scripts

| Script | Purpose |
|--------|---------|
| `install.sh` | Download sing-box with mirror fallback |
| `start.sh` | Start sing-box manually (TUN mode, needs root) |
| `stop.sh` | Stop sing-box |
| `status.sh` | Check process, TUN device, routes, DNS, connectivity |
| `toggle.sh` | Quick on/off toggle (used by `tun` alias) |
| `install-service.sh` | Install as systemd service |

## tmux Keybindings

Prefix: `Ctrl+s`

| Key | Action |
|-----|--------|
| `\|` | Vertical split |
| `-` | Horizontal split |
| `h/j/k/l` | Navigate panes (vim-style) |
| `H/J/K/L` | Resize panes |
| `Ctrl+h/l` | Previous/next window |
| `Alt+1..9` | Switch to window N |
| `v` | Enter copy mode |
| `g` | Sync panes (type in all panes) |
| `z` | Maximize/restore pane |

Supports OSC 52 clipboard for copying over SSH.

## File Overview

```
setup.sh            Main installer/deployer
shell_common.sh     Shared config: PATH, proxy, mirrors, truecolor
zshrc               Zsh: zinit plugins, fzf/zoxide/starship init
bashrc              Bash: starship/uv init
starship.toml       Prompt theme (One Dark, powerline segments)
tmux.conf           tmux config (vim keys, mouse, OSC 52 clipboard)
local.sh.example    Template for machine-specific overrides
s-box/              sing-box proxy management scripts
tun/                Legacy TUN proxy scripts (tun2socks, Linux only)
```
