local status_ok, which_key = pcall(require, "which-key")
if not status_ok then
	return
end

local setup = {
	plugins = {
		marks = true, -- shows a list of your marks on ' and `
		registers = true, -- shows your registers on " in NORMAL or <C-r> in INSERT mode
		spelling = {
			enabled = true, -- enabling this will show WhichKey when pressing z= to select spelling suggestions
			suggestions = 20, -- how many suggestions should be shown in the list?
		},
		-- the presets plugin, adds help for a bunch of default keybindings in Neovim
		-- No actual key bindings are created
		presets = {
			operators = false, -- adds help for operators like d, y, ... and registers them for motion / text object completion
			motions = true, -- adds help for motions
			text_objects = true, -- help for text objects triggered after entering an operator
			windows = true, -- default bindings on <c-w>
			nav = true, -- misc bindings to work with windows
			z = true, -- bindings for folds, spelling and others prefixed with z
			g = true, -- bindings for prefixed with g
		},
	},
	-- add operators that will trigger motion and text object completion
	-- to enable all native operators, set the preset / operators plugin above
	-- operators = { gc = "Comments" },
	key_labels = {
		-- override the label used to display some keys. It doesn't effect WK in any other way.
		-- For example:
		-- ["<space>"] = "SPC",
		-- ["<cr>"] = "RET",
		-- ["<tab>"] = "TAB",
	},
	icons = {
		breadcrumb = "»", -- symbol used in the command line area that shows your active key combo
		separator = "➜", -- symbol used between a key and it's label
		group = "+", -- symbol prepended to a group
	},
	popup_mappings = {
		scroll_down = "<c-d>", -- binding to scroll down inside the popup
		scroll_up = "<c-u>", -- binding to scroll up inside the popup
	},
	window = {
		border = "rounded", -- none, single, double, shadow
		position = "bottom", -- bottom, top
		margin = { 1, 0, 1, 0 }, -- extra window margin [top, right, bottom, left]
		padding = { 2, 2, 2, 2 }, -- extra window padding [top, right, bottom, left]
		winblend = 0,
	},
	layout = {
		height = { min = 4, max = 25 }, -- min and max height of the columns
		width = { min = 20, max = 50 }, -- min and max width of the columns
		spacing = 3, -- spacing between columns
		align = "left", -- align columns left, center or right
	},
	ignore_missing = true, -- enable this to hide mappings for which you didn't specify a label
	hidden = { "<silent>", "<cmd>", "<Cmd>", "<CR>", "call", "lua", "^:", "^ " }, -- hide mapping boilerplate
	show_help = true, -- show help message on the command line when the popup is visible
	triggers = "auto", -- automatically setup triggers
	-- triggers = {"<leader>"} -- or specify a list manually
	triggers_blacklist = {
		-- list of mode / prefixes that should never be hooked by WhichKey
		-- this is mostly relevant for key maps that start with a native binding
		-- most people should not need to change this
		i = { "j", "k" },
		v = { "j", "k" },
	},
}

local term_id_max = 9

local function term_id_cmds(name, cmd_str)
	local t = {}
	t["name"] = name
	for i = 1, term_id_max, 1 do
		local k = tostring(i)
		local s = string.format("<cmd>%s %d<cr>", cmd_str, i)
		local n = string.format("Term %d", i)
		t[k] = { s, n }
	end
	return t
end

local function term_multi_hv(name, size, direction)
	local t = {}
	t["name"] = name
	for i = 1, term_id_max, 1 do
		local k = tostring(i)
		local s = string.format("<cmd>%dToggleTerm size=%d direction=%s<cr>", i, size, direction)
		local n = string.format("Term %d", i)
		t[k] = { s, n }
	end
	return t
end

local n_opts = {
	mode = "n", -- NORMAL mode
	prefix = "",
	buffer = nil, -- Global mappings. Specify a buffer number for buffer local mappings
	silent = true, -- use `silent` when creating keymaps
	noremap = true, -- use `noremap` when creating keymaps
	nowait = true, -- use `nowait` when creating keymaps
}

local n_mappings = {
	["<leader>"] = {
		["a"] = { "<cmd>Alpha<cr>", "Alpha" },
		["A"] = { "<cmd>ASToggle<cr>", "Autosave" },
		["b"] = {
			"<cmd>lua require('telescope.builtin').buffers(require('telescope.themes').get_dropdown{previewer = false})<cr>",
			"Buffers",
		},
		["B"] = {
			name = "BufferLine",
			d = { "<cmd>BufferLineSortByDirectory<cr>", "Sort By Dir" },
		},
		["c"] = { "<cmd>Bdelete!<CR>", "Close Buffer" },
		["f"] = {
			"<cmd>lua require('telescope.builtin').find_files(require('telescope.themes').get_dropdown{previewer = false})<cr>",
			"Find files",
		},
		["F"] = { "<cmd>Telescope live_grep theme=ivy<cr>", "Find Text" },
		["g"] = {
			name = "Git",
			b = { "<cmd>Telescope git_branches<cr>", "Checkout Branch" },
			c = { "<cmd>Telescope git_commits<cr>", "Checkout Commit" },
			d = {
				"<cmd>Gitsigns diffthis HEAD<cr>",
				"Diff",
			},
			h = { "<cmd>Gitsigns select_hunk<CR>", "Select Hunk" },
			j = { "<cmd>lua require 'gitsigns'.next_hunk()<cr>", "Next Hunk" },
			k = { "<cmd>lua require 'gitsigns'.prev_hunk()<cr>", "Prev Hunk" },
			l = { "<cmd>lua require 'gitsigns'.blame_line()<cr>", "Blame" },
			o = { "<cmd>Telescope git_status<cr>", "Open Changed File" },
			p = { "<cmd>lua require 'gitsigns'.preview_hunk()<cr>", "Preview Hunk" },
			r = { "<cmd>lua require 'gitsigns'.reset_hunk()<cr>", "Reset Hunk" },
			R = { "<cmd>lua require 'gitsigns'.reset_buffer()<cr>", "Reset Buffer" },
			s = { "<cmd>lua require 'gitsigns'.stage_hunk()<cr>", "Stage Hunk" },
			u = {
				"<cmd>lua require 'gitsigns'.undo_stage_hunk()<cr>",
				"Undo Stage Hunk",
			},
		},
		["h"] = { "<cmd>nohlsearch<CR>", "No Highlight Search" },
		["l"] = {
			a = { "<cmd>lua vim.lsp.buf.code_action()<cr>", "Code Action" },
			c = {
				"<cmd>Telescope lsp_document_diagnostics<cr>",
				"Document Diagnostics",
			},
			d = { "<cmd>lua vim.lsp.buf.definition()<CR>", "Definition" },
			D = { "<cmd>lua vim.lsp.buf.declaration()<CR>", "Declaration" },
			K = { "<cmd>lua vim.lsp.buf.hover()<CR>", "Hover" },
			h = { "<cmd>lua vim.lsp.buf.signature_help()<CR>", "Sig Help" },
			H = { "<cmd>LspInfo<cr>", "Info" },
			i = { "<cmd>lua vim.lsp.buf.implementation()<cr>", "Implementation" },
			I = { "<cmd>LspInstallInfo<cr>", "Installer Info" },
			l = { '<cmd>lua vim.diagnostic.open_float({ border = "rounded" })<CR>', "Diagnostics" },
			L = { "<cmd>lua vim.lsp.codelens.run()<cr>", "CodeLens Action" },
			n = {
				"<cmd>lua vim.lsp.diagnostic.goto_next()<CR>",
				"Next Diagnostic",
			},
			N = { "<cmd>NullLsInfo", "Null-Ls Info" },
			p = {
				"<cmd>lua vim.lsp.diagnostic.goto_prev()<cr>",
				"Prev Diagnostic",
			},
			q = { "<cmd>lua vim.lsp.diagnostic.setloclist()<cr>", "Diagnostic List" },
			r = { "<cmd>lua vim.lsp.buf.references()<CR>", "References" },
			R = { "<cmd>lua vim.lsp.buf.rename()<cr>", "Rename" },
			s = { "<cmd>Telescope lsp_document_symbols<cr>", "Document Symbols" },
			S = {
				"<cmd>Telescope lsp_dynamic_workspace_symbols<cr>",
				"Workspace Symbols",
			},
			w = {
				"<cmd>Telescope lsp_workspace_diagnostics<cr>",
				"Workspace Diagnostics",
			},
		},
		["n"] = { "<cmd>NvimTreeToggle<cr>", "Explorer" },
		["P"] = { "<cmd>lua require('telescope').extensions.projects.projects()<cr>", "Projects" },
		["r"] = {
			name = "SnipRun",
			c = { "<cmd>SnipClose", "Close" },
			i = { "<cmd>SnipInfo", "Info" },
			l = { "<cmd>SnipLive<cr>", "Live" },
			m = { "<cmd>SnipReplMemoryClean<cr>", "Memory Clean" },
			r = { "<cmd>SnipRun<cr>", "Run" },
			s = { "<cmd>SnipReset<cr>", "Stop" },
			o = { "<cmd>lua require'sniprun'.run('n')<cr>", "Run Operator" },
		},
		["s"] = {
			name = "Search",
			b = { "<cmd>Telescope git_branches<cr>", "Checkout branch" },
			c = { "<cmd>Telescope commands<cr>", "Commands" },
			C = { "<cmd>Telescope colorscheme<cr>", "Colorscheme" },
			h = { "<cmd>Telescope help_tags<cr>", "Find Help" },
			k = { "<cmd>Telescope keymaps<cr>", "Keymaps" },
			m = { "<cmd>Telescope man_pages<cr>", "Man Pages" },
			r = { "<cmd>Telescope oldfiles<cr>", "Open Recent File" },
			R = { "<cmd>Telescope registers<cr>", "Registers" },
		},
		["S"] = {
			name = "Session",
			c = { "<cmd>SessionManager load_current_dir_session", "Load Current Dirtectory" },
			d = { "<cmd>SessionManager delete_session", "Delete Session" },
			l = { "<cmd>SessionManager load_last_session", "Last Saved Session" },
			s = { "<cmd>SessionManager load_session<cr>", "Load Session" },
			w = { "<cmd>SessionManager save_current_session", "Save Current Dirtectory" },
		},
		["t"] = {
			name = "Terminal",
			a = { "<cmd>ToggleTermToggleAll<cr>", "All" },
			c = { "<cmd>ToggleTermSendCurrentLine<cr>", "Send Line" },
			C = term_id_cmds("Send Line", "ToggleTermSendCurrentLine"),
			g = { "<cmd>lua _LAZYGIT_TOGGLE()<cr>", "Lazygit" },
			p = { "<cmd>lua _PYTHON3_TOGGLE()<cr>", "Python3" },
			f = { "<cmd>ToggleTerm direction=float<cr>", "Float" },
			h = { "<cmd>ToggleTerm size=15 direction=horizontal<cr>", "Horizontal" },
			H = term_multi_hv("Multi-Horizontal", 15, "horizontal"),
			v = { "<cmd>ToggleTerm size=80 direction=vertical<cr>", "Vertical" },
			V = term_multi_hv("Multi-Vertical", vim.o.columns * 0.4, "vertical"),
			w = { "<cmd>ToggleTerm direction=window<cr>", "Window" },
		},
		["T"] = {
			name = "Tab",
			c = { "<cmd>tabclose<cr>", "Close" },
			n = { "<cmd>tabnew %<cr>", "New" },
		},
		["u"] = { "<cmd>UndotreeToggle<cr>", "Undotree" },
		["w"] = { "<cmd>w<cr>", "Save" },
		["W"] = { "<cmd>w !sudo -S tee %<CR>", "Force Save(Linux Only)" },
		["z"] = {
			name = "Unachieved",
			a = {},
		},
		["="] = { "<cmd>lua vim.lsp.buf.formatting()<cr>", "Format" },
		["<leader>"] = {
			c = {
				name = "Colorizer",
				a = { "<cmd>ColorizerAttachToBuffer<cr>", "Attach" },
				d = { "<cmd>ColorizerDetachFromBuffer<cr>", "Detach" },
				r = { "<cmd>ColorizerReloadAllBuffers<cr>", "Reload" },
				t = { "<cmd>ColorizerToggle<cr>", "Toggle" },
			},
			p = {
				name = "Packer",
				c = { "<cmd>PackerCompile<cr>", "Compile" },
				i = { "<cmd>PackerInstall<cr>", "Install" },
				s = { "<cmd>PackerSync<cr>", "Sync" },
				S = { "<cmd>PackerStatus<cr>", "Status" },
				u = { "<cmd>PackerUpdate<cr>", "Update" },
			},
			s = { "<cmd>StartupTime<cr>", "Startup Time" },
		},
	},
}

which_key.setup(setup)
which_key.register(n_mappings, n_opts)

local v_opts = {
	mode = "v", -- VISUAL mode
	-- prefix: use "<leader>f" for example for mapping everything related to finding files
	-- the prefix is prepended to every mapping part of `mappings`
	prefix = "",
	buffer = nil, -- Global mappings. Specify a buffer number for buffer local mappings
	silent = true, -- use `silent` when creating keymaps
	noremap = true, -- use `noremap` when creating keymaps
	nowait = false, -- use `nowait` when creating keymaps
}

local v_mappings = {
	["<leader>"] = {
		l = { "<cmd>ToggleTermSendVisualLines<cr>", "Send Line" },
		L = term_id_cmds("Send Line", "ToggleTermSendVisualLines"),
		r = { "<cmd>SnipRun<cr>", "Run Snip" },
		s = { "<cmd>ToggleTermSendVisualSelection<cr>", "Send Selection" },
		S = term_id_cmds("Send Selection", "ToggleTermSendVisualSelection"),
	},
}

which_key.register(v_mappings, v_opts)
