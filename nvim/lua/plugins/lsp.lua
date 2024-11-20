return {
	{
		"neovim/nvim-lspconfig",
		dependencies = {
			"williamboman/mason.nvim",
			"williamboman/mason-lspconfig.nvim",
			"WhoIsSethDaniel/mason-tool-installer.nvim",

			{ "j-hui/fidget.nvim", opts = {} },

			-- Autoformatting
			"stevearc/conform.nvim",
		},
		config = function()
			local capabilities = nil
			if pcall(require, "cmp_nvim_lsp") then
				capabilities = require("cmp_nvim_lsp").default_capabilities()
			end

			local lspconfig = require("lspconfig")

			local servers = {
				-- bashls = true,
				gopls = true,
				lua_ls = true,
				rust_analyzer = true,
				jsonls = true,
				yamlls = true,
				ts_ls = true,
				tflint = true,
				helm_ls = true,
				ocamllsp = {
					manual_install = true,
					settings = {
						codelens = { enable = true },
					},
					filetypes = {
						"ocaml",
						"ocaml.interface",
						"ocaml.menhir",
						"ocaml.cram",
					},
				},
				clangd = {
					init_options = { clangdFileStatus = true },
					filetypes = { "c" },
				},
			}

			local servers_to_install = vim.tbl_filter(function(key)
				local t = servers[key]
				if type(t) == "table" then
					return not t.manual_install
				else
					return t
				end
			end, vim.tbl_keys(servers))

			require("mason").setup()
			local ensure_installed = {
				"stylua",
				"lua_ls",
				"delve",
			}

			vim.list_extend(ensure_installed, servers_to_install)
			require("mason-tool-installer").setup({ ensure_installed = ensure_installed })

			for name, config in pairs(servers) do
				if config == true then
					config = {}
				end
				config = vim.tbl_deep_extend("force", {}, {
					capabilities = capabilities,
				}, config)

				lspconfig[name].setup(config)
			end

			local disable_semantic_tokens = {
				lua = true,
			}

			vim.api.nvim_create_autocmd("LspAttach", {
				callback = function(args)
					local bufnr = args.buf
					local client = assert(vim.lsp.get_client_by_id(args.data.client_id), "must have valid client")

					vim.opt_local.omnifunc = "v:lua.vim.lsp.omnifunc"
					vim.keymap.set("n", "gd", vim.lsp.buf.definition, { buffer = 0 })
					vim.keymap.set("n", "gr", vim.lsp.buf.references, { buffer = 0 })
					vim.keymap.set("n", "gD", vim.lsp.buf.declaration, { buffer = 0 })
					vim.keymap.set("n", "gT", vim.lsp.buf.type_definition, { buffer = 0 })

					vim.keymap.set("n", "<space>mv", vim.lsp.buf.rename, { buffer = 0 })
					vim.keymap.set("n", "<space>ca", vim.lsp.buf.code_action, { buffer = 0 })
					vim.keymap.set("n", "<C-k>", vim.diagnostic.goto_prev, { buffer = 0 })
					vim.keymap.set("n", "<C-j>", vim.diagnostic.goto_next, { buffer = 0 })

					local filetype = vim.bo[bufnr].filetype
					if disable_semantic_tokens[filetype] then
						client.server_capabilities.semanticTokensProvider = nil
					end
				end,
			})

			-- Autoformatting Setup
			require("conform").setup({
				formatters_by_ft = {
					lua = { "stylua" },
					go = { "gofumpt" },
				},
				format_on_save = {
					lsp_fallback = true,
					async = false,
					timeout_ms = 500,
				},
			})

			vim.api.nvim_create_autocmd("BufWritePre", {
				callback = function(args)
					require("conform").format({
						bufnr = args.buf,
						lsp_fallback = true,
						quiet = true,
					})
				end,
			})

			lspconfig.phpactor.setup({
				cmd = { "phpactor", "language-server" },
				filetypes = { "php" },
				root_dir = lspconfig.util.root_pattern("composer.json", ".git", "phpactor.json"),
				init_options = {
					["language_server_phpstan.enabled"] = true,
					["language_server_psalm.enabled"] = false,
				},
			})
		end,
	},
}
