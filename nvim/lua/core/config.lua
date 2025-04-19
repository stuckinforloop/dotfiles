local M = {}

function M.setup()
    -- UI Options
    vim.opt.number = false         -- Show line numbers
    vim.opt.relativenumber = false -- Show relative line numbers
    vim.opt.numberwidth = 4        -- Width of number column
    vim.opt.cursorline = false     -- Highlight current line
    vim.opt.signcolumn = "yes"     -- Always show sign column
    vim.opt.scrolloff = 5          -- Keep 5 lines above/below cursor
    vim.opt.sidescrolloff = 5      -- Keep 5 columns left/right of cursor
    vim.opt.wrap = true            -- Wrap lines
    vim.opt.showmode = false       -- Don't show mode in command line
    vim.opt.showtabline = 0        -- Don't show tabline
    vim.opt.termguicolors = true   -- Enable true color support
    vim.opt.background = "dark"    -- Use dark background
    vim.opt.winblend = 0           -- Window transparency
    vim.opt.laststatus = 10        -- Always show statusline
    vim.opt.pumheight = 10         -- Popup menu height
    vim.opt.pumblend = 5           -- Popup menu transparency

    -- Search Options
    vim.opt.ignorecase = true    -- Case insensitive search
    vim.opt.smartcase = true     -- Case sensitive when uppercase present
    vim.opt.hlsearch = true      -- Highlight search results
    vim.opt.inccommand = "split" -- Show substitution preview in split

    -- Indentation Options
    vim.opt.tabstop = 4        -- Number of spaces a tab represents
    vim.opt.shiftwidth = 4     -- Number of spaces for indentation
    vim.opt.expandtab = true   -- Convert tabs to spaces
    vim.opt.smartindent = true -- Smart auto-indentation

    -- Performance Options
    vim.opt.updatetime = 300  -- Faster completion
    vim.opt.timeoutlen = 1000 -- Time to wait for a mapped sequence

    -- File Options
    vim.opt.backup = false         -- Don't create backup files
    vim.opt.writebackup = false    -- Don't create backup while editing
    vim.opt.swapfile = false       -- Don't create swap files
    vim.opt.undofile = true        -- Enable persistent undo
    vim.opt.fileencoding = "utf-8" -- File encoding
    vim.opt.conceallevel = 0       -- Show concealed text

    -- Window Options
    vim.opt.splitright = true -- Vertical splits open to the right
    vim.opt.splitbelow = true -- Horizontal splits open below

    -- Completion Options
    vim.opt.completeopt = { "menuone", "noselect" } -- Completion options
    vim.opt.wildoptions = "pum"                     -- Use popup menu for wildmenu

    -- Global Variables
    vim.g.mapleader = " "       -- Set space as the leader key
    vim.g.maplocalleader = "\\" -- Set backslash as the local leader key

    -- System Integration
    vim.opt.clipboard = "unnamedplus" -- Use system clipboard
    vim.opt.mouse = "a"               -- Enable mouse in all modes

    -- Session Options
    -- '10: Save marks for last 10 files
    -- <0: No limit on item size
    -- s10: Save last 10 registers
    -- h: Save all search history
    -- /10: Save last 10 search patterns
    vim.opt.shada = { "'10", "<0", "s10", "h", "/10" } -- Session options

    -- Format Options
    vim.opt.formatoptions:remove("o") -- Don't continue comments on new line

    -- Create undo directory if it doesn't exist
    local undo_dir = vim.fn.stdpath("data") .. "/undo"
    if not vim.loop.fs_stat(undo_dir) then
        vim.fn.mkdir(undo_dir, "p")
    end
end

return M
