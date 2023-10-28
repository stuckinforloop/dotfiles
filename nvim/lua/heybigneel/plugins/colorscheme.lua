return {
	"ellisonleao/gruvbox.nvim",
	dependencies = {
		"xiyaowong/transparent.nvim",
	},
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

		function ColorMyPencils(color)
			color = color or "gruvbox"
			vim.cmd.colorscheme(color)

			-- vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
			-- vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
			-- vim.api.nvim_set_hl(0, "Select", { bg = "none" })
			require("transparent").setup()
		end
		ColorMyPencils()
	end,
}
