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
		on_enter = function()
			vim.bo.modifiable = false
		end,
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

Hydra.spawn = function(head)
	if head == "dap-hydra" then
		dap_hydra:activate()
	end
end
