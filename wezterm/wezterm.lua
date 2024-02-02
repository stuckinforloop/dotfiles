local wezterm = require("wezterm")

return {
	enable_tab_bar = false,
	font = wezterm.font("MonoLisa Nerd Font Mono", { weight = 700 }),
	-- font_size = 14.0,
	font_size = 17.0, -- monitor
	line_height = 1.3,
	color_scheme = "gruvbox_custom",
	colors = {
		foreground = "#fbf1c7",
		background = "#181818",
		cursor_bg = "#928374",
		cursor_fg = "black",
		cursor_border = "#928374",
		selection_fg = "#928374",
		selection_bg = "#ebdbb2",
		scrollbar_thumb = "#222222",
		split = "#444444",
		ansi = {
			"#1d2021", -- black, color 0
			"#cc241d", -- red, color 1
			"#98971a", -- green, color 2
			"#d79921",
			"#458588",
			"#b16286",
			"#689d6a",
			"#a89984",
		},
		brights = {
			"#7c6f64", -- black, color 0
			"#fb4934", -- red, color 1
			"#b8bb26", -- green, color 2
			"#fabd2f",
			"#83a598",
			"#d3869b",
			"#8ec07c",
			"#fbf1c7",
		},
	},
}
