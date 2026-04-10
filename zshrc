# ====================================
# Zsh-specific config
# ====================================
MYCONFIG_DIR="$(cd "$(dirname "${(%):-%x}")" && pwd)"
source "$MYCONFIG_DIR/shell_common.sh"

# -- History --
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt APPEND_HISTORY
setopt SHARE_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE

# -- Color support & eza --
if command -v eza &>/dev/null; then
    alias ls='eza'
    alias ll='eza -l --git'
    alias la='eza -la --git'
    alias lt='eza -T --level=2'
elif [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
elif [ "$(uname)" = "Darwin" ]; then
    export CLICOLOR=1
fi
alias grep='grep --color=auto'

# -- Zinit plugin manager --
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
if [[ ! -f "$ZINIT_HOME/zinit.zsh" ]]; then
    echo "Installing zinit..."
    mkdir -p "$(dirname "$ZINIT_HOME")"
    git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi
source "$ZINIT_HOME/zinit.zsh"

# Plugins (turbo mode — deferred loading for fast startup)
zinit light-mode wait lucid for \
    zsh-users/zsh-autosuggestions \
    zsh-users/zsh-completions \
    Aloxaf/fzf-tab \
    zdharma-continuum/fast-syntax-highlighting

# Load completions
autoload -Uz compinit && compinit
zinit cdreplay -q

# -- Tool init --
command -v fzf &>/dev/null && eval "$(fzf --zsh)"
command -v zoxide &>/dev/null && eval "$(zoxide init zsh)"
command -v starship &>/dev/null && eval "$(starship init zsh)"
command -v uv &>/dev/null && eval "$(uv generate-shell-completion zsh)"
command -v uvx &>/dev/null && eval "$(uvx --generate-shell-completion zsh)"
