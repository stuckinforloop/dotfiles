-- Core Neovim configuration module
-- This module sets up essential settings and plugin management

local M = {}

-- Import submodules
local config = require("core.config")
local lazy = require("core.lazy")
local lsp = require("core.lsp")

function M.setup()
  -- Setup core configuration first
  config.setup()

  -- Setup lazy.nvim
  lazy.setup()

  -- Setup LSP
  lsp.setup()
end

-- Initialize the module
M.setup()

return M
