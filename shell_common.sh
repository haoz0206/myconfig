# Shared shell configuration. MYCONFIG_DIR is set by zshrc.
export PATH="$HOME/.local/bin:$PATH"

# SSH clients do not always forward COLORTERM.
if [ -n "${SSH_TTY:-}" ] && [ -z "${COLORTERM:-}" ]; then
    case "${TERM:-}" in
        xterm-ghostty|xterm-256color|alacritty) export COLORTERM=truecolor ;;
    esac
fi

# Per-machine overrides are never overwritten by setup.sh.
if [ -f "$MYCONFIG_DIR/local.sh" ]; then
    source "$MYCONFIG_DIR/local.sh"
fi
