#!/usr/bin/env bash
# Claude Code statusLine command
# Mirrors the Starship prompt style with Catppuccin Mocha colors.
# Receives JSON from Claude Code via stdin.

input=$(cat)

# --- Colors (Catppuccin Mocha) ---
lavender="\033[38;2;180;190;254m"   # directory
mauve="\033[38;2;203;166;247m"      # git branch
red="\033[38;2;243;139;168m"        # git status / dirty
green="\033[38;2;166;227;161m"      # model
yellow="\033[38;2;249;226;175m"     # context
reset="\033[0m"
bold="\033[1m"

# --- Directory (truncated to 3 segments, like Starship) ---
cwd=$(echo "$input" | jq -r '.workspace.current_dir // .cwd // ""')
if [ -n "$cwd" ]; then
  # Replace $HOME with ~
  home="$HOME"
  cwd="${cwd/#$home/~}"
  # Truncate to last 3 path segments
  segment_count=$(echo "$cwd" | tr '/' '\n' | grep -c .)
  if [ "$segment_count" -gt 3 ]; then
    cwd=$(echo "$cwd" | rev | cut -d'/' -f1-3 | rev)
    cwd=".../$cwd"
  fi
fi

# --- Git branch & status ---
git_branch=""
git_dirty=""
proj_dir=$(echo "$input" | jq -r '.workspace.current_dir // .cwd // "."')
if git -C "$proj_dir" rev-parse --git-dir >/dev/null 2>&1; then
  git_branch=$(git -C "$proj_dir" -c core.hooksPath=/dev/null rev-parse --abbrev-ref HEAD 2>/dev/null)
  git_status_flags=$(git -C "$proj_dir" -c core.hooksPath=/dev/null status --porcelain 2>/dev/null)
  if [ -n "$git_status_flags" ]; then
    git_dirty="!"
  fi
  upstream=$(git -C "$proj_dir" -c core.hooksPath=/dev/null rev-parse --abbrev-ref '@{upstream}' 2>/dev/null)
  if [ -n "$upstream" ]; then
    ahead=$(git -C "$proj_dir" -c core.hooksPath=/dev/null rev-list --count "@{upstream}..HEAD" 2>/dev/null || echo 0)
    behind=$(git -C "$proj_dir" -c core.hooksPath=/dev/null rev-list --count "HEAD..@{upstream}" 2>/dev/null || echo 0)
    [ "$ahead" -gt 0 ] 2>/dev/null  && git_dirty="${git_dirty}+"
    [ "$behind" -gt 0 ] 2>/dev/null && git_dirty="${git_dirty}-"
  fi
fi

# --- Model ---
model=$(echo "$input" | jq -r '.model.display_name // ""')

# --- Context window ---
remaining=$(echo "$input" | jq -r '.context_window.remaining_percentage // empty')


# --- Assemble output ---
out=""

if [ -n "$cwd" ]; then
  out+=$(printf "${bold}${lavender}%s${reset}" "$cwd")
fi

if [ -n "$git_branch" ]; then
  out+=$(printf "  ${bold}${mauve} %s${reset}" "$git_branch")
  if [ -n "$git_dirty" ]; then
    out+=$(printf " ${bold}${red}%s${reset}" "$git_dirty")
  fi
fi

if [ -n "$model" ]; then
  [ -n "$out" ] && out+="  "
  out+=$(printf "${bold}${green}%s${reset}" "$model")
fi

if [ -n "$remaining" ]; then
  [ -n "$out" ] && out+="  "
  out+=$(printf "${yellow}ctx: %s%%%s" "$remaining" "${reset}")
fi


printf "%b" "$out"
