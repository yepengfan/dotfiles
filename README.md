# dotfiles

Personal development environment managed with [GNU Stow](https://www.gnu.org/software/stow/). Themed consistently with **Catppuccin Mocha** across all tools.

## Packages

| Package | Tool | Description |
|---------|------|-------------|
| `bat` | [bat](https://github.com/sharkdp/bat) | Syntax-highlighted cat replacement |
| `claude` | [Claude Code](https://docs.anthropic.com/en/docs/claude-code) | AI coding assistant settings and statusline |
| `ghostty` | [Ghostty](https://ghostty.org/) | Terminal emulator |
| `git` | [Git](https://git-scm.com/) | Git config with [delta](https://github.com/dandavella/delta) pager and LFS |
| `lazygit` | [lazygit](https://github.com/jesseduffield/lazygit) | Git TUI client |
| `nvim` | [Neovim](https://neovim.io/) | Editor powered by [LazyVim](https://www.lazyvim.org/) |
| `starship` | [Starship](https://starship.rs/) | Minimal cross-shell prompt |
| `tmux` | [tmux](https://github.com/tmux/tmux) | Terminal multiplexer |
| `zellij` | [Zellij](https://zellij.dev/) | Terminal multiplexer (tmux alternative) |
| `zsh` | [Zsh](https://www.zsh.org/) | Shell config with aliases and plugins |

## Setup

### Prerequisites

- macOS
- [Homebrew](https://brew.sh/)
- [GNU Stow](https://www.gnu.org/software/stow/) (`brew install stow`)

### Installation

```sh
git clone https://github.com/yepengfan/dotfiles.git ~/.dotfiles
cd ~/.dotfiles

# Symlink all packages
stow */

# Or symlink individual packages
stow nvim
stow zsh
```

### Removing symlinks

```sh
stow -D nvim   # Remove a single package
stow -D */     # Remove all packages
```

## Key Integrations

- **Smart Splits** — seamless `Ctrl+hjkl` navigation between Neovim splits and multiplexer panes (Zellij, tmux)
- **Claude Code via Zellij** — AI assistant runs in a persistent Zellij pane with Neovim keymaps to send context
- **Modern CLI replacements** — `eza` (ls), `bat` (cat), `delta` (diff), `zoxide` (cd), `fzf` (fuzzy finder)
- **Lazy-loaded NVM** — deferred Node version manager loading for faster shell startup

## Claude Code + Neovim Usage

Claude Code runs in a Zellij pane to the right of Neovim. This setup allows persistent sessions that survive editor restarts, unlike the embedded terminal approach.

### Prerequisites

- Zellij running with at least two panes: Neovim (left) and Claude Code (right)

### Keybindings

All keybindings use the `<leader>a` prefix ("ai" group):

| Keymap | Mode | Description |
|---|---|---|
| `<leader>af` | Normal | Focus the Claude Code pane |
| `<leader>ar` | Normal | Send `file:line` reference to Claude, return to Neovim |
| `<leader>ab` | Normal | Send the current file path to Claude, return to Neovim |
| `<leader>as` | Visual | Send `file:start-end` range reference to Claude, return to Neovim |

### Workflow

1. Open Neovim and Claude Code side-by-side in Zellij
2. Use `<leader>af` to switch focus to Claude at any time
3. Use `Ctrl+h` to return focus to Neovim (via vim-zellij-navigator)
4. To share code context, position your cursor or select code in Neovim:
   - `<leader>ar` — sends a reference like `src/main.lua:42`
   - `<leader>ab` — sends the file path like `src/main.lua`
   - `<leader>as` (visual mode) — sends a `file:start-end` range reference (Claude reads the file itself)
5. Text is typed into the Claude input without pressing Enter, so you can review or edit before submitting
