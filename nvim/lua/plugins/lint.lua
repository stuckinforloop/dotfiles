return {
	{
		"mfussenegger/nvim-lint",
		event = { "BufReadPre", "BufNewFile" },
		config = function()
			local lint = require("lint")

			local function has(bin)
				return vim.fn.executable(bin) == 1
			end

			local by_ft = {
				lua = has("selene") and { "selene" } or {},
				javascript = has("eslint_d") and { "eslint_d" } or {},
				javascriptreact = has("eslint_d") and { "eslint_d" } or {},
				typescript = has("eslint_d") and { "eslint_d" } or {},
				typescriptreact = has("eslint_d") and { "eslint_d" } or {},
				markdown = has("markdownlint") and { "markdownlint" } or {},
			}

			lint.linters_by_ft = by_ft

			local lint_augroup = vim.api.nvim_create_augroup("nvim_lint", { clear = true })
			vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
				group = lint_augroup,
				callback = function()
					lint.try_lint()
				end,
			})

			vim.keymap.set("n", "<leader>cl", function()
				lint.try_lint()
			end, { desc = "Run lint" })
		end,
	},
}
