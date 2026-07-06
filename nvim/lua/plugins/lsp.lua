return {
	{
		"neovim/nvim-lspconfig",
		dependencies = {
			{
				"folke/lazydev.nvim",
				ft = "lua",
				opts = {
					library = {
						{ path = "${3rd}/luv/library", words = { "vim%.uv" } },
					},
				},
			},
			{ "Bilal2453/luvit-meta", lazy = true },
			"williamboman/mason.nvim",
			"williamboman/mason-lspconfig.nvim",
		},
		config = function()
			require("mason").setup()

			local ts_root = function(bufnr)
				return vim.fs.root(bufnr, { "tsconfig.json", "jsconfig.json", "package.json", ".git" })
			end

			local servers = {
				lua_ls = {
					settings = {
						Lua = {
							diagnostics = { globals = { "vim" } },
							workspace = { checkThirdParty = false },
							hint = {
								enable = true,
								setType = false,
								paramType = true,
								paramName = "Disable",
								semicolon = "Disable",
								arrayIndex = "Disable",
							},
						},
					},
				},
				gopls = {
					settings = {
						gopls = {
							hints = {
								assignVariableTypes = true,
								compositeLiteralFields = true,
								compositeLiteralTypes = true,
								constantValues = true,
								functionTypeParameters = true,
								parameterNames = true,
								rangeVariableTypes = true,
							},
						},
					},
				},
				rust_analyzer = {},
				ts_ls = {
					root_dir = ts_root,
					single_file_support = false,
					settings = {
						typescript = {
							inlayHints = {
								includeInlayParameterNameHints = "literal",
								includeInlayParameterNameHintsWhenArgumentMatchesName = false,
								includeInlayFunctionParameterTypeHints = true,
								includeInlayVariableTypeHints = true,
								includeInlayPropertyDeclarationTypeHints = true,
								includeInlayFunctionLikeReturnTypeHints = true,
								includeInlayEnumMemberValueHints = true,
							},
						},
						javascript = {
							inlayHints = {
								includeInlayParameterNameHints = "all",
								includeInlayParameterNameHintsWhenArgumentMatchesName = false,
								includeInlayFunctionParameterTypeHints = true,
								includeInlayVariableTypeHints = true,
								includeInlayPropertyDeclarationTypeHints = true,
								includeInlayFunctionLikeReturnTypeHints = true,
								includeInlayEnumMemberValueHints = true,
							},
						},
					},
				},
			}

			local ensure_installed = { "lua_ls", "gopls", "rust_analyzer", "ts_ls" }

			vim.diagnostic.config({
				underline = true,
				update_in_insert = false,
				severity_sort = true,
				virtual_text = {
					spacing = 2,
					source = "if_many",
					prefix = "●",
				},
				float = {
					border = "rounded",
					source = "if_many",
					focusable = false,
				},
				signs = {
					text = {
						[vim.diagnostic.severity.ERROR] = " ",
						[vim.diagnostic.severity.WARN] = " ",
						[vim.diagnostic.severity.HINT] = " ",
						[vim.diagnostic.severity.INFO] = " ",
					},
				},
			})

			local capabilities = vim.lsp.protocol.make_client_capabilities()
			local ok, blink = pcall(require, "blink.cmp")
			if ok and blink.get_lsp_capabilities then
				capabilities = blink.get_lsp_capabilities(capabilities)
			end

			local function on_attach(_, bufnr)
				if vim.lsp.inlay_hint then
					pcall(vim.lsp.inlay_hint.enable, true, { bufnr = bufnr })
				end
			end

			for server, server_opts in pairs(servers) do
				server_opts.capabilities = capabilities
				server_opts.on_attach = on_attach
				vim.lsp.config(server, server_opts)
			end

			require("mason-lspconfig").setup({
				ensure_installed = ensure_installed,
				automatic_enable = true,
			})
		end,
	},
}
