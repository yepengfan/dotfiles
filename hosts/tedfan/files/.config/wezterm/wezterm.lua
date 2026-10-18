local wezterm = require("wezterm")

local function clear_focus_appearance(window)
	local overrides = window:get_config_overrides() or {}
	if overrides.window_background_opacity ~= nil or overrides.foreground_text_hsb ~= nil then
		overrides.window_background_opacity = nil
		overrides.foreground_text_hsb = nil
		window:set_config_overrides(overrides)
	end
end

-- Run before the shared handler so this host keeps the same appearance on blur.
wezterm.on("window-focus-changed", function(window)
	clear_focus_appearance(window)
	return false
end)
wezterm.on("window-config-reloaded", clear_focus_appearance)

local config = dofile(wezterm.home_dir .. "/.dotfiles/home/.config/wezterm/wezterm.lua")

config.window_decorations = "TITLE | RESIZE"
config.window_background_opacity = 1.0
config.macos_window_background_blur = 0

config.font = wezterm.font_with_fallback({
  "Hack Nerd Font",
  "PingFang SC",
})

return config
