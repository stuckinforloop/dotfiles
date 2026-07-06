return {
	"dmtrKovalenko/fff.nvim",
	build = function()
		-- downloads a prebuilt binary or falls back to cargo build
		require("fff.download").download_or_build_binary()
	end,
	-- for nixos:
	-- build = "nix run .#release",
	opts = {
		debug = {
			enabled = false,
			show_scores = false,
		},
	},
	lazy = false, -- the plugin lazy-initialises itself
}
