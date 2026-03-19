local M = {}

function M.setup()
    local keymap = vim.keymap.set
    local opts = { noremap = true, silent = true }

    -- fff picker
    local function with_fff(cb)
        local ok, fff = pcall(require, "fff")
        if not ok then
            vim.notify("fff.nvim is not ready. Run :lua require('fff.download').download_or_build_binary()",
                vim.log.levels.ERROR)
            return
        end

        local ran, err = pcall(cb, fff)
        if not ran then
            vim.notify(err, vim.log.levels.ERROR)
        end
    end

    -- search
    keymap("n", "<leader>ff", function()
        with_fff(function(fff)
            fff.find_files()
        end)
    end, { desc = "Find files" })
    keymap("n", "<leader>fg", function()
        with_fff(function(fff)
            fff.live_grep()
        end)
    end, { desc = "Live grep" })
    keymap("n", "<leader>fw", function()
        with_fff(function(fff)
            fff.live_grep({ query = vim.fn.expand("<cword>") })
        end)
    end, { desc = "Search current word" })

    -- primeagen-style fast keys
    keymap("n", "ff", function()
        with_fff(function(fff)
            fff.find_files()
        end)
    end, { desc = "FFFind files" })
    keymap("n", "fg", function()
        with_fff(function(fff)
            fff.live_grep()
        end)
    end, { desc = "LiFFFe grep" })

    -- git
    keymap("n", "<leader>s", ":Git<CR>", opts)
    keymap("n", "<leader>p", ":Git push<CR>", opts)
    keymap("n", "<leader>c", ":Git commit<CR>", opts)
    keymap("n", "<leader>v", ":Gvdiffsplit<CR>", opts)

    -- file explorer
    keymap("n", "<leader>e", ":Oil --float .<CR>", opts)

    -- primeagen-style workflow maps
    keymap("v", "J", ":m '>+1<CR>gv=gv", opts)
    keymap("v", "K", ":m '<-2<CR>gv=gv", opts)
    keymap("n", "J", "mzJ`z", opts)
    keymap("n", "<C-d>", "<C-d>zz", opts)
    keymap("n", "<C-u>", "<C-u>zz", opts)
    keymap("x", "<leader>p", [['_dP]], opts)

    keymap("n", "<C-k>", "<cmd>cnext<CR>zz", opts)
    keymap("n", "<C-j>", "<cmd>cprev<CR>zz", opts)
    keymap("n", "<leader>k", "<cmd>lnext<CR>zz", opts)
    keymap("n", "<leader>j", "<cmd>lprev<CR>zz", opts)

    -- LSP / diagnostics
    keymap("n", "gd", vim.lsp.buf.definition, opts)
    keymap("n", "gr", vim.lsp.buf.references, opts)
    keymap("n", "gD", vim.lsp.buf.declaration, opts)
    keymap("n", "gT", vim.lsp.buf.type_definition, opts)
    keymap("n", "K", vim.lsp.buf.hover, opts)
    keymap("n", "<leader>rn", vim.lsp.buf.rename, opts)
    keymap("n", "<leader>ca", vim.lsp.buf.code_action, opts)
    keymap("n", "<leader>ih", function()
        vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = 0 }), { bufnr = 0 })
    end, { desc = "Toggle inlay hints" })
    keymap("n", "<leader>cd", vim.diagnostic.open_float, opts)
    keymap("n", "[d", vim.diagnostic.goto_prev, opts)
    keymap("n", "]d", vim.diagnostic.goto_next, opts)
end

return M
