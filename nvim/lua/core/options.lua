local M = {}

function M.setup()
  local options = {
    -- system level
    backup = false,
    writebackup = false,
    backspace = { "indent", "eol", "start" },
    clipboard = { "unnamed", "unnamedplus" },
    mouse = "a",
    history = 10000,
    swapfile = false,
    conceallevel = 2,
    smoothscroll = true,

    -- file level
    fileencoding = "utf-8",
    smartindent = true,
    autoindent = true,
    shiftwidth = 4,
    tabstop = 4,
    expandtab = true,
    undofile = true,

    -- appearance
    fcs = "eob: ",
    termguicolors = true,
    number = false,
    relativenumber = false,
    cursorline = false,
    numberwidth = 4,
    cursorcolumn = false,
    wrap = true,
    linebreak = true,
    ttyfast = true,
    textwidth = 100,
    laststatus = 0,
    scrolloff = 8,
    wildmenu = true,
    showcmd = true,
    showmode = false,
    showmatch = true,
    hidden = true,
    updatetime = 300,
    pumheight = 10,
    pumblend = 5,
    splitbelow = true,
    splitright = true,
    showtabline = 2,
    signcolumn = "yes",
    winborder = "rounded",

    completeopt = { "menuone", "noselect" },
    timeoutlen = 1000,
    sidescrolloff = 5,
    background = "dark",
    winblend = 0,
    wildoptions = "pum",
    inccommand = "split",
    shada = { "'10", "<0", "s10", "h" },

    -- search
    grepprg = "rg --vimgrep --no-heading --smart-case",
    grepformat = "%f:%l:%c:%m",
    ignorecase = true,
    smartcase = true,
    hlsearch = true,
    incsearch = true,
    lazyredraw = false,
    magic = true,
  }

  for k, v in pairs(options) do
    vim.opt[k] = v
  end
end

return M
