# Personal configuration and upstream sync

This fork is the source of truth for Ted's Mac. `main` is the reviewed, active
configuration. Upstream supplies shared defaults; the selected host supplies
personal settings. Both remain in the same repository and lockfile.

## Where to edit

| Configuration | Source |
| --- | --- |
| Local macOS account, GitHub namespace, Git author | `hosts/tedfan/identity.nix` |
| Homebrew inventory, upgrade policy, maintained local tap | `hosts/tedfan/darwin.nix` |
| Git/delta, aliases, agent links, optional-resource overrides | `hosts/tedfan/home.nix` |
| Login and interactive shell, Claude settings, agent instructions, Herdr preferences | `hosts/tedfan/files/` |
| WezTerm font fallback, native title bar, and opaque windows | `hosts/tedfan/files/.config/wezterm/wezterm.lua` |
| Ice 2 version and checksum (avoids invalid unrelated casks in the upstream tap) | `hosts/tedfan/homebrew/Casks/ice-2.rb` |
| Shared system and Home Manager defaults | `configuration.nix`, `home.nix`, `home/` |
| Host selection and module composition | `flake.nix` |

`macUser` is the local macOS login account (`tedfan`); `githubUser` is the GitHub
namespace (`yepengfan`). Bootstrap personalizes only `macUser` in the host's
identity file. Git author name/email are separate from both account names.

The shared `configuration.nix` and `home.nix` match upstream. Personal modules
use Nix's normal module merging and explicit overrides. The host owns the full
Homebrew formula/cask lists, including tools that also occur in the shared
base, so an upstream removal cannot silently remove a required local tool when
`cleanup = "zap"` runs. Review upstream package-list changes and add wanted
packages to the host inventory explicitly. Other shared defaults, including
Neovim and WezTerm behavior, continue to receive upstream changes.

Homebrew owns all user software, shell plugins and fonts on this host.
The host Home Manager module replaces `home.packages` with environment metadata
only, and generates zsh initialization without Nix program paths. Upstream
aliases and Starship settings still merge; the prompt and shell plugins are
loaded from Homebrew by `.zshrc.local`. Git and LFS remain configured by Home
Manager with their package installation disabled, and delta is resolved on PATH.
The host disables nix-darwin's interactive shell packages, retains system
environment initialization in `/etc/zshenv`, and selects Homebrew zsh as the
login shell after Homebrew activation. Nix's configuration and activation
dependencies remain in the store as infrastructure.

Homebrew itself is pinned by the `nix-homebrew` input in `flake.lock`;
`brew update` refreshes package definitions but cannot upgrade that runtime.
If newer casks require unsupported Homebrew DSL methods, update only this input
with `nix flake lock --update-input nix-homebrew`, build and review the change
through a PR, then apply with `./rebuild.sh` after merging.

Azure Functions Core Tools v4 also causes Homebrew to load the unversioned
formula while inspecting the installed package. The host declares trust for
that additional definition through a tap-level item allowlist in
`homebrew.extraConfig`, alongside the v4 formula's own trust declaration.
Only v4 is installed. Keep this trust in the generated Brewfile: Homebrew Bundle
cleanup replaces the trust store with the Brewfile's declarations, so a manual
`brew trust` alone does not persist across rebuilds.

The host declares `nvm` in Homebrew and lazy-loads its scripts from
`$HOMEBREW_PREFIX/opt/nvm`. Node versions, aliases and global npm packages stay
in `~/.nvm`, outside the Homebrew Cellar, so nvm upgrades preserve them.
On a fresh Mac, run `nvm install --lts` after bootstrap to install Node.
When migrating a manual nvm installation, back up `~/.nvm/nvm.sh` and
`~/.nvm/nvm-exec` outside those paths before opening a new shell and running
`nvm --version`. Homebrew's loader creates links to its managed scripts for
`nvm exec` and tools that source `~/.nvm/nvm.sh` directly.

After selecting a Node version, `av harden node` configures AV's npm launcher;
verify it with `av doctor node`. When `/usr/local/bin/npm` exists, the host keeps
`/usr/local/bin` ahead of nvm's version directory at startup and after nvm
commands. This preserves the AV entry point when switching Node versions.
The launcher remains bound to the npm target selected during AV hardening;
check its target in AV when changing the protected npm version.

WezTerm loads the shared Lua configuration, adds the host's font fallback,
and restores the native title bar with macOS window controls. This host uses
opaque windows and disables the shared focus dimming; reloads clear stale
opacity and text-dimming overrides from existing windows.
The host keeps its own Claude settings, agent policy and Herdr preferences.
Upstream's Pi resources remain in the repository but are disabled for this host;
the upstream permission-shortcut aliases `cc` and `co` are removed at shell
startup. New upstream aliases can still merge normally.

Secrets remain optional local inputs at `~/.zsh/secrets.zsh` and
`~/.config/no-mistakes/bitbucket.env`. Generated hooks, sessions, sockets, caches
and downloaded runtimes stay outside the repository. Only Herdr's preferences
file is linked. Do not commit credentials or generated application state.

The host declares Automic Vault and its `gh-cli` formula, which supplies `gh`
and conflicts with the upstream `gh` formula. Bootstrap opens Vault for its
attended CLI installation, runs `av harden gh`, and verifies with `av doctor gh`.
Administrator approval and GitHub credential setup remain interactive on a new
Mac; credentials are not restored from this public repository.

## Configure remotes once

```sh
git remote -v
# origin:   https://github.com/yepengfan/dotfiles.git
# upstream: https://github.com/kunchenguid/dotfiles.git
```

If `upstream` is absent:

```sh
git remote add upstream https://github.com/kunchenguid/dotfiles.git
```

Keep pull requests targeted at this fork after adding `upstream`:

```sh
gh repo set-default yepengfan/dotfiles
```

GitHub CLI can otherwise prefer the parent repository when resolving a fork's
remotes. This setting affects PR targeting, not which commits Git merges.

## Review an upstream update

Start with a clean checkout. Choose a new branch name for each sync:

```sh
cd ~/.dotfiles
git fetch upstream
git switch main
git pull --ff-only origin main
git switch -c sync/upstream-YYYYMMDD
git merge upstream/main
```

Resolve any conflicts while preserving the host modules and the imports in
`flake.nix`. Review shared defaults as well as dependency-lock changes. Keep
merge commits so both upstream history and the fork's reviewed changes remain
visible. Upstream sync and dependency upgrades can be reviewed separately;
`git merge` does not require an unrelated `nix flake update`.

Validate the proposed configuration:

```sh
nix --extra-experimental-features 'nix-command flakes' flake check --no-build
nix --extra-experimental-features 'nix-command flakes' build .#darwinConfigurations.mac.system
```

Preview the resulting Homebrew cleanup before applying a changed inventory:

```sh
nix --extra-experimental-features 'nix-command flakes' eval --raw .#darwinConfigurations.mac.config.homebrew.brewfile | HOMEBREW_NO_AUTO_UPDATE=1 brew bundle cleanup --file=-
```

Run affected application checks, then commit conflict resolutions if needed,
push the sync branch and open a PR against your own `main`:

```sh
git push -u origin sync/upstream-YYYYMMDD
```

Merge the reviewed PR on GitHub, then apply from the canonical checkout:

```sh
git switch main
git pull --ff-only origin main
./rebuild.sh
```

`rebuild.sh` only applies the canonical `~/.dotfiles` checkout. It never repoints
that path to a review worktree. Installing this refactor requires a rebuild so
existing application links move to the host-specific files. Review worktrees
can be built independently without changing the active checkout.
