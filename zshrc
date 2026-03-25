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

# -- Zinit plugin manager --
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
if [[ ! -f "$ZINIT_HOME/zinit.zsh" ]]; then
    echo "Installing zinit..."
    mkdir -p "$(dirname $ZINIT_HOME)"
    git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi
source "$ZINIT_HOME/zinit.zsh"

# Plugins (turbo mode — deferred loading for fast startup)
zinit light-mode wait lucid for \
    zsh-users/zsh-autosuggestions \
    zsh-users/zsh-completions \
    zdharma-continuum/fast-syntax-highlighting

# Load completions
autoload -Uz compinit && compinit
zinit cdreplay -q

# -- Tool init --
command -v starship &>/dev/null && eval "$(starship init zsh)"
command -v uv &>/dev/null && eval "$(uv generate-shell-completion zsh)"
command -v uvx &>/dev/null && eval "$(uvx --generate-shell-completion zsh)"
