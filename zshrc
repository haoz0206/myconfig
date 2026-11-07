# ====================================
# Zsh-specific config
# ====================================
# Discover Homebrew before loading tools, including in non-login shells.
if (( $+commands[brew] )); then
    eval "$(brew shellenv zsh)"
else
    for brew_bin in /opt/homebrew/bin/brew /usr/local/bin/brew /home/linuxbrew/.linuxbrew/bin/brew; do
        if [[ -x "$brew_bin" ]]; then
            eval "$("$brew_bin" shellenv zsh)"
            break
        fi
    done
fi
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
# Zinit itself is installed by Homebrew; plugins download on first use.
if command -v brew >/dev/null 2>&1 && [[ -f "$(brew --prefix)/opt/zinit/zinit.zsh" ]]; then
    source "$(brew --prefix)/opt/zinit/zinit.zsh"
    zinit light-mode wait lucid for \
        zsh-users/zsh-autosuggestions \
        zsh-users/zsh-completions \
        Aloxaf/fzf-tab \
        zdharma-continuum/fast-syntax-highlighting
    autoload -Uz compinit && compinit
    zinit cdreplay -q
else
    autoload -Uz compinit && compinit
fi

# -- Tool init --
command -v fzf &>/dev/null && eval "$(fzf --zsh)"
command -v zoxide &>/dev/null && eval "$(zoxide init zsh)"
command -v starship &>/dev/null && eval "$(starship init zsh)"
command -v uv &>/dev/null && eval "$(uv generate-shell-completion zsh)"
command -v uvx &>/dev/null && eval "$(uvx --generate-shell-completion zsh)"
