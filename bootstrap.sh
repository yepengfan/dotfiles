#!/usr/bin/env bash
# Takes a fresh Mac from nothing to a built nix-darwin config.
# Run this once. After it finishes, use ./rebuild.sh for every later change.
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"

echo "==> Step 1: Determinate Nix"
if command -v nix >/dev/null 2>&1; then
  echo "    nix already installed, skipping"
else
  curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix \
    | sh -s -- install --no-confirm
  # shellcheck disable=SC1091
  . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
fi

echo "==> Step 2: symlink this repo to ~/.dotfiles"
# home.nix resolves its mkOutOfStoreSymlink paths through ~/.dotfiles, so this
# has to exist before the first switch or the build will fail to find them.
if [[ "$DIR" != "$HOME/.dotfiles" ]]; then
  if [[ -e "$HOME/.dotfiles" && ! -L "$HOME/.dotfiles" ]]; then
    echo "    ~/.dotfiles is an existing directory; back it up before bootstrapping another checkout." >&2
    exit 1
  fi
  ln -sfn "$DIR" "$HOME/.dotfiles"
fi

echo "==> Step 3: personalize the configured username"
IDENTITY_FILE="$DIR/hosts/tedfan/identity.nix"
# Do this before any sudo call: sudo resets $USER to root, so whoami has to
# run as the real interactive user first.
REAL_USER="$(whoami)"
FLAKE_USER="$(sed -nE 's/^[[:space:]]*macUser = "([^"]+)";.*/\1/p' "$IDENTITY_FILE" | head -n1)"
if [ -z "$FLAKE_USER" ]; then
  echo "    Could not find the single \"macUser = \" line in hosts/tedfan/identity.nix."
  echo "    Edit hosts/tedfan/identity.nix yourself before continuing."
  exit 1
elif [ "$FLAKE_USER" != "$REAL_USER" ]; then
  echo "    identity.nix is configured for user \"$FLAKE_USER\", but you are \"$REAL_USER\"."
  read -r -p "    Rewrite identity.nix's \"macUser = \" line to \"$REAL_USER\"? [y/N] " REPLY
  if [ "$REPLY" = "y" ] || [ "$REPLY" = "Y" ]; then
    sed -i '' -E "s/^([[:space:]]*macUser = \")[^\"]+(\";.*)/\1${REAL_USER}\2/" "$IDENTITY_FILE"
    echo "    Updated. Review the change with: git diff hosts/tedfan/identity.nix"
  else
    echo "    Skipped. Edit the single \"macUser = \" line in hosts/tedfan/identity.nix yourself before continuing."
    exit 1
  fi
else
  echo "    identity.nix already matches \"$REAL_USER\", nothing to do."
fi

echo "==> Step 4: first darwin-rebuild switch (pinned to nix-darwin-26.05)"
# darwin-rebuild doesn't exist yet on a fresh machine, so run it straight
# from the flake this once. After this, rebuild.sh works normally.
# This fetches the darwin-rebuild tool from the nix-darwin-26.05 release branch,
# not the exact flake.lock revision. The system config it applies is still pinned
# by this repo's flake.lock.
# sudo resets PATH to a secure default that excludes /nix/.../bin, so a
# freshly installed `nix` would not be found under sudo even though it's
# on PATH here. Resolve the absolute path first and invoke that instead.
NIX_BIN="$(command -v nix)"
# "mac" is the flake host label - if you renamed it, change it in flake.nix
# and rebuild.sh too.
sudo "$NIX_BIN" --extra-experimental-features 'nix-command flakes' run github:nix-darwin/nix-darwin/nix-darwin-26.05#darwin-rebuild -- \
  switch --flake ~/.dotfiles#mac
# If this still fails with "nix: command not found", open a new terminal
# (Determinate adds nix to new shells' PATH) and re-run ./bootstrap.sh.

echo "==> Done. Use ./rebuild.sh for future changes."
