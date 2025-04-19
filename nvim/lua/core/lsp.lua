local M = {}

function M.setup()
    vim.lsp.enable({ "lua_ls", "gopls" })

    vim.diagnostic.config({
        virtual_lines = true
    })
end

return M
