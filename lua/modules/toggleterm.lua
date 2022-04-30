local status_ok, toggleterm = pcall(require, "toggleterm")
if not status_ok then
	return
end

-- float config
local float_cfg = {
	size = 20,
	open_mapping = [[<c-\>]],
	hide_numbers = true,
	shade_filetypes = {},
	shade_terminals = true,
	shading_factor = 2,
	start_in_insert = true,
	insert_mappings = true,
	persist_size = true,
	direction = "float",
	close_on_exit = true,
	shell = vim.o.shell,
	float_opts = {
		border = "curved",
		winblend = 0,
		highlights = {
			border = "Normal",
			background = "Normal",
		},
	},
}

toggleterm.setup(float_cfg)

function _G.set_terminal_keymaps()
	local opts = { noremap = true }
	-- vim.api.nvim_buf_set_keymap(0, "t", "<esc>", [[<C-\><C-n>]], opts)
	vim.api.nvim_buf_set_keymap(0, "t", "jk", [[<C-\><C-n>]], opts)
	vim.api.nvim_buf_set_keymap(0, "t", "<C-h>", [[<C-\><C-n><C-W>h]], opts)
	vim.api.nvim_buf_set_keymap(0, "t", "<C-j>", [[<C-\><C-n><C-W>j]], opts)
	vim.api.nvim_buf_set_keymap(0, "t", "<C-k>", [[<C-\><C-n><C-W>k]], opts)
	vim.api.nvim_buf_set_keymap(0, "t", "<C-l>", [[<C-\><C-n><C-W>l]], opts)
end

vim.cmd("autocmd! TermOpen term://* lua set_terminal_keymaps()")

-- Create custom terminals
local Terminal = require("toggleterm.terminal").Terminal

-- Setup nvim as default editor for lazygit
local lazygit = Terminal:new({
	cmd = [[VISUAL="nvim" EDITOR="nvim" lazygit]],
	hidden = true,
})
function _G._LAZYGIT_TOGGLE()
	lazygit:toggle()
end

local python3 = Terminal:new({ cmd = "python3", hidden = true })
function _G._PYTHON3_TOGGLE()
	python3:toggle()
end

local dlv_debug = Terminal:new({ cmd = "dlv debug", hidden = true })
function _G._DLV_DEBUG_TOGGLE()
	dlv_debug:toggle()
end
