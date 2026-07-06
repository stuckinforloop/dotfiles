return {
	"craftzdog/solarized-osaka.nvim",
	name = "solarized-osaka",
	lazy = false,
	priority = 1000,
	config = function()
		require("solarized-osaka").setup({
			transparent = true,
		})

		vim.cmd.colorscheme("solarized-osaka")
	end,
}
