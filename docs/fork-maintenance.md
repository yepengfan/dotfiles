# Personal configuration and upstream sync

This fork is the source of truth for Ted's Mac. `main` is the reviewed, active
configuration. Upstream supplies shared defaults; the selected host supplies
personal settings. Both remain in the same repository and lockfile.

## Where to edit

| Configuration | Source |
| --- | --- |
| Local macOS account, GitHub namespace, Git author | `hosts/tedfan/identity.nix` |
| Homebrew inventory, upgrade policy, maintained Reasonix tap | `hosts/tedfan/darwin.nix` |
| Git/delta, aliases, agent links, optional-resource overrides | `hosts/tedfan/home.nix` |
| Login and interactive shell, Claude settings, agent instructions, Herdr preferences | `hosts/tedfan/files/` |
| Chinese font fallback layered over upstream WezTerm defaults | `hosts/tedfan/files/.config/wezterm/wezterm.lua` |
| Reasonix version, architecture-specific checksums and install hook | `hosts/tedfan/homebrew/Casks/reasonix.rb` |
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

WezTerm loads the shared Lua configuration and adds the host's font fallback.
The host keeps its own Claude settings, agent policy and Herdr preferences.
Upstream's Pi resources remain in the repository but are disabled for this host;
the upstream permission-shortcut aliases `cc` and `co` are removed at shell
startup. New upstream aliases can still merge normally.

Secrets remain optional local inputs at `~/.zsh/secrets.zsh` and
`~/.config/no-mistakes/bitbucket.env`. Generated hooks, sessions, sockets, caches
and downloaded runtimes stay outside the repository. Only Herdr's preferences
file is linked. Do not commit credentials or generated application state.

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
