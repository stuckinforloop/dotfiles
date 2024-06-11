--[[
-- Setup initial configuration,
--
-- Primarily just download and execute lazy.nvim
--]]
vim.g.mapleader = "<space>"

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable",
		lazypath,
	})
end

-- Add lazy to the `runtimepath`, this allows us to `require` it.
---@diagnostic disable-next-line: undefined-field
vim.opt.rtp:prepend(lazypath)

vim.cmd("luafile ~/.config/nvim/core/options.lua")
vim.cmd("luafile ~/.config/nvim/core/keymaps.lua")

-- Set up lazy, and load my `lua/plugins/` folder
require("lazy").setup({ import = "plugins" }, {
	change_detection = {
		notify = false,
	},
})
