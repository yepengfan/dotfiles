local wezterm = require("wezterm")
local config = dofile(wezterm.home_dir .. "/.dotfiles/home/.config/wezterm/wezterm.lua")

config.font = wezterm.font_with_fallback({
  "Hack Nerd Font",
  "PingFang SC",
})

return config
