return {
	"epwalsh/obsidian.nvim",
	version = "*",
	-- lazy = true,
	-- ft = "markdown",
	-- event = {
	-- 	-- If you want to use the home shortcut '~' here you need to call 'vim.fn.expand'.
	-- 	-- E.g. "BufReadPre " .. vim.fn.expand "~" .. "/my-vault/*.md"
	-- 	-- refer to `:h file-pattern` for more examples
	-- 	"BufReadPre /Users/neel.modi/Documents/ironkeep/*.md",
	-- 	"BufNewFile /Users/neel.modi/Documents/ironkeep/*.md",
	-- },
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-telescope/telescope.nvim",
		"hrsh7th/nvim-cmp",
	},
	opts = {
		workspaces = {
			{
				name = "work",
				path = "/Users/neel.modi/Documents/ironkeep",
			},
			{
				name = "personal",
				path = "/Users/neel.modi/Library/Mobile Documents/iCloud~md~obsidian/Documents/vault",
			},
		},
	},
	config = function(_, opts)
		require("obsidian").setup(opts)
	end,
}
