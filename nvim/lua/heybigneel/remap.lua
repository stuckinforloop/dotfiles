local keymap = vim.api.nvim_set_keymap
local opts = { noremap = true, silent = true }

keymap("", "<Space>", "<Nop>", opts)
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Remove highlighting
keymap("n", "<ESC>", ":noh<CR>", opts)

-- Better window navigation
keymap("n", "<C-h>", "<C-w>h", opts)
keymap("n", "<C-j>", "<C-w>j", opts)
keymap("n", "<C-k>", "<C-w>k", opts)
keymap("n", "<C-l>", "<C-w>l", opts)

-- Close current buffer
keymap("n", "<leader>x", ":bd<CR>", opts)

-- Open alternate file
keymap("n", "<leader>af", "<C-^><CR>", opts)

-- Open Explorer
keymap("n", "<leader>la", ":Sex 75<CR>", opts)

-- Resize with arrows
keymap("n", "<C-Up>", ":resize +2<CR>", opts)
keymap("n", "<C-Down>", ":resize -2<CR>", opts)
keymap("n", "<C-Left>", ":vertical resize -2<CR>", opts)
keymap("n", "<C-Right>", ":vertical resize +2<CR>", opts)

-- Navigate buffers
keymap("n", "<TAB>", ":bnext<CR>", opts)
keymap("n", "<S-TAB>", ":bprevious<CR>", opts)

-- Stay in indent mode
keymap("v", "<", "<gv", opts)
keymap("v", ">", ">gv", opts)

-- Move text up and down
keymap("v", "<A-j>", ":m .+1<CR>==", opts)
keymap("v", "<A-k>", ":m .-2<CR>==", opts)
keymap("v", "p", '"_dP', opts)

-- Move text up and down
keymap("x", "J", ":move '>+1<CR>gv-gv", opts)
keymap("x", "K", ":move '<-2<CR>gv-gv", opts)
keymap("x", "<A-j>", ":move '>+1<CR>gv-gv", opts)
keymap("x", "<A-k>", ":move '<-2<CR>gv-gv", opts)

-- Harpoon
keymap("n", "<leader>ha", ':lua require("harpoon.mark").add_file()<CR>', opts)
keymap("n", "<leader>ho", ':lua require("harpoon.ui").toggle_quick_menu()<CR>', opts)
keymap("n", "<leader>he", ':lua require("harpoon.ui").nav_file(1)<CR>', opts)
keymap("n", "<leader>hl", ':lua require("harpoon.ui").nav_file(2)<CR>', opts)
keymap("n", "<leader>hf", ':lua require("harpoon.ui").nav_file(3)<CR>', opts)

-- Git
keymap("n", ";s", ":G<CR>", opts)
keymap("n", ";h", ":Git push<CR>", opts)
keymap("n", ";c", ":Git commit<CR>", opts)
keymap("n", ";a", ":GcLog<CR>", opts)
keymap("n", ";m", ":Git merge<CR>", opts)
keymap("n", ";v", ":Gvdiffsplit<CR>", opts)
keymap("n", ";o", ":Git push -u origin ", opts)

-- Telescope
keymap("n", "<leader>ff", "<cmd>Telescope find_files<cr>", opts)
keymap("n", "<leader>gw", "<cmd>Telescope live_grep<cr>", opts)
keymap("n", "<leader>fc", "<cmd>Telescope grep_string<cr>", opts)

-- Go
keymap("n", "<leader>qp", ":GoTestFunc<CR>", opts)
keymap("n", "<leader>ql", ":GoTestFile<CR>", opts)

