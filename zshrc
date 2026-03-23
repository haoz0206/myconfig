# ====================================
# Zsh-specific config
# ====================================
MYCONFIG_DIR="$(cd "$(dirname "${(%):-%x}")" && pwd)"
source "$MYCONFIG_DIR/shell_common.sh"

# -- Color support (Linux) --
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# -- Tool init --
command -v starship &>/dev/null && eval "$(starship init zsh)"
command -v uv &>/dev/null && eval "$(uv generate-shell-completion zsh)"
command -v uvx &>/dev/null && eval "$(uvx --generate-shell-completion zsh)"
