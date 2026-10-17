# dotfiles

<p align="center">
  <a href="https://discord.gg/Wsy2NpnZDu"
    ><img
      alt="Discord"
      src="https://img.shields.io/discord/1439901831038763092?style=flat-square&label=discord"
  /></a>
</p>

Watch the walkthrough: https://youtu.be/5N-okeDdIuI

My personal Mac setup for `tedfan`, managed with nix-darwin and home-manager.
One repo, one command, and a fresh Mac ends up configured the same way every time.

## Contributing / Using This Repo

These are my personal dotfiles, shared publicly so people can read them, learn from them, and fork them freely.
Feature requests and pull requests are not accepted here, and PRs are auto-closed.
If you find a bug, please open a GitHub Issue using the bug report template.

## What you get

Running the switch builds:

- System settings (dark mode, key repeat, dock, Finder, trackpad)
- Homebrew apps (casks and CLI tools)
- Nix user packages (ripgrep, fd, fzf, jq, lazygit, Neovim, Hack Nerd Font)
- Shell (zsh, aliases, starship prompt)
- Editor (Neovim config with the rose-pine moon theme)
- Terminal (WezTerm config with the rose-pine moon theme and dimmed unfocused windows)
- Agent configs (Claude, Codex, opencode all share one AGENTS.md)
- Personal Git identity, work shell integration, CJK font fallback, and shared Cursor rules

## Prerequisites

- Apple Silicon Mac, by default.
- Intel Mac: change one line.
  In `configuration.nix`, set `nixpkgs.hostPlatform = "x86_64-darwin";` (the comment right there tells you the same thing).

## Fresh-machine setup

On a brand new Mac, from a bare clone of this repo:

```sh
git clone https://github.com/kunchenguid/dotfiles.git
cd dotfiles
```

Before you run it: review "Make it yours" below.
Change the host label or CPU architecture if needed, and read the Homebrew cleanup warning.
`bootstrap.sh` applies the config to your machine, so do this first.

```sh
./bootstrap.sh
```

`bootstrap.sh` does four things, in order:

1. Installs Determinate Nix, if it isn't already installed.
2. Symlinks this repo to `~/.dotfiles`.
   This has to happen before the first build, because `home.nix` points at config files through `~/.dotfiles`.
3. Checks the `user` configured in `flake.nix` against your actual macOS username, and offers to fix it for you if they differ.
4. Runs the first `darwin-rebuild switch`.
   It fetches the `darwin-rebuild` tool from the nix-darwin 26.05 release branch, then applies this repo's locked flake config.

After that, `darwin-rebuild` exists and you're on the normal workflow below.

### Validate without applying

Once Nix is installed (`bootstrap.sh` step 1 handles that), you can check that the config builds without touching your system - handy when you have edited something:

```sh
nix flake check --no-build
nix build .#darwinConfigurations.mac.system --dry-run
```

If you renamed the host label in "Make it yours", substitute your label for `mac` in these commands.

## Daily use

Edit the config files in place, then apply:

```sh
./rebuild.sh
```

That's it.
No separate build-and-copy step.

## Make it yours

This repo is mine.
If you clone it, review these before you run `bootstrap.sh`:

- **Username**: run `./bootstrap.sh` (it detects your macOS username and offers to set it) OR change the single `user = "tedfan"` line in `flake.nix`.
  Everything else (`configuration.nix`, `home.nix`, home directory paths) is threaded from that one variable.
- **Host label** `"mac"`, in three places: `flake.nix` (the `darwinConfigurations."mac"` name), `rebuild.sh:5` (the `#mac` at the end of the flake reference), and `bootstrap.sh`'s first-switch command (also `#mac`).
  All three have to match.
- **CPU architecture**, `hostPlatform` in `configuration.nix` (see Prerequisites above).

**Git identity:** `home.nix` declares this machine's name and email. Change
`programs.git.settings.user` before applying this configuration for another
person.

**Homebrew cleanup warning:** `configuration.nix` sets `homebrew.onActivation.cleanup = "zap"`.
That means every time you switch, Homebrew removes any package or cask on your machine that isn't listed in the `brews` and `casks` arrays in `configuration.nix`.
If you already have Homebrew stuff installed that isn't in that list, the first switch will uninstall it.
Read through `brews` and `casks` before you run `bootstrap.sh` or `rebuild.sh` for the first time, and add anything you want to keep.

**About `herdr`:** it's in the `brews` list.
It's a real public Homebrew formula (`brew info herdr` finds it in homebrew-core, no tap needed), so it will install fine.
If you don't use it, just remove it from `brews` in your copy.

**Heads-up:**

- `home/AGENTS.md` is my personal agent policy, and `home.nix` installs it for Claude, Codex, and opencode.
  If you clone this repo, you'd silently inherit my agent instructions - edit or delete `home/AGENTS.md` if you don't want that.
- Upstream's optional `cc` and `co` shortcuts are not enabled on this machine. Those shortcuts would run: `claude --dangerously-skip-permissions` and `codex --full-auto`.

## Repo tour

- `flake.nix` - the entry point.
  Wires up nixpkgs, nix-darwin, home-manager, and nix-homebrew, and declares the `mac` machine.
- `configuration.nix` - system-level config: macOS defaults, Homebrew.
- `home.nix` - user-level config: shell, packages, prompt, and the symlinks described below.
- `rebuild.sh` - re-applies the config after the first switch.
  Run this every time you make a change.
- `home/` - the actual config files that get symlinked into place; the sections below explain the shared symlink model and Pi's narrower selective setup.

## How the symlinks work

The files under `home/` are the real files - editing them here is editing your live config, no rebuild needed to see the change in your editor.
`home.nix` uses `mkOutOfStoreSymlink` to point paths like `~/.config/nvim` straight at `home/.config/nvim` in this repo, so the two never drift out of sync.
You only run `./rebuild.sh` when you change something that isn't just a symlinked file, like a package list or a system default.

## Optional Pi resources

The `home/.pi/` files are optional resources retained from upstream. This Mac
uses its existing agent tools; Home Manager does not install Pi or activate
those resources.

## Notes

The first time you launch `nvim`, it bootstraps [lazy.nvim](https://github.com/folke/lazy.nvim) by cloning plugins from GitHub.
That needs network access once; after that it's offline.
Neovim and WezTerm both use the rose-pine moon theme.
Neovim keeps italics off and uses a transparent background on macOS, Windows, and WSL so it matches the terminal setup.

## License

This repo is licensed under MIT No Attribution.
See `LICENSE`.

## Workstation tools

`configuration.nix` declares the workstation's existing Homebrew formulae,
casks and third-party taps before enabling `cleanup = "zap"`. Applying system
settings does not automatically update or upgrade tools; tool updates are
separate, deliberate changes.

Reasonix is provided by this repository's Nix-managed `yepengfan/dotfiles` tap
in `homebrew/Casks/reasonix.rb`. It uses the official 2.42.0 macOS release and
architecture-specific SHA-256 checksums. The upstream generated cask evaluates
`staged_path` inside `postflight_steps` while loading, which fails on Homebrew
6.0.1. The maintained cask keeps the upstream post-install quarantine handling in a
`postflight` block, where Homebrew provides `staged_path` at installation time. Update its version and both checksums
together when adopting a new release.

## Configuration ownership on this Mac

This repository is the source of truth for the Nix system and Home Manager
configuration, Homebrew tool inventory, Git/delta, Zsh login and interactive
shells, Starship, WezTerm, Neovim, Herdr preferences and shared agent rules.
The canonical checkout is `~/.dotfiles`; apply it with `./rebuild.sh`.
Edit the tracked source here and review changes through a pull request.
`rebuild.sh` only applies the canonical checkout and never repoints `~/.dotfiles`.

Existing work integrations (NVM, Bun, Kiro and Antigravity) are loaded only
when installed. Their credentials, downloaded runtimes and generated hooks
remain local. Claude settings declare the existing plugin and hook integration;
Herdr and context-mode own their generated hook scripts. Missing generated hooks
are ignored, so a new shell or agent session can start before those tools have
initialized their integration.

Credentials stay outside Git: `~/.zsh/secrets.zsh` and
`~/.config/no-mistakes/bitbucket.env` are optional, local inputs. Application
history, sockets, sessions, caches and plugin runtime data are not configuration
sources. Only Herdr's `config.toml` is linked, so its runtime files stay outside
the checkout.

The previous Stow environment is archived at `~/.dotfiles-stow-20261018`;
backups live under `~/dotfiles-rollback`. They are recovery data, not active
configuration sources.
