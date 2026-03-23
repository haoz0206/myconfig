# ====================================
# Bash-specific config
# ====================================
MYCONFIG_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$MYCONFIG_DIR/shell_common.sh"

# -- Tool init --
command -v starship &>/dev/null && eval "$(starship init bash)"
command -v uv &>/dev/null && eval "$(uv generate-shell-completion bash)"
command -v uvx &>/dev/null && eval "$(uvx --generate-shell-completion bash)"
