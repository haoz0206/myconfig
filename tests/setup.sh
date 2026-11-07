#!/usr/bin/env bash
set -euo pipefail
repo=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
home="$tmp/home with spaces"
mkdir -p "$home/.config"
printf 'previous prompt\n' > "$home/.config/starship.toml"
printf 'previous tmux\n' > "$home/.tmux.conf"
printf '# existing config\n' > "$home/.zshrc"
HOME="$home" bash "$repo/setup.sh" --no-install >/dev/null
printf '# custom local settings\n' > "$home/.myconfig/local.sh"
HOME="$home" bash "$repo/setup.sh" --no-install >/dev/null
[ "$(find "$home" -name '*.myconfig-backup-*' | wc -l | tr -d ' ')" -eq 2 ]
grep -qx 'previous prompt' "$home"/.config/starship.toml.myconfig-backup-*
grep -qx 'previous tmux' "$home"/.tmux.conf.myconfig-backup-*
grep -qx '# custom local settings' "$home/.myconfig/local.sh"
[ "$(grep -Fc 'source "$HOME/.myconfig/zshrc"' "$home/.zshrc")" -eq 1 ]
cmp "$repo/starship.toml" "$home/.config/starship.toml"
cmp "$repo/tmux.conf" "$home/.tmux.conf"
if HOME="$home" bash "$repo/setup.sh" --invalid >/dev/null 2>&1; then
    echo 'Unknown option was accepted' >&2; exit 1
fi
printf 'setup deployment tests passed\n'
