local opts = { noremap = true, silent = true }

-- local term_opts = { silent = true }

-- Shorten function name
local keymap = vim.api.nvim_set_keymap

--Remap comma as leader key
local leaderKey = ","
keymap("", leaderKey, "<Nop>", { noremap = true, silent = true })
vim.g.mapleader = leaderKey
vim.g.maplocalleader = " "

-- Modes
--   normal_mode = "n",
--   insert_mode = "i",
--   visual_mode = "v",
--   visual_block_mode = "x",
--   term_mode = "t",
--   command_mode = "c",

-- Normal --
-- Better window navigation
keymap("n", "<C-h>", "<C-w>h", { desc = "Go left", noremap = true, silent = true })
keymap("n", "<C-j>", "<C-w>j", { desc = "Go down", noremap = true, silent = true })
keymap("n", "<C-k>", "<C-w>k", { desc = "Go up", noremap = true, silent = true })
keymap("n", "<C-l>", "<C-w>l", { desc = "Go right", noremap = true, silent = true })

-- Resize with arrows
-- <Control-arrows> is system short key in MacOS
keymap("n", "<M-Up>", ":resize -2<CR>", { desc = "-Height", noremap = true, silent = true })
keymap("n", "<M-Down>", ":resize +2<CR>", { desc = "+Height", noremap = true, silent = true })
keymap("n", "<M-Left>", ":vertical resize -2<CR>", { desc = "-Width", noremap = true, silent = true })
keymap("n", "<M-Right>", ":vertical resize +2<CR>", { desc = "+Width", noremap = true, silent = true })

-- Navigate buffers
keymap("n", "L", ":bnext<CR>", { desc = "Prev buffer", noremap = true, silent = true })
keymap("n", "H", ":bprevious<CR>", { desc = "Next buffer", noremap = true, silent = true })

-- Move text up and down
keymap("n", "gj", "<Esc>:m .+1<CR>==gi", { desc = "Move text down", noremap = true, silent = true })
keymap("n", "gk", "<Esc>:m .-2<CR>==gi", { desc = "Move text up", noremap = true, silent = true })

-- Insert --
-- Press jk fast to enter
keymap("i", "jk", "<ESC>", { desc = "ESC", noremap = true, silent = true })

-- Visual --
-- Stay in indent mode
-- keymap("v", "<", "<gv", { noremap = true, silent = true })
-- keymap("v", ">", ">gv", { noremap = true, silent = true })

-- Move text up and down
keymap("v", "J", ":m .+1<CR>==", { desc = "Move text down", noremap = true, silent = true })
keymap("v", "K", ":m .-2<CR>==", { desc = "Move text Up", noremap = true, silent = true })

-- paste and replace
keymap("v", "p", '"_dP', { desc = "Paste & replace", noremap = true, silent = true })

-- Visual Block --
-- Move text up and down
keymap("x", "J", ":move '>+1<CR>gv-gv", { desc = "Move text down", noremap = true, silent = true })
keymap("x", "K", ":move '<-2<CR>gv-gv", { desc = "Move text up", noremap = true, silent = true })

keymap("n", "<leader>h", "<cmd>nohlsearch<CR>", { desc = "No Highlight Search", noremap = true, silent = true })
keymap("n", "<leader>q", "<cmd>x<cr>", { desc = "Close Window", noremap = true, silent = true })
keymap("n", "<leader>Q", "<cmd>xa<cr>", { desc = "Quit Nvim", noremap = true, silent = true })
