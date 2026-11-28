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

# Resolve the absolute path for the later sudo call, which resets PATH.
NIX_BIN="$(command -v nix)"
# App Store authentication is attended. Skip the prompt if all declared apps
# are already installed, so a bootstrap retry can proceed without signing in.
MAS_APP_IDS=$("$NIX_BIN" --extra-experimental-features 'nix-command flakes' eval --raw \
  "$DIR#darwinConfigurations.mac.config.homebrew.masApps" \
  --apply 'apps: builtins.concatStringsSep "\n" (builtins.map toString (builtins.attrValues apps))')
missing_store_app=false
while IFS= read -r app_id; do
  if [[ -n "$app_id" && -z "$(mdfind "kMDItemAppStoreAdamID == $app_id && kMDItemAppStoreHasReceipt == 1")" ]]; then
    missing_store_app=true
    break
  fi
done <<< "$MAS_APP_IDS"
if "$missing_store_app"; then
  echo "==> Mac App Store sign-in is required to restore the declared apps"
  if [[ ! -t 0 ]]; then
    echo "    Sign in to the Mac App Store and rerun ./bootstrap.sh in an interactive terminal." >&2
    exit 1
  fi
  open -a "App Store"
  if ! read -r -p "    Have you signed in to the Mac App Store? [y/N] " app_store_ready ||
     [[ "$app_store_ready" != [yY] ]]; then
    echo "    Sign in to the Mac App Store, then rerun ./bootstrap.sh." >&2
    exit 1
  fi
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
# "mac" is the flake host label. Keep it in sync with the preflight above,
# flake.nix, and rebuild.sh.
sudo "$NIX_BIN" --extra-experimental-features 'nix-command flakes' run github:nix-darwin/nix-darwin/nix-darwin-26.05#darwin-rebuild -- \
  switch --flake ~/.dotfiles#mac
# If this still fails with "nix: command not found", open a new terminal
# (Determinate adds nix to new shells' PATH) and re-run ./bootstrap.sh.

echo "==> Step 5: Automic Vault GitHub CLI setup"
open -a "Automic Vault"
if [[ ! -x /usr/local/bin/av ]]; then
  echo "    Complete Automic Vault's CLI installation in the app (administrator authentication required)."
  read -r -p "    Press Enter when the CLI installation is complete. "
fi
if [[ ! -x /usr/local/bin/av ]]; then
  echo "    Automic Vault CLI is missing. Complete its installation, then re-run ./bootstrap.sh." >&2
  exit 1
fi
/usr/local/bin/av harden gh
/usr/local/bin/av doctor gh

echo "==> Done. Use ./rebuild.sh for future changes."
