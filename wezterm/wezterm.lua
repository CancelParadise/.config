local wezterm = require("wezterm")
local config = wezterm.config_builder()

-- Theme
config.color_scheme = "Tokyo Night"

-- Font
config.font = wezterm.font("JetBrains Mono")
config.font_size = 12.0

-- Window
config.window_background_opacity = 0.95
config.hide_tab_bar_if_only_one_tab = true

-- Environment
config.set_environment_variables = {
	TERM_PROGRAM = "wezterm",
}

return config
