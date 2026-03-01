# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Is

GNU Stow-managed dotfiles for macOS. Each top-level directory is a stow package that mirrors `$HOME` structure. Catppuccin Mocha theme is used consistently across all tools.

## Commands

```sh
stow */          # Symlink all packages
stow nvim        # Symlink a single package
stow -D nvim     # Remove symlinks for a package
stow -R nvim     # Re-stow (remove then re-symlink)
```

Before stowing, check for existing non-symlinked files at the target — back them up first to avoid conflicts.

## Git Workflow

- `main` is protected — always create a feature branch and open a PR to merge
- Use conventional commits: `feat:`, `fix:`, `docs:`, `chore:`
- PRs are created via `gh pr create`

## Architecture

### Stow Packages

Each directory maps configs to `~/.config/<tool>/` (or `~/` for dotfiles like `.zshrc`). Key packages: `nvim`, `zsh`, `zellij`, `ghostty`, `git`, `claude`, `starship`, `bat`, `lazygit`, `tmux`.

### Neovim (LazyVim)

Built on LazyVim with custom plugin configs in `nvim/.config/nvim/lua/plugins/`. Key design decisions:

- **Navigation:** `smart-splits.nvim` replaces `vim-tmux-navigator` for unified Ctrl+hjkl across Neovim splits and multiplexer panes (Zellij/tmux). The snacks.nvim terminal `win.keys` must be overridden to route Ctrl+hjkl through smart-splits instead of LazyVim defaults — both are configured in `navigator.lua`.
- **File explorer:** neo-tree is disabled; snacks explorer is used as a persistent sidebar (`neo-tree.lua`).
- **Claude Code:** `claudecode.nvim` uses snacks as its terminal provider (`claude-code.lua`). Keybindings are under `<leader>a` prefix.
- **Plugin disabling pattern:** `{ "plugin/name", enabled = false }` in a plugin spec file.

### Zsh

- Auto-starts Zellij using absolute path (`/opt/homebrew/bin/zellij`) because it runs before PATH is set up.
- NVM is lazy-loaded for faster shell startup.
- Modern CLI tool aliases: `bat` (cat), `eza` (ls), `delta` (diff).

### Zellij

- `vim-zellij-navigator` plugin enables the Neovim-to-pane Ctrl+hjkl integration.
- Mode switching uses Alt keys (Alt+p, Alt+r, Alt+m) to free Ctrl+p/n for shell history.
- Ctrl+B is unbound to preserve Vim page-up.

### Ghostty

Reads config only on launch — must fully quit (Cmd+Q) and relaunch to apply changes.
