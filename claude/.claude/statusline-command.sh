#!/usr/bin/env bash
# Claude Code statusLine command
# Catppuccin Mocha colors.
# Receives JSON from Claude Code via stdin.

input=$(cat)

# --- Colors (Catppuccin Mocha) ---
yellow="\033[38;2;249;226;175m"     # context
peach="\033[38;2;250;179;135m"      # cost
teal="\033[38;2;148;226;213m"       # lines changed
sky="\033[38;2;137;220;235m"        # vim mode
flamingo="\033[38;2;242;205;205m"   # api duration
sapphire="\033[38;2;116;199;236m"   # tokens
reset="\033[0m"
bold="\033[1m"

# --- Context window ---
remaining=$(echo "$input" | jq -r '.context_window.remaining_percentage // empty')

# --- Session cost ---
cost=$(echo "$input" | jq -r '.cost.total_cost_usd // empty')
if [ -n "$cost" ]; then
  cost=$(printf "%.2f" "$cost")
fi

# --- Lines changed ---
lines_added=$(echo "$input" | jq -r '.cost.total_lines_added // 0')
lines_removed=$(echo "$input" | jq -r '.cost.total_lines_removed // 0')

# --- Vim mode ---
vim_mode=$(echo "$input" | jq -r '.vim.mode // empty')

# --- API duration ---
api_duration_ms=$(echo "$input" | jq -r '.cost.total_api_duration_ms // empty')
if [ -n "$api_duration_ms" ]; then
  api_duration_s=$(( api_duration_ms / 1000 ))
  api_min=$(( api_duration_s / 60 ))
  api_sec=$(( api_duration_s % 60 ))
  if [ "$api_min" -gt 0 ]; then
    api_duration="${api_min}m${api_sec}s"
  else
    api_duration="${api_sec}s"
  fi
fi

# --- Token counts ---
input_tokens=$(echo "$input" | jq -r '.context_window.total_input_tokens // 0')
output_tokens=$(echo "$input" | jq -r '.context_window.total_output_tokens // 0')
# Format with k suffix
format_tokens() {
  local t=$1
  if [ "$t" -ge 1000000 ]; then
    printf "%.1fM" "$(echo "scale=1; $t / 1000000" | bc)"
  elif [ "$t" -ge 1000 ]; then
    printf "%.1fk" "$(echo "scale=1; $t / 1000" | bc)"
  else
    printf "%d" "$t"
  fi
}
input_tokens_fmt=$(format_tokens "$input_tokens")
output_tokens_fmt=$(format_tokens "$output_tokens")

# --- Assemble output ---
out=""

if [ -n "$remaining" ]; then
  out+=$(printf "${yellow}ctx: %s%%%s" "$remaining" "${reset}")
fi

if [ -n "$cost" ]; then
  [ -n "$out" ] && out+="  "
  out+=$(printf "${peach}\$%s${reset}" "$cost")
fi

if [ "$lines_added" -gt 0 ] || [ "$lines_removed" -gt 0 ]; then
  [ -n "$out" ] && out+="  "
  out+=$(printf "${teal}+%s -%s${reset}" "$lines_added" "$lines_removed")
fi

if [ -n "$vim_mode" ]; then
  [ -n "$out" ] && out+="  "
  out+=$(printf "${bold}${sky}%s${reset}" "$vim_mode")
fi

if [ -n "$api_duration_ms" ] && [ "$api_duration_ms" -gt 0 ]; then
  [ -n "$out" ] && out+="  "
  out+=$(printf "${flamingo}api: %s${reset}" "$api_duration")
fi

if [ "$input_tokens" -gt 0 ] || [ "$output_tokens" -gt 0 ]; then
  [ -n "$out" ] && out+="  "
  out+=$(printf "${sapphire}in: %s out: %s${reset}" "$input_tokens_fmt" "$output_tokens_fmt")
fi

printf "%b" "$out"
