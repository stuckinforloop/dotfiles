local M = {}

-- Import LSP autocmds
local lsp = require("autocmds.lsp")

function M.setup()
    -- Setup LSP autocmds
    lsp.setup()
end

return M
