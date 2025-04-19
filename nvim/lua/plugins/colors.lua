return {
	"ellisonleao/gruvbox.nvim",
	dependencies = {
		"xiyaowong/transparent.nvim",
	},
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

		function ColorMyPencils(color)
			color = color or "gruvbox"
			vim.cmd.colorscheme(color)
			vim.opt.fillchars = { eob = " " }

			vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
			vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
			vim.api.nvim_set_hl(0, "Select", { bg = "none" })
			vim.api.nvim_set_hl(0, "WinSeparator", { bg = "none" })
			vim.api.nvim_set_hl(0, "VertSplit", { bg = "none" })

			require("transparent").setup({
				extra_groups = {
					"NormalFloat", -- plugins which have float panel such as Lazy, Mason, LspInfo
				},
			})
		end

		ColorMyPencils()
	end,
}

-- return {
-- 	"sainnhe/gruvbox-material",
-- 	dependencies = {
-- 		"xiyaowong/transparent.nvim",
-- 	},
-- 	enabled = true,
-- 	priority = 1000,
-- 	config = function()
-- 		vim.g.gruvbox_material_transparent_background = 1
-- 		-- vim.g.gruvbox_material_foreground = "mix"
-- 		-- vim.g.gruvbox_material_background = "hard"
-- 		-- vim.g.gruvbox_material_ui_contrast = "high"
-- 		-- vim.g.gruvbox_material_float_style = "bright"
-- 		-- vim.g.gruvbox_material_statusline_style = "material"
-- 		vim.g.gruvbox_material_cursor = "auto"
-- 		vim.opt.fillchars = { eob = " " }
-- 		vim.g.gruvbox_material_colors_override = {
-- 			bg0 = "#0e1010",
-- 		}
-- 		vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
-- 		vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
-- 		vim.api.nvim_set_hl(0, "Select", { bg = "none" })
-- 		vim.api.nvim_set_hl(0, "WinSeparator", { bg = "none" })
-- 		vim.api.nvim_set_hl(0, "VertSplit", { bg = "none" })

-- 		require("transparent").setup({
-- 			extra_groups = {
-- 				"NormalFloat", -- plugins which have float panel such as Lazy, Mason, LspInfo
-- 			},
-- 		})

-- 		vim.cmd.colorscheme("gruvbox-material")
-- 	end,
-- }
