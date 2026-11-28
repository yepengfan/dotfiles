# dotfiles

This fork selects the `hosts/tedfan/` configuration. See
[personal configuration and upstream sync](docs/fork-maintenance.md) for this
Mac's settings, configuration ownership and review workflow.

<p align="center">
  <a href="https://discord.gg/Wsy2NpnZDu"
    ><img
      alt="Discord"
      src="https://img.shields.io/discord/1439901831038763092?style=flat-square&label=discord"
  /></a>
</p>

Watch the walkthrough: https://youtu.be/5N-okeDdIuI

My personal Mac setup, managed with nix-darwin and home-manager.
One repo, one command, and a fresh Mac ends up configured the same way every time.

## Contributing / Using This Repo

These are my personal dotfiles, shared publicly so people can read them, learn from them, and fork them freely.
Feature requests and pull requests are not accepted here, and PRs are auto-closed.
If you find a bug, please open a GitHub Issue using the bug report template.

## What you get

Running the switch builds:

- System settings (dark mode, key repeat, dock, Finder, trackpad)
- Homebrew Bundle apps (casks, CLI tools, and Mac App Store apps)
- Nix user packages (ripgrep, fd, fzf, jq, lazygit, Neovim, Hack Nerd Font)
- Shell (zsh, aliases, starship prompt)
- Editor (Neovim config with the rose-pine moon theme)
- Terminal (WezTerm config with the rose-pine moon theme and dimmed unfocused windows)
- Agent configs (Claude, Codex, opencode all share one AGENTS.md)
- Optional Pi theme and local extensions, generic UI settings and model overrides, plus two deliberately pinned third-party Pi packages

## Prerequisites

- Apple Silicon Mac, by default.
- Intel Mac: change one line.
  In `configuration.nix`, set `nixpkgs.hostPlatform = "x86_64-darwin";` (the comment right there tells you the same thing).

## Fresh-machine setup

On a brand new Mac, from a bare clone of this repo:

```sh
git clone https://github.com/yepengfan/dotfiles.git
cd dotfiles
```

Before you run it: review "Make it yours" below.
Change the host label or CPU architecture if needed, and read the Homebrew cleanup warning.
Sign in to the Mac App Store before running `bootstrap.sh` so Homebrew Bundle can
install the apps declared in `homebrew.masApps`.

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

On this host, Homebrew installs user software, fonts, zsh and its plugins.
Nix and Home Manager manage macOS settings and configuration files, without
installing duplicate user tools. Declare software in `hosts/tedfan/darwin.nix`;
use `brew upgrade` to update it deliberately. Rebuilding does not upgrade
existing Homebrew packages. Node versions remain managed by nvm.

After applying the configuration, new login sessions use
`/opt/homebrew/bin/zsh`. macOS's `/bin/zsh` remains available as a fallback.

## Make it yours

This repo is mine.
If you clone it, review these before you run `bootstrap.sh`:

- **Account identity**: edit `hosts/tedfan/identity.nix`. `macUser` is the local macOS account; `githubUser` is the GitHub namespace. `bootstrap.sh` offers to personalize only `macUser`.
- **Host label** `"mac"`, in three places: `flake.nix` (the `darwinConfigurations."mac"` name), `rebuild.sh` (the `#mac` at the end of the flake reference), and `bootstrap.sh`'s first-switch command (also `#mac`).
  All three have to match.
- **CPU architecture**, `hostPlatform` in `configuration.nix` (see Prerequisites above).

**Git identity:** the shared Home Manager module leaves this unset. This fork's
host declares the author name/email in `hosts/tedfan/identity.nix`.

**Homebrew cleanup warning:** the shared `configuration.nix` enables
`homebrew.onActivation.cleanup = "zap"`. The host declares its Homebrew inventory
in [`hosts/tedfan/darwin.nix`](hosts/tedfan/darwin.nix) using `brews`, `casks`, and
`masApps`.
The `brews` and `casks` lists use `lib.mkForce` and replace the shared lists in
`configuration.nix`.

Before running `bootstrap.sh` or `rebuild.sh`, add every formula and cask you
want to keep to **`hosts/tedfan/darwin.nix`**. Adding it only to the shared
`configuration.nix` will not retain it: the next switch can uninstall anything
absent from the host inventory. Review the cleanup preview described in the
[fork maintenance guide](docs/fork-maintenance.md) before applying inventory changes.

**About `herdr`:** it is declared in the host's `brews` list in
`hosts/tedfan/darwin.nix`. If you do not use it, remove it from that host list.

**Heads-up:**

- This fork installs the host's `hosts/tedfan/files/AGENTS.md` for Claude, Codex, opencode and Cursor. Review that policy when using this fork.
- The base `cc` and `co` shell aliases are disabled by this host. In the upstream base they are shortcuts for: `claude --dangerously-skip-permissions` and `codex --full-auto`.

## Repo tour

- `flake.nix` - the entry point.
  Wires up nixpkgs, nix-darwin, home-manager, and nix-homebrew, and declares the `mac` machine.
- `configuration.nix` - shared system defaults from upstream.
- `hosts/tedfan/darwin.nix` - this Mac's Homebrew inventory and system overrides.
- `home.nix` - user-level config: shell, packages, prompt, and the symlinks described below.
- `rebuild.sh` - re-applies the config after the first switch.
  Run this every time you make a change.
- `home/` - the actual config files that get symlinked into place; the sections below explain the shared symlink model and Pi's narrower selective setup.

## How the symlinks work

The files under `home/` are the real files - editing them here is editing your live config, no rebuild needed to see the change in your editor.
`home.nix` uses `mkOutOfStoreSymlink` to point paths like `~/.config/nvim` straight at `home/.config/nvim` in this repo, so the two never drift out of sync.
You only run `./rebuild.sh` when you change something that isn't just a symlinked file, like a package list or a system default.

## Pi

The selected host installs the [Pi CLI](https://formulae.brew.sh/formula/pi-coding-agent)
through Homebrew.

[Pi Launcher](https://github.com/kunchenguid/homebrew-tap) is optional. Install it separately with Homebrew.

```sh
brew install --cask kunchenguid/tap/pi-launcher
```

### Optional Home Manager configuration

The selected host disables the Pi links from the shared Home Manager configuration. When enabled, those links expose `~/.pi/agent/themes`, `~/.pi/agent/extensions`, `~/.pi/agent/models.json`, and `~/.pi/agent/settings.json`. The local extension directory is for public, repository-authored extensions only - third-party package code never belongs there. Run `/reload` after editing a linked extension or other Pi resource. The terminal-title extension shows a spinner while Pi is working, then a completion mark with the session name or current directory. The `rose-pine-moon` theme was authored clean-room from the public [Rosé Pine Moon palette](https://rosepinetheme.com/palette) and Pi's [public theme schema](https://raw.githubusercontent.com/earendil-works/pi/main/packages/coding-agent/src/modes/interactive/theme/theme-schema.json), not from a private or live theme file.

### Pi Calm

`home/.pi/agent/extensions/calm` is a standalone local Pi extension. Pi auto-loads Calm when the shared Home Manager extensions link is enabled. `/calm` toggles a conversation-only presentation mode and is off by default. Its choice is stored locally in `~/.pi/agent/calm` (or the directory selected by `PI_CODING_AGENT_DIR`), not in this repository or Home Manager. Adapted from Firstmate under the bundled MIT license, Calm imports no Firstmate modules and has no Firstmate runtime dependency.

When enabled, Calm hides collapsed thinking and the call/result shells for Pi's seven built-in tools (`read`, `bash`, `edit`, `write`, `grep`, `find`, and `ls`) without leaving blank transcript rows. During an active run it replaces Pi's working row with a two-line animated blue-water, yellow-boat widget. `/calm` restores Pi's stock rendering and preserves the existing Ctrl+O tool-expansion choice.

Calm never changes prompts, tool execution, model context, session data, or ordering. `/share` and `/export` use the complete stock transcript. Generic custom tools, images, and unsupported Pi transcript classes deliberately remain visible because Pi has no safe general-purpose transcript filter. If a future Pi release no longer exports the exact collapsed-thinking rendering seam, Calm logs one diagnostic and leaves only that adapter disabled; all other behavior remains available.

Run `bash tests/pi-calm.test.sh` to test Calm. The script looks for the Pi package in the global npm directory and then in the Homebrew formula. Set `PI_CALM_TEST_PACKAGE_DIR` to use a specific package directory. The interactive smoke test also requires `tmux` and Pi 0.82.0 on `PATH`. To run it with an isolated Pi 0.82.0 install, use a Node.js version supported by Pi and run:

```sh
npm exec --ignore-scripts --package=@earendil-works/pi-coding-agent@0.82.0 -- bash -c '
  pi_bin=$(command -v pi)
  PI_CALM_TEST_PACKAGE_DIR="$(dirname "$(dirname "$pi_bin")")/@earendil-works/pi-coding-agent" \
    bash tests/pi-calm.test.sh
'
```

### Optional Pi packages and runtime state

When linked, the shared `settings.json` declares two third-party sources:

- `npm:pi-web-access@0.14.0` - the exact public npm release for web access.
- `npm:@ryan_nookpi/pi-extension-codex-fast-mode@0.2.6` - the exact public npm release from `ryan_nookpi`.

The versions are immutable pins, so Pi does not move them during package updates. Deliberate updates require a new source and security audit, followed by an explicit pin change in `home/.pi/agent/settings.json`. On Pi 0.82.0, global settings declarations install missing pinned packages automatically at startup. No one-time install command is required. Pi keeps the downloaded npm package trees in its own unmanaged `~/.pi/agent/npm` runtime directory, outside Home Manager and Git tracking.

Both packages execute with your full user permissions and must be trusted like any other executable code.

Pi manages its own authentication, sessions, trust decisions, caches, and installed package trees under `~/.pi/agent`. The model overrides leave credentials, endpoints, and default model selection to your local Pi configuration. They take effect after you authenticate Pi.

## Notes

The first time you launch `nvim`, it bootstraps [lazy.nvim](https://github.com/folke/lazy.nvim) by cloning plugins from GitHub.
That needs network access once; after that it's offline.
Neovim and WezTerm both use the rose-pine moon theme.
Neovim keeps italics off and uses a transparent background on macOS, Windows, and WSL so it matches the terminal setup.

## License

This repo is licensed under MIT No Attribution.
See `LICENSE`.
