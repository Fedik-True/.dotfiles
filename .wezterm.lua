local wezterm = require("wezterm")
local config = wezterm.config_builder()

-- PowerShell 7 (native ARM64) rather than the built-in Windows PowerShell 5.1,
-- so the outer shell matches Neovim's `:terminal` (see nvim/lua/config/options.lua).
config.default_prog = { "pwsh.exe", "-NoLogo" }

config.window_background_opacity = 0.5
config.text_background_opacity = 0.95

config.window_decorations = "RESIZE"

config.win32_system_backdrop = "Acrylic"

return config
