#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
DEPLOY_DIR="$HOME/.myconfig"
INSTALL=1

usage() {
    cat <<'USAGE'
Usage: bash setup.sh [--no-install] [--help]
  --no-install  Deploy configuration without installing Homebrew or formulae
  --help        Show this help
USAGE
}
for arg in "$@"; do
    case "$arg" in
        --no-install) INSTALL=0 ;;
        -h|--help) usage; exit 0 ;;
        *) echo "Unknown option: $arg" >&2; usage >&2; exit 2 ;;
    esac
done

# Homebrew may not be in PATH in a fresh login session.
find_brew() {
    if command -v brew >/dev/null 2>&1; then command -v brew; return; fi
    local candidate
    for candidate in /opt/homebrew/bin/brew /usr/local/bin/brew /home/linuxbrew/.linuxbrew/bin/brew; do
        if [ -x "$candidate" ]; then printf '%s\n' "$candidate"; return; fi
    done
    return 1
}

if [ "$INSTALL" -eq 1 ]; then
    if ! BREW=$(find_brew); then
        echo 'Homebrew is not installed. Running the official installer (it may request sudo).'
        command -v curl >/dev/null 2>&1 || { echo 'curl is required to install Homebrew.' >&2; exit 1; }
        installer=$(mktemp "${TMPDIR:-/tmp}/myconfig-brew.XXXXXXXX")
        trap 'rm -f "$installer"' EXIT
        curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh -o "$installer"
        /bin/bash "$installer"
        rm -f "$installer"
        trap - EXIT
        BREW=$(find_brew) || { echo 'Homebrew could not be found after installation.' >&2; exit 1; }
    fi
    eval "$("$BREW" shellenv)"
    echo 'Installing Homebrew formulae...'
    "$BREW" install zsh tmux starship fzf zoxide uv eza zinit
fi

# Preserve files replaced by deployment and conflicting destinations.
backup() {
    local path="$1" backup_path="${1}.myconfig-backup-$(date +%Y%m%d%H%M%S)" n=0
    while [ -e "$backup_path" ] || [ -L "$backup_path" ]; do
        n=$((n + 1)); backup_path="${path}.myconfig-backup-$(date +%Y%m%d%H%M%S)-$n"
    done
    mv "$path" "$backup_path"
    echo "  backed up $path -> $backup_path"
}
link_file() {
    local source="$1" dest="$2"
    if [ -L "$dest" ] && [ "$(readlink "$dest")" = "$source" ]; then return; fi
    if [ -e "$dest" ] || [ -L "$dest" ]; then backup "$dest"; fi
    ln -s "$source" "$dest"
    echo "  linked $dest -> $source"
}

mkdir -p "$DEPLOY_DIR" "$HOME/.config"
for file in zshrc shell_common.sh proxy.sh starship.toml tmux.conf; do
    source_file="$SCRIPT_DIR/$file"
    dest_file="$DEPLOY_DIR/$file"
    [ -f "$source_file" ] || { echo "Missing required file: $source_file" >&2; exit 1; }
    if [ -f "$dest_file" ] && cmp -s "$source_file" "$dest_file"; then continue; fi
    if [ -e "$dest_file" ] || [ -L "$dest_file" ]; then backup "$dest_file"; fi
    cp "$source_file" "$dest_file"
    echo "  deployed $dest_file"
done
link_file "$DEPLOY_DIR/starship.toml" "$HOME/.config/starship.toml"
link_file "$DEPLOY_DIR/tmux.conf" "$HOME/.tmux.conf"

# Preserve all existing shell configuration. Do not append duplicates on reruns.
ZSHRC="$HOME/.zshrc"
touch "$ZSHRC"
if ! grep -Fxq 'source "$HOME/.myconfig/zshrc"' "$ZSHRC" && \
   ! grep -Fxq "source $DEPLOY_DIR/zshrc" "$ZSHRC"; then
    printf '\n# myconfig\nsource "$HOME/.myconfig/zshrc"\n' >> "$ZSHRC"
    echo "  added myconfig to $ZSHRC"
fi
if [ ! -e "$DEPLOY_DIR/local.sh" ]; then
    cp "$SCRIPT_DIR/local.sh.example" "$DEPLOY_DIR/local.sh"
    echo "  created $DEPLOY_DIR/local.sh"
fi
printf '\nDone. Start or restart zsh to use the configuration.\n'
