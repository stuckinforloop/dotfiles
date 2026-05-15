return {
	{
		"saghen/blink.cmp",
		version = "1.*",
		opts = {
			keymap = {
				preset = "enter",
				["<C-space>"] = { "show", "show_documentation", "hide_documentation" },
				["<C-e>"] = { "hide", "fallback" },
				["<CR>"] = { "accept", "fallback" },
				["<Tab>"] = { "select_next", "fallback" },
				["<S-Tab>"] = { "select_prev", "fallback" },
			},
			completion = {
				menu = { auto_show = true },
				documentation = { auto_show = true },
			},
			sources = {
				default = { "lsp", "path", "buffer" },
			},
			fuzzy = {
				prebuilt_binaries = {
					download = true,
					ignore_version_mismatch = true,
				},
			},
		},
	},
}
