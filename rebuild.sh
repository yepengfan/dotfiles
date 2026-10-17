#!/usr/bin/env bash
set -euo pipefail
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
if [[ "$(cd "$HOME/.dotfiles" 2>/dev/null && pwd -P)" != "$DIR" ]]; then
  echo "Apply configuration from the canonical ~/.dotfiles checkout." >&2
  exit 1
fi
export PATH="/run/current-system/sw/bin:$PATH"
exec sudo darwin-rebuild switch --flake "$DIR#mac" "$@"
