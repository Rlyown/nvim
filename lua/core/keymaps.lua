local opts = { noremap = true, silent = true }

-- local term_opts = { silent = true }

-- Shorten function name
local keymap = vim.api.nvim_set_keymap

--Remap comma as leader key
local leaderKey = ","
keymap("", leaderKey, "<Nop>", opts)
vim.g.mapleader = leaderKey
vim.g.maplocalleader = leaderKey

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
-- keymap("n", "<C-Up>", ":resize -2<CR>", opts)
-- keymap("n", "<C-Down>", ":resize +2<CR>", opts)
-- keymap("n", "<C-Left>", ":vertical resize -2<CR>", opts)
-- keymap("n", "<C-Right>", ":vertical resize +2<CR>", opts)

-- Navigate buffers
keymap("n", "<C-n>", ":bnext<CR>", opts)
keymap("n", "<C-p>", ":bprevious<CR>", opts)

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

-- plugins
keymap("v", "<leader>l", ":ToggleTermSendVisualLines<cr>", opts)
keymap("v", "<leader>r", ":SnipRun<cr>", opts)
keymap("v", "<leader>s", ":ToggleTermSendVisualSelection<cr>", opts)
keymap("v", "<leader>Gc", ":GoChannelPeers<cr>", opts)
keymap("v", "<leader>GR", ":GoRemoveTags<cr>", opts)
keymap("v", "<leader>GT", ":GoAddTags<cr>", opts)
keymap("v", "<leader>a", ":Telescope lsp_range_code_actions<cr>", opts)

-- Visual Block --
-- Move text up and down
keymap("x", "J", ":move '>+1<CR>gv-gv", opts)
keymap("x", "K", ":move '<-2<CR>gv-gv", opts)

-- Terminal --
-- Better terminal navigation
-- keymap("t", "<C-h>", "<C-\\><C-N><C-w>h", term_opts)
-- keymap("t", "<C-j>", "<C-\\><C-N><C-w>j", term_opts)
-- keymap("t", "<C-k>", "<C-\\><C-N><C-w>k", term_opts)
-- keymap("t", "<C-l>", "<C-\\><C-N><C-w>l", term_opts)

-- Hop plugins
local hop_status_ok, _ = pcall(require, "hop")
if hop_status_ok then
	-- place this in one of your configuration file(s)
	keymap(
		"n",
		"f",
		"<cmd>lua require'hop'.hint_char1({ direction = require'hop.hint'.HintDirection.AFTER_CURSOR })<cr>",
		opts
	)
	keymap(
		"n",
		"F",
		"<cmd>lua require'hop'.hint_char1({ direction = require'hop.hint'.HintDirection.BEFORE_CURSOR })<cr>",
		opts
	)
	keymap(
		"v",
		"f",
		"<cmd>lua require'hop'.hint_char1({ direction = require'hop.hint'.HintDirection.AFTER_CURSOR, inclusive_jump = true })<cr>",
		opts
	)
	keymap(
		"v",
		"F",
		"<cmd>lua require'hop'.hint_char1({ direction = require'hop.hint'.HintDirection.BEFORE_CURSOR, inclusive_jump = true })<cr>",
		opts
	)
	keymap(
		"",
		"t",
		"<cmd>lua require'hop'.hint_char1({ direction = require'hop.hint'.HintDirection.AFTER_CURSOR })<cr>",
		opts
	)
	keymap(
		"",
		"T",
		"<cmd>lua require'hop'.hint_char1({ direction = require'hop.hint'.HintDirection.BEFORE_CURSOR })<cr>",
		opts
	)
end

-- Dap plugins
-- keymap("v", "<leader>d", ':lua require("dapui").eval()', opts)
