return {
	{
		"ellisonleao/gruvbox.nvim",
		priority = 1000,
		config = function()
			require("gruvbox").setup({
				bold = true,
				dim_inactive = true,
				invert_selection = true,
				italic = {
					strings = false,
					emphasis = false,
					comments = false,
					operators = false,
					folds = false,
				},
				transparent_mode = true,
				terminal_colors = true,
				underline = false,
			})
		end,
	},
	{
		"rose-pine/neovim",
		name = "rose-pine",
		priority = 1000,
		config = function()
			require("rose-pine").setup({
				disable_background = true,
				styles = {
					italic = false,
				},
				vim.cmd("colorscheme rose-pine-moon"),
			})
		end,
	},
	{
		"xiyaowong/transparent.nvim",
		priority = 1000,
		config = function()
			require("transparent").setup({
				extra_groups = {
					"NormalFloat", -- plugins which have float panel such as Lazy, Mason, LspInfo
				},
			})
		end,
	},
	{
		"folke/tokyonight.nvim",
		priority = 1000,
		opts = {
			transparent = true,
			styles = {
				sidebars = "transparent",
				floats = "transparent",
			},
		},
	},
	{
		"catppuccin/nvim",
		name = "catppuccin",
		priority = 1000,
		opts = {
			transparent_background = true,
		},
	},
	{
		"rebelot/kanagawa.nvim",
		priority = 1000,
		opts = {
			transparent = true,
		},
	},
	-- {
	-- 	event = "VeryLazy",
	-- 	config = function()
	-- 		function ColorMyPencils(color)
	-- 			color = color or "rose-pine-moon"
	-- 			vim.cmd.colorscheme(color)
	-- 			vim.opt.fillchars = { eob = " " }

	-- 			vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
	-- 			vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
	-- 			vim.api.nvim_set_hl(0, "Select", { bg = "none" })
	-- 			vim.api.nvim_set_hl(0, "WinSeparator", { bg = "none" })
	-- 			vim.api.nvim_set_hl(0, "VertSplit", { bg = "none" })
	-- 		end

	-- 		ColorMyPencils()
	-- 	end,
	-- },
}
