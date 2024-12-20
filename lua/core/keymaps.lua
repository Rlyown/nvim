local opts = { noremap = true, silent = true }

-- local term_opts = { silent = true }

-- Shorten function name
local keymap = vim.api.nvim_set_keymap

--Remap comma as leader key
local leaderKey = ","
keymap("", leaderKey, "<Nop>", opts)
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
keymap("n", "<C-h>", "<C-w>h", opts)
keymap("n", "<C-j>", "<C-w>j", opts)
keymap("n", "<C-k>", "<C-w>k", opts)
keymap("n", "<C-l>", "<C-w>l", opts)

-- Resize with arrows
-- <Control-arrows> is system short key in MacOS
keymap("n", "<M-Up>", ":resize -2<CR>", opts)
keymap("n", "<M-Down>", ":resize +2<CR>", opts)
keymap("n", "<M-Left>", ":vertical resize -2<CR>", opts)
keymap("n", "<M-Right>", ":vertical resize +2<CR>", opts)

-- Navigate buffers
keymap("n", "<C-n>", ":bnext<CR>", opts)
keymap("n", "<C-p>", ":bprevious<CR>", opts)
keymap("n", "L", ":bnext<CR>", opts)
keymap("n", "H", ":bprevious<CR>", opts)

-- Move text up and down
keymap("n", "gj", "<Esc>:m .+1<CR>==gi", opts)
keymap("n", "gk", "<Esc>:m .-2<CR>==gi", opts)

-- Insert --
-- Press jk fast to enter
keymap("i", "jk", "<ESC>", opts)

-- Visual --
-- Stay in indent mode
-- keymap("v", "<", "<gv", opts)
-- keymap("v", ">", ">gv", opts)

-- Move text up and down
keymap("v", "J", ":m .+1<CR>==", opts)
keymap("v", "K", ":m .-2<CR>==", opts)

-- paste and replace
keymap("v", "p", '"_dP', opts)

-- Visual Block --
-- Move text up and down
keymap("x", "J", ":move '>+1<CR>gv-gv", opts)
keymap("x", "K", ":move '<-2<CR>gv-gv", opts)

-- Open Url
-- netrw will be disabled if you use nvim-tree
--[[ local os = require("core.gvariable").os ]]
--[[ if os == "mac" then ]]
--[[ 	keymap("", "gx", '<Cmd>call jobstart(["open", expand("<cfile>")], {"detach": v:true})<CR>', opts) ]]
--[[ elseif os == "unix" then ]]
--[[ 	keymap("", "gx", '<Cmd>call jobstart(["xdg-open", expand("<cfile>")], {"detach": v:true})<CR>', opts) ]]
--[[ else ]]
--[[ 	keymap("", "gx", '<Cmd>lua print("Error: gx is not supported on this OS!")<CR>', opts) ]]
--[[ end ]]
-- Terminal --
-- Better terminal navigation
-- keymap("t", "<C-h>", "<C-\\><C-N><C-w>h", term_opts)
-- keymap("t", "<C-j>", "<C-\\><C-N><C-w>j", term_opts)
-- keymap("t", "<C-k>", "<C-\\><C-N><C-w>k", term_opts)
-- keymap("t", "<C-l>", "<C-\\><C-N><C-w>l", term_opts)
keymap("v", "<leader>l", ":ToggleTermSendVisualLines<cr>", opts)
keymap("v", "<leader>s", ":ToggleTermSendVisualSelection<cr>", opts)

-- refactoring
keymap("v", "<leader>a", "<Esc><cmd>lua require('telescope').extensions.refactoring.refactors()<CR>", opts)

-- Hop
keymap("v", "<leader>mb", ":HopChar2<cr>", opts)
keymap("v", "<leader>mc", ":HopChar1<cr>", opts)
keymap("v", "<leader>ml", ":HopLine<cr>", opts)
keymap("v", "<leader>mw", ":HopWord<cr>", opts)

-- Dap plugin
-- keymap("v", "<leader>d", ':lua require("dapui").eval()', opts)

-- spectre
keymap("v", "<leader>S", "<cmd>lua require('spectre').open_visual()<CR>", opts)

-- crate
keymap("v", "<leader><leader>lru", ":lua require('crates').update_crates()<cr>", opts)
keymap("v", "<leader><leader>lru", ":lua require('crates').upgrade_crates()<cr>", opts)

-- Copilot
vim.cmd([[imap <silent><script><expr> <C-J> copilot#Accept("\<CR>")]])
