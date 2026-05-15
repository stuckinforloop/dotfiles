local M = {}

local autocmds = require("core.autocmds")
local keymaps = require("core.keymaps")
local options = require("core.options")

function M.setup()
	options.setup()
	keymaps.setup()
	autocmds.setup()
end

return M
