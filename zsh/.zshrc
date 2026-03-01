# Kiro CLI pre block. Keep at the top of this file.
[[ -f "${HOME}/Library/Application Support/kiro-cli/shell/zshrc.pre.zsh" ]] && builtin source "${HOME}/Library/Application Support/kiro-cli/shell/zshrc.pre.zsh"

# --- Zellij Auto-Start ---
if [[ -x /opt/homebrew/bin/zellij && -z "$ZELLIJ" && -t 0 ]]; then
  exec /opt/homebrew/bin/zellij
fi

# --- Zsh Options ---
setopt AUTO_CD              # cd by typing directory name
setopt AUTO_PUSHD           # push directories on cd
setopt PUSHD_IGNORE_DUPS    # no duplicate dirs in stack
setopt CORRECT              # command correction
setopt INTERACTIVE_COMMENTS # allow comments in interactive shell

# --- History ---
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt SHARE_HISTORY          # share history across sessions
setopt HIST_IGNORE_ALL_DUPS   # remove older duplicate entries
setopt HIST_REDUCE_BLANKS     # remove superfluous blanks
setopt HIST_VERIFY            # show before executing history expansion
setopt APPEND_HISTORY         # append instead of overwrite

# --- Completion ---
autoload -Uz compinit
# Only regenerate .zcompdump once per day for faster startup
if [[ -n ~/.zcompdump(#qN.mh+24) ]]; then
  compinit
else
  compinit -C
fi

zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}' # case-insensitive completion
zstyle ':completion:*' menu select                       # menu-style completion
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"  # colored completions

# --- PATH ---
export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:$PATH"
export PATH="/usr/local/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"

# --- Environment ---
export EDITOR="nvim"
export VISUAL="nvim"
export LANG=en_US.UTF-8
export ANTHROPIC_MODEL="claude-opus-4-6"

# --- NVM (lazy-loaded for faster startup) ---
export NVM_DIR="$HOME/.nvm"
nvm() {
  unfunction nvm node npm npx 2>/dev/null
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
  [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
  nvm "$@"
}
node() { nvm --version >/dev/null 2>&1; unfunction node 2>/dev/null; command node "$@"; }
npm()  { nvm --version >/dev/null 2>&1; unfunction npm 2>/dev/null;  command npm "$@"; }
npx()  { nvm --version >/dev/null 2>&1; unfunction npx 2>/dev/null;  command npx "$@"; }

# --- Bun ---
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
[ -s "/Users/tedfan/.bun/_bun" ] && source "/Users/tedfan/.bun/_bun"

# --- Antigravity ---
export PATH="/Users/tedfan/.antigravity/antigravity/bin:$PATH"

# --- Aliases ---
source ~/.zsh/aliases.zsh

# --- Plugins ---
# zsh-autosuggestions
if [[ -f ~/.zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh ]]; then
  source ~/.zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
fi

# zsh-syntax-highlighting (must be last plugin sourced)
if [[ -f ~/.zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]]; then
  source ~/.zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
fi

# --- Tool Integrations ---
# Starship prompt
eval "$(starship init zsh)"

# Zoxide (smarter cd)
eval "$(zoxide init zsh)"

# fzf keybindings and completion
source <(fzf --zsh)

# Restore default history navigation (overridden by plugins)
bindkey '^P' up-line-or-history
bindkey '^N' down-line-or-history

# --- Kiro ---
[[ "$TERM_PROGRAM" == "kiro" ]] && . "$(kiro --locate-shell-integration-path zsh)"

# Kiro CLI post block. Keep at the bottom of this file.
[[ -f "${HOME}/Library/Application Support/kiro-cli/shell/zshrc.post.zsh" ]] && builtin source "${HOME}/Library/Application Support/kiro-cli/shell/zshrc.post.zsh"
