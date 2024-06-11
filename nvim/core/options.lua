local options = {
    backup = false,
    clipboard = "unnamedplus",
    completeopt = { "menuone", "noselect" },
    conceallevel = 0,
    fileencoding = "utf-8",
    hlsearch = true,
    ignorecase = true,
    mouse = "a",
    pumheight = 10,
    pumblend = 5,
    showmode = false,
    showtabline = 0,
    smartcase = true,
    smartindent = true,
    splitbelow = true,
    splitright = true,
    swapfile = false,
    termguicolors = true,
    timeoutlen = 1000,
    undofile = true,
    updatetime = 300,
    writebackup = false,
    expandtab = true,
    shiftwidth = 4,
    tabstop = 4,
    cursorline = false,
    number = false,
    relativenumber = false,
    numberwidth = 4,
    signcolumn = "yes",
    wrap = true,
    scrolloff = 5,
    sidescrolloff = 5,
    laststatus = 0,
    background = "dark",
    winblend = 0,
    wildoptions = "pum",
    inccommand = "split",
    shada = { "'10", "<0", "s10", "h" }
}

for k, v in pairs(options) do
    vim.opt[k] = v
end

vim.opt.formatoptions:remove "o"
