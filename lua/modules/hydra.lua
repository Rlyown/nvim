local Hydra = require("hydra")

-- NOTE: body need to hit toghter
local dap_hydra = Hydra({
	name = "DAP",
	mode = "n",
	body = "<leader>d",
	config = {
		invoke_on_body = false,
		color = "pink",
		timeout = false,
		--[[ on_enter = function() ]]
		--[[ 	vim.bo.modifiable = false ]]
		--[[ end, ]]
		hint = {
			position = "middle-right",
			border = "rounded",
		},
	},
	hint = [[
 _b_: Breakpoint      _f_: Step out         _o_: Repl        _w_: CondBreakpoint
 _c_: Continue        _g_: Get Session      _p_: Pause       _x_: Dapui         
 _C_: Run to Cursor   _y_: CountBreakpint   _q_: Close                          
 _d_: Disconnect      _v_: LogBreakpoint    _R_: Rerun                          
 _e_: ExpBreakpoint   _n_: Step over        _s_: Step into                      
 ^
 ^ ^              ^ ^                                   ^ ^            _<Esc>_
]],
	heads = {
		{ "b", "<cmd>lua require'dap'.toggle_breakpoint()<CR>" },
		{ "c", "<cmd>lua require'dap'.continue()<CR>" },
		{ "C", "<cmd>lua require'dap'.run_to_cursor()<cr>" },
		{ "d", "<cmd>lua require'dap'.disconnect()<cr>", { exit = true } },
		{
			"e",
			"<cmd>lua require'dap'.set_exception_breakpoints('default', { breakMode = 'userUnhandled' })<cr>",
		},
		{ "f", "<cmd>lua require'dap'.step_out()<CR>" },
		{ "g", "<cmd>lua require'dap'.session()<cr>" },
		{ "n", "<cmd>lua require'dap'.step_over()<CR>" },
		{ "o", "<cmd>lua require'dap'.repl.toggle()<CR>" },
		{ "p", "<cmd>lua require'dap'.pause.toggle()<cr>" },
		{ "q", "<cmd>lua require'dap'.close()<cr>", { exit = true } },
		{ "R", "<cmd>lua require'dap'.run_last()<CR>" },
		{ "s", "<cmd>lua require'dap'.step_into()<CR>" },
		{
			"v",
			"<cmd>lua require'dap'.set_breakpoint(nil, nil, vim.fn.input('Log point message: '))<CR>",
		},
		{
			"w",
			"<cmd>lua require'dap'.set_breakpoint(vim.fn.input('Breakpoint condition: '))<CR>",
		},
		{ "x", "<cmd>lua require('dapui').toggle()<cr>", { exit = true } },
		{
			"y",
			"<cmd>lua require'dap'.set_breakpoint(nil, vim.fn.input('Hit count: '))",
		},
		{ "<Esc>", nil, { exit = true } },
	},
})

local resize_hydra = Hydra({
	name = "Resize Window",
	mode = { "n" },
	body = "<C-w>",
	config = {
		-- color = "pink",
		hint = {
			border = "rounded",
		},
	},
	heads = {
		-- move window
		{ "h", "<C-w>h", { desc = "Move Left" } },
		{ "j", "<C-w>j", { desc = "Move Down" } },
		{ "k", "<C-w>k", { desc = "Move Up" } },
		{ "l", "<C-w>l", { desc = "Move Right" } },

		-- resizing window
		{ "<", "<C-w><", { desc = "Decrease Weight" } },
		{ ">", "<C-w>>", { desc = "Increase Weight" } },
		{ "+", "<C-w>+", { desc = "Increase Height" } },
		{ "-", "<C-w>-", { desc = "Decrease Height" } },
		-- equalize window sizes
		{ "=", "<C-w>=", { desc = "Equalize" } },

		-- exit this Hydra
		{ "<Esc>", nil, { exit = true, nowait = true } },
	},
})

-- TODO: set hydra for gitsigns
local gitsigns = require("gitsigns")
local git_hydra = Hydra({
	name = "Git",
	hint = [[
 _J_: next hunk   _s_: stage hunk        _d_: show deleted   _b_: blame line
 _K_: prev hunk   _u_: undo stage hunk   _p_: preview hunk   _B_: blame show full 
 ^ ^              _S_: stage buffer      ^ ^                 _/_: show base file
 ^
 ^ ^  _c_: checkout branch    _C_: checkout commit    _o_: open changed file
 ^ ^              ^ ^                    ^ ^                 _<esc>_
]],
	config = {
		color = "pink",
		invoke_on_body = true,
		hint = {
			position = "bottom",
			border = "rounded",
		},
		-- on_enter = function()
		-- 	vim.bo.modifiable = false
		-- gitsigns.toggle_signs(true)
		-- gitsigns.toggle_linehl(true)
		-- end,
		-- on_exit = function()
		-- gitsigns.toggle_signs(false)
		-- gitsigns.toggle_linehl(false)
		-- gitsigns.toggle_deleted(false)
		-- end,
	},
	mode = { "n", "x" },
	body = "<leader>g",
	heads = {
		{
			"J",
			function()
				if vim.wo.diff then
					return "]c"
				end
				vim.schedule(function()
					gitsigns.next_hunk()
				end)
				return "<Ignore>"
			end,
			{ expr = true },
		},
		{
			"K",
			function()
				if vim.wo.diff then
					return "[c"
				end
				vim.schedule(function()
					gitsigns.prev_hunk()
				end)
				return "<Ignore>"
			end,
			{ expr = true },
		},
		{ "s", ":Gitsigns stage_hunk<CR>", { silent = true } },
		{ "u", gitsigns.undo_stage_hunk },
		{ "S", gitsigns.stage_buffer },
		{ "p", gitsigns.preview_hunk },
		{ "d", gitsigns.toggle_deleted, { nowait = true } },
		{ "b", gitsigns.blame_line },
		{
			"B",
			function()
				gitsigns.blame_line({ full = true })
			end,
		},
		{ "/", gitsigns.show, { exit = true } }, -- show the base of the file
		{ "c", "<cmd>Telescope git_branches<cr>", { exit = true } },
		{ "C", "<cmd>Telescope git_commits<cr>", { exit = true } },
		{ "o", "<cmd>Telescope git_status<cr>", { exit = true } },
		{ "<Enter>", _LAZYGIT_TOGGLE, { exit = true } },
		{ "<esc>", nil, { exit = true, nowait = true } },
	},
})

-- TODO: set hydra for [ and ] shortcut
-- local motion_hydra = Hydra({})

Hydra.spawn = function(head)
	if head == "dap-hydra" then
		dap_hydra:activate()
	elseif head == "git-hydra" then
		git_hydra:activate()
	end
end
