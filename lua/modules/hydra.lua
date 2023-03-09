return function()
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
 _b_: breakpoint      _f_: step out         _o_: repl        _w_: condition bp
 _c_: run/continue    _g_: get session      _p_: pause       _x_: dapui         
 _C_: run to cursor   _y_: count bp         _v_: log bp      _R_: rerun
 _e_: exception bp    _n_: step over        _s_: step into                      
 ^
 ^ ^              ^ ^                       _q_: disconnect              _<Esc>_
]],
		heads = {
			{ "b", "<cmd>lua require'dap'.toggle_breakpoint()<CR>" },
			{ "c", "<cmd>lua require'dap'.continue()<CR>" },
			{ "C", "<cmd>lua require'dap'.run_to_cursor()<cr>" },
			{
				"e",
				"<cmd>lua require'dap'.set_exception_breakpoints('default', { breakMode = 'userUnhandled' })<cr>",
			},
			{ "f", "<cmd>lua require'dap'.step_out()<CR>" },
			{ "g", "<cmd>lua require'dap'.session()<cr>" },
			{ "n", "<cmd>lua require'dap'.step_over()<CR>" },
			{ "o", "<cmd>lua require'dap'.repl.toggle()<CR>" },
			{ "p", "<cmd>lua require'dap'.pause.toggle()<cr>" },
			{ "q", "<cmd>lua require'dap'.disconnect()<cr>", { exit = true } },
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
		body = "<leader>r",
		hint = [[
 _<_: desc weight   _-_: desc height   ___: max height   _o_: max both
 _>_: incr weight   _+_: incr height   _|_: max weight   _=_: equalize
 ^
 _h_: move left     _j_: move down     _k_: move up      _o_: move right
 ^
 ^ ^                ^ ^                ^ ^               _<esc>_
]],
		config = {
			-- color = "pink",
			hint = {
				border = "rounded",
				position = "bottom",
			},
		},
		heads = {
			-- move window
			{ "h", "<C-w>h" },
			{ "j", "<C-w>j" },
			{ "k", "<C-w>k" },
			{ "l", "<C-w>l" },

			-- resizing window
			{ "<", "30<C-w><" },
			{ ">", "30<C-w>>" },
			{ "+", "10<C-w>+" },
			{ "-", "10<C-w>-" },
			{ "_", "<C-w>_" },
			{ "|", "<C-w>|" },
			{ "o", "<C-w>|<C-w>_" },
			{ "=", "<C-w>=" },

			-- exit this Hydra
			{ "<Esc>", nil, { exit = true, nowait = true } },
		},
	})

	local gitsigns = require("gitsigns")
	local git_hydra = Hydra({
		name = "Git",
		hint = [[
 _J_: next hunk   _s_: stage hunk        _d_: show deleted   _b_: blame line
 _K_: prev hunk   _u_: undo stage hunk   _p_: preview hunk   _B_: blame show full 
 ^ ^              _S_: stage buffer      ^ ^                 _/_: show base file
 ^
 ^ ^  _c_: checkout branch    _C_: checkout commit    _o_: open changed file
 ^
 _<Enter>_: lazygit    _n_: neogit       _D_: diffview       _<esc>_
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
			{ "c", "<cmd>lua require('telescope.builtin').git_branches()<cr>", { exit = true } },
			{ "C", "<cmd>lua require('telescope.builtin').git_commits()<cr>", { exit = true } },
			{ "o", "<cmd>lua require('telescope.builtin').git_status()<cr>", { exit = true } },
			{ "<Enter>", "<cmd>lua _LAZYGIT_TOGGLE()<cr>", { exit = true } },
			{ "n", "<cmd>Neogit<cr>", { exit = true } },
			{ "D", "<cmd>DiffviewOpen<cr>", { exit = true } },
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
		elseif head == "resize-hydra" then
			resize_hydra:activate()
		end
	end
end
