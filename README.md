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

- **Vim-Tmux Navigator** — seamless `Ctrl+hjkl` navigation between Neovim splits and tmux panes
- **Claude Code in Neovim** — AI assistant accessible via custom keybindings
- **Modern CLI replacements** — `eza` (ls), `bat` (cat), `delta` (diff), `zoxide` (cd), `fzf` (fuzzy finder)
- **Lazy-loaded NVM** — deferred Node version manager loading for faster shell startup
