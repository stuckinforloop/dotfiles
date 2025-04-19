-- Neovim's main configuration file
-- This is the entry point that loads all other configuration files

-- Add the lua directory to the runtime path
-- This allows Neovim to find our Lua modules
-- vim.fn.stdpath("config") returns the path to your Neovim config directory
vim.opt.rtp:prepend(vim.fn.stdpath("config"))

-- Load core configuration first
-- This sets up essential settings, plugin management, and LSP
require("core")

-- Load other configuration modules
-- require("options")  -- Neovim options and settings
-- require("keymaps")  -- Key mappings
require("autocmds") -- Autocommands and events
-- require("plugins")  -- Plugin configurations
