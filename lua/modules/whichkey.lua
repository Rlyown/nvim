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
	local prompt = string.format("Input Terminal ID(1 - %d, default 1): ", term_id_max)

	local do_func = function()
		local id = tonumber(vim.fn.input(prompt))
		if not id then
			id = 1
		end

		if id and 1 <= id and id <= term_id_max then
			local s = string.format("%s %d", cmd_str, id)
			vim.cmd(s)
		end
	end

	return { do_func, name }
end

local function term_multi_hv(name, rate, direction)
	local prompt = string.format("Input Terminal ID(1 - %d, default 1): ", term_id_max)

	local do_func = function()
		local id = tonumber(vim.fn.input(prompt))
		if not id then
			id = 1
		end

		local size = 20

		if direction == "vertical" then
			size = vim.o.columns * rate
		elseif direction == "horizontal" then
			size = vim.o.lines * rate
		end

		if id and 1 <= id and id <= term_id_max then
			local s = string.format("%dToggleTerm size=%d direction=%s", id, size, direction)
			vim.cmd(s)
		end
	end

	return { do_func, name }
end

-- bufdelete.nvim plugin cannot kill terminal by Bdelete command
local function close_buffer()
	local toggleterm_pattern = "^term://.*#toggleterm#%d+"
	if string.find(vim.fn.bufname(), toggleterm_pattern) then
		vim.cmd("bdelete!")
	else
		vim.cmd("Bdelete!")
	end
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
		["c"] = { close_buffer, "Close Buffer" },
		["e"] = { "<cmd>SudaRead<cr>", "Sudo Reopen" },
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
		["G"] = {
			name = "Golang",
			a = { "<cmd>GoAlternate<cr>", "Alternate" },
			b = { "<cmd>GoBuild<cr>", "Build" },
			B = { "<cmd>GoCoverageBrowser<cr>", "Coverage Browser" },
			c = { "<cmd>GoTestCompile<cr>", "Compile Test" },
			C = { "<cmd>GoCoverageToggle<cr>", "Coverage" },
			D = { "<cmd>GoDeps<cr>", "Dependence" },
			f = { "<cmd>GoTestFunc<cr>", "Function Test" },
			F = { "<cmd>GoFiles<cr>", "Files" },
			I = { "<cmd>GoInstallBinaries<cr>", "Install Binaries" },
			r = { "<cmd>GoRun<cr>", "Run" },
			R = {
				function()
					local s = vim.fn.input("Input GoRemoveTags Optional Args: ")
					vim.cmd(string.format("GoRemoveTags %s", s))
				end,
				"Remove Tags",
			},
			t = { "<cmd>GoTest<cr>", "Test" },
			T = {
				function()
					local s = vim.fn.input("Input GoAddTags Optional Args: ")
					vim.cmd(string.format("GoAddTags %s", s))
				end,
				"Add Tags",
			},
			U = { "<cmd>GoUpdateBinaries<cr>", "Update Binaries" },
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
			N = { "<cmd>NullLsInfo<cr>", "Null-Ls Info" },
			p = {
				"<cmd>lua vim.lsp.diagnostic.goto_prev()<cr>",
				"Prev Diagnostic",
			},
			q = { "<cmd>lua vim.diagnostic.setloclist()<cr>", "Diagnostic List" },
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
		["m"] = { "<cmd>MarkdownPreviewToggle<cr>", "Markdown Preview" },
		["n"] = { "<cmd>NvimTreeToggle<cr>", "Explorer" },
		["o"] = {
			name = "Open(MacOS Only)",
			m = {
				function()
					vim.cmd(string.format('silent exec "!open -a /Applications/Typora.app %s"', vim.fn.expand("%:p")))
				end,
				"Typora",
			},
		},
		["O"] = { "<cmd>AerialToggle right<cr>", "Code OutLine" },
		["P"] = { "<cmd>lua require('telescope').extensions.projects.projects()<cr>", "Projects" },
		["q"] = { "<cmd>q<cr>", "Quit" },
		["Q"] = { "<cmd>qa<cr>", "Quit All" },
		["r"] = {
			name = "SnipRun",
			c = { "<cmd>SnipClose<cr>", "Close" },
			i = { "<cmd>SnipInfo<cr>", "Info" },
			l = { "<cmd>SnipLive<cr>", "Live" },
			m = { "<cmd>SnipReplMemoryClean<cr>", "Memory Clean" },
			r = { "<cmd>SnipRun<cr>", "Run" },
			s = { "<cmd>SnipReset<cr>", "Stop" },
			o = { "<cmd>lua require'sniprun'.run('n')<cr>", "Run Operator" },
		},
		["s"] = {
			name = "Search",
			b = { "<cmd>Telescope git_branches<cr>", "Checkout branch" },
			B = { "<cmd>Telescope file_browser<cr>", "File Browser" },
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
			c = { "<cmd>SessionManager load_current_dir_session<cr>", "Load Current Dirtectory" },
			d = { "<cmd>SessionManager delete_session<cr>", "Delete Session" },
			l = { "<cmd>SessionManager load_last_session<cr>", "Last Session" },
			s = { "<cmd>SessionManager load_session<cr>", "Select Session" },
			w = { "<cmd>SessionManager save_current_session<cr>", "Save Current Dirtectory" },
		},
		["t"] = {
			name = "Terminal",
			a = { "<cmd>ToggleTermToggleAll<cr>", "All" },
			c = term_id_cmds("Send Line", "ToggleTermSendCurrentLine"),
			f = { "<cmd>ToggleTerm direction=float<cr>", "Float" },
			h = term_multi_hv("Horizontal", 0.3, "horizontal"),
			q = { "<cmd>q<cr>", "Background" },
			Q = { "<cmd>q<cr>", "Finish" },
			s = {
				name = "Specific",
				c = { "<cmd>lua _CGDB_TOGGLE()<cr>", "CGDB" },
				d = { "<cmd>lua _DLV_DEBUG_TOGGLE()<cr>", "Delve" },
				g = { "<cmd>lua _GDB_TOGGLE()<cr>", "GDB" },
				l = { "<cmd>lua _LLDB_TOGGLE()<cr>", "LLDB" },
				G = { "<cmd>lua _LAZYGIT_TOGGLE()<cr>", "Lazygit" },
				p = { "<cmd>lua _PYTHON3_TOGGLE()<cr>", "Python3" },
			},
			t = { "<cmd>ToggleTerm direction=tab<cr>", "Tab" },
			v = term_multi_hv("Vertical", 0.4, "vertical"),
			w = { "<cmd>terminal<cr>", "Window" },
		},
		["T"] = {
			name = "Tab",
			c = { "<cmd>tabclose<cr>", "Close" },
			n = { "<cmd>tabnew %<cr>", "New" },
		},
		["u"] = { "<cmd>UndotreeToggle<cr>", "Undotree" },
		["w"] = { "<cmd>w<cr>", "Save" },
		["W"] = { "<cmd>SudaWrite<cr>", "Force Save" },
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
	["g"] = {
		a = "Code Action",
		c = {
			name = "Line Comment",
			A = "Line End",
			c = "Current Line",
			O = "Line Above ",
			o = "Line Below ",
		},
		b = {
			name = "Block Comment",
			c = "Current Line",
		},
		d = "Goto Definition",
		D = "Goto Declaration",
		j = "Move Text Down",
		i = "Goto Implementation",
		k = "Move Text Up",
		h = "Signature Help",
		l = "Show Diagnostic",
		q = "Diagnostic List",
		r = "References",
		S = "Split Line",
		J = "Join Block",
		t = "Next Tab",
		T = "Prev Tab",
		w = { "<cmd>BufferLinePick<cr>", "Pick Buffer" },
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
		a = "Refactoring",
		c = "Line Comment",
		b = "Block Comment",
		l = "ToggleTermSendVisualLines",
		r = "SnipRun",
		s = "ToggleTermSendVisualSelection",
		G = {
			name = "Golang",
			c = "GoChannelPeers",
			R = "GoRemoveTags",
			T = "GoAddTags",
		},
	},
	["g"] = {
		u = "Lower",
		U = "Upper",
	},
}

which_key.register(v_mappings, v_opts)
