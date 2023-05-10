return function()
	local which_key = require("which-key")
	local os = require("core.gvariable").os
	local helper = require("modules.which-key-helper")

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
			["<leader>"] = "LDR",
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
		disable = {
			buftypes = {},
			filetypes = { "TelescopePrompt", "spectre_panel" },
		},
	}
	which_key.setup(setup)

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
			["b"] = {
				"<cmd>lua require('telescope.builtin').buffers(require('telescope.themes').get_dropdown{previewer = false})<cr>",
				"Buffers",
			},
			["B"] = {
				name = "BufferLine",
				c = { "<cmd>BufferLineGroupClose<cr>", "Close Group Buffers" },
				d = { "<cmd>BufferLineSortByDirectory<cr>", "Sort By Directory" },
				e = { "<cmd>BufferLineSortByExtension<cr>", "Sort By Extensions" },
				p = { "<cmd>BufferLineTogglePin<cr>", "Pin" },
				t = { "<cmd>BufferLineGroupToggle<cr>", "Group Toggle" },
				T = { "<cmd>BufferLineSortByTabs<cr>", "Sort by Tabs" },
			},
			["c"] = { helper.close_buffer, "Close Buffer" },
			["C"] = { "<cmd>lua require('telescope').extensions.cder.cder()<cr>", "Change Work Directory" },
			["d"] = {
				"<cmd>lua require('hydra').spawn('dap-hydra')<cr>",
				"Debug",
			},
			["e"] = { "<cmd>edit<cr>", "Reopen" },
			["E"] = { "<cmd>SudaRead<cr>", "Sudo Reopen" },
			["f"] = {
				"<cmd>lua require('telescope.builtin').find_files(require('telescope.themes').get_dropdown{previewer = false})<cr>",
				"Find files",
			},
			["F"] = { "<cmd>lua require('telescope.builtin').live_grep()<cr>", "Find Text" },
			["g"] = {
				"<cmd>lua require('hydra').spawn('git-hydra')<cr>",
				"Git",
			},
			["h"] = { "<cmd>nohlsearch<CR>", "No Highlight Search" },
			["l"] = {
				a = {
					function()
						vim.b.copilot_enabled = true
						vim.notify("Copilot is enabled", "info", { title = "Copilot" })
					end,
					"Force Enable Copilot",
				},
				f = { "<cmd>lua vim.lsp.buf.format({ async=false })<cr>", "Format" },
				F = {
					function()
						if vim.g.custom_enable_auto_format then
							vim.g.custom_enable_auto_format = false
							vim.notify("File autoformat is disabled", "info", { title = "LSP Autoformat" })
						else
							vim.g.custom_enable_auto_format = true
							vim.notify("File autoformat is enabled", "info", { title = "LSP Autoformat" })
						end
					end,
					"Auto Format Toggle",
				},
				K = { "<cmd>lua vim.lsp.buf.hover()<CR>", "Hover" },
				H = { "<cmd>LspInfo<cr>", "Info" },
				I = { "<cmd>Mason<cr>", "Mason Info" },
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
				q = { "<cmd>lua require('telescope.builtin').diagnostics()<cr>", "Diagnostic" },
				R = { "<cmd>lua vim.lsp.buf.rename()<cr>", "Rename" },
				s = { "<cmd>lua require('telescope.builtin').lsp_document_symbols()<cr>", "Document Symbols" },
				S = {
					"<cmd>lua require('telescope.builtin').lsp_dynamic_workspace_symbols()<cr>",
					"Workspace Symbols",
				},
			},
			["L"] = {
				name = "Language Specific",
				c = {
					name = "C/CPP",
					t = { "<cmd>edit .clang-tidy<cr>", "Gen Clang Tidy" },
					f = { "<cmd>edit .clang-format<cr>", "Gen Clang Format" },
				},
				g = {
					name = "Golang",
					a = { "<cmd>GoCodeAction<cr>", "Code action" },
					e = { "<cmd>GoIfErr<cr>", "Add if err" },
					h = {
						name = "Helper",
						a = { "<cmd>GoAddTag<cr>", "Add tags to struct" },
						r = { "<cmd>GoRMTag<cr>", "Remove tags to struct" },
						c = { "<cmd>GoCoverage<cr>", "Test coverage" },
						g = { "<cmd>lua require('go.comment').gen()<cr>", "Generate comment" },
						v = { "<cmd>GoVet<cr>", "Go vet" },
						t = { "<cmd>GoModTidy<cr>", "Go mod tidy" },
						i = { "<cmd>GoModInit<cr>", "Go mod init" },
					},
					i = { "<cmd>GoToggleInlay<cr>", "Toggle inlay" },
					l = { "<cmd>GoLint<cr>", "Run linter" },
					o = { "<cmd>GoPkgOutline<cr>", "Outline" },
					r = { "<cmd>GoRun<cr>", "Run" },
					s = { "<cmd>GoFillStruct<cr>", "Autofill struct" },
					t = {
						name = "Tests",
						r = { "<cmd>GoTest<cr>", "Run tests" },
						a = { "<cmd>GoAlt!<cr>", "Open alt file" },
						s = { "<cmd>GoAltS!<cr>", "Open alt file in split" },
						v = { "<cmd>GoAltV!<cr>", "Open alt file in vertical split" },
						u = { "<cmd>GoTestFunc<cr>", "Run test for current func" },
						f = { "<cmd>GoTestFile<cr>", "Run test for current file" },
					},
					x = {
						name = "Code Lens",
						l = { "<cmd>GoCodeLenAct<cr>", "Toggle Lens" },
						a = { "<cmd>GoCodeAction<cr>", "Code Action" },
					},
				},
				p = {
					name = "Python",
					v = { "<cmd>VenvSelect<cr>", "VenvSelect" },
				},
				r = {
					name = "Rust Crate",
					d = { "<cmd>lua require('crates').open_documentation()<cr>", "Documentation" },
					f = { "<cmd>lua require('crates').show_features_popup()<cr>", "Features" },
					g = { "<cmd>lua require('crates').open_repository()<cr>", "Repository" },
					h = { "<cmd>lua require('crates').open_homepage()<cr>", "Homepage" },
					i = { "<cmd>lua require('crates').upgrade_crate()<cr>", "Upgrade" },
					I = { "<cmd>lua require('crates').upgrade_all_crates()<cr>", "Upgrade All" },
					o = { "<cmd>lua require('crates').toggle()<cr>", "Toggle" },
					p = { "<cmd>lua require('crates').open_crates_io()<cr>", "Creates.io" },
					r = { "<cmd>lua require('crates').reload()<cr>", "Reload" },
					u = { "<cmd>lua require('crates').update_crate()<cr>", "Update" },
					U = { "<cmd>lua require('crates').update_all_crates()<cr>", "Update All" },
					v = { "<cmd>lua require('crates').show_versions_popup()<cr>", "Versions" },
				},
				t = {
					name = "Latex",
					i = { "<plug>(vimtex-info)", "Info" },
					I = { "<plug>(vimtex-info-full)", "Info Full" },
					t = { "<plug>(vimtex-toc-open)", "Toc Open" },
					T = { "<plug>(vimtex-toc-toggle)", "Toc Toggle" },
					q = { "<plug>(vimtex-log)", "Log" },
					v = { "<plug>(vimtex-view)", "View" },
					r = { "<plug>(vimtex-reverse-search)", "Reverse Search" },
					l = { "<plug>(vimtex-compile)", "Compile" },
					k = { "<plug>(vimtex-stop)", "Stop" },
					K = { "<plug>(vimtex-stop-all)", "Stop All" },
					e = { "<plug>(vimtex-errors)", "Errors" },
					o = { "<plug>(vimtex-compile-output)", "Compile Output" },
					g = { "<plug>(vimtex-status)", "Status" },
					G = { "<plug>(vimtex-status-all)", "Status All" },
					c = { "<plug>(vimtex-clean)", "Clean" },
					C = { "<plug>(vimtex-clean-full)", "Clean Full" },
					m = { "<plug>(vimtex-imaps-list)", "Imaps List" },
					x = { "<plug>(vimtex-reload)", "Reload" },
					X = { "<plug>(vimtex-reload-state)", "Reload State" },
					s = { "<plug>(vimtex-toggle-main)", "Toggle Main" },
					a = { "<plug>(vimtex-context-menu)", "Context Menu" },
				},
			},
			["M"] = { helper.markdown_helper(), "Markdown Preview" },
			["m"] = {
				name = "Motion",
				b = { "<cmd>HopChar2<cr>", "2-Char" },
				c = { "<cmd>HopChar1<cr>", "Char" },
				l = { "<cmd>HopLine<cr>", "Line" },
				w = { "<cmd>HopWord<cr>", "Word" },
			},
			["N"] = {
				name = "Neorg",
				g = {
					name = "GTD",
					u = "Undone",
					p = "Pending",
					d = "Done",
					h = "On Hold",
					c = "Cancelled",
					r = "Recurring",
					i = "Important",
					n = "Cycling Task",
				},

				s = {
					name = "Search",
					c = helper.telescope_neorg_bind_helper("find_context_tasks", "Find Context Tasks"),
					h = helper.telescope_neorg_bind_helper("search_headings", "Find Heading"),
					l = helper.telescope_neorg_bind_helper("find_linkable", "Find Linkable"),
					p = helper.telescope_neorg_bind_helper("find_project_tasks", "Find Project Tasks"),
					P = helper.telescope_neorg_bind_helper("find_aof_project_tasks", "Find aof Project Tasks"),
					t = helper.telescope_neorg_bind_helper("find_aof_tasks", "Find Aof Tasks"),
				},
				w = helper.telescope_neorg_bind_helper("switch_workspace", "Switch Workspace"),
			},
			["n"] = { "<cmd>NvimTreeToggle<cr>", "Explorer" },
			["o"] = {
				name = "Open(MacOS Only)",
				m = {
					function()
						vim.cmd(
							string.format('silent exec "!open -a /Applications/Typora.app %s"', vim.fn.expand("%:p"))
						)
					end,
					"Typora",
				},
			},
			["O"] = { "<cmd>SymbolsOutline<cr>", "Code OutLine" },
			-- ["P"] = { "<cmd>lua require('telescope').extensions.projects.projects()<cr>", "Projects" },
			["p"] = {
				name = "Session",
				c = { "<cmd>SessionManager load_current_dir_session<cr>", "Load Current Dirtectory" },
				d = { "<cmd>SessionManager delete_session<cr>", "Delete Session" },
				l = { "<cmd>SessionManager load_last_session<cr>", "Last Session" },
				s = { "<cmd>SessionManager load_session<cr>", "Select Session" },
				w = { "<cmd>SessionManager save_current_session<cr>", "Save Current Dirtectory" },
			},
			["q"] = { "<cmd>q<cr>", "Close Window" },
			["Q"] = { "<cmd>qa<cr>", "Quit Nvim" },
			["r"] = {
				"<cmd>lua require('hydra').spawn('resize-hydra')<cr>",
				"Resize Window",
			},
			["R"] = {
				name = "SnipRun",
				c = { "<cmd>lua require’sniprun.display’.close_all()<cr>", "Clear" },
				r = { "<cmd>lua require’sniprun’.run()<cr>", "Run" },
				s = { "<cmd>lua require’sniprun’.reset()<cr>", "Stop" },
			},
			["s"] = {
				name = "Search",
				B = { "<cmd>lua require('telescope').extensions.file_browser.file_browser()<cr>", "File Browser" },
				c = { "<cmd>lua require('telescope.builtin').commands()<cr>", "Commands" },
				C = { "<cmd>lua require('telescope.builtin').colorscheme()<cr>", "Colorscheme" },
				d = {
					name = "DAP",
					b = { "<cmd>lua require('telescope').extensions.dap.list_breakpoints()<cr>", "Breakpoints" },
					c = { "<cmd>lua require('telescope').extensions.dap.commands()<cr>", "Commands" },
					C = { "<cmd>lua require('telescope').extensions.dap.configurations()<cr>", "Configurations" },
					f = { "<cmd>lua require('telescope').extensions.dap.frames()<cr>", "Frames" },
					v = { "<cmd>lua require('telescope').extensions.dap.variables()<cr>", "Variables" },
				},
				g = {
					name = "Git",
					b = { "<cmd>lua require('telescope.builtin').git_branches()<cr>", "Checkout branch" },
					c = { "<cmd>lua require('telescope.builtin').git_commits()<cr>", "Checkout Commit" },
					o = { "<cmd>lua require('telescope.builtin').git_status()<cr>", "Open Changed File" },
				},
				h = { "<cmd>lua require('telescope.builtin').help_tags()<cr>", "Find Help" },
				k = { "<cmd>lua require('telescope.builtin').keymaps()<cr>", "Keymaps" },
				m = { "<cmd>lua require('telescope.builtin').man_pages()<cr>", "Man Pages" },
				M = { "<cmd>Noice<cr>", "Messages" },
				n = {
					"<cmd>lua require('telescope').extensions.notify.notify(require('telescope.themes').get_dropdown({}))<cr>",
					"Notify",
				},
				r = { "<cmd>lua require('telescope.builtin').oldfiles()<cr>", "Open Recent File" },
				R = { "<cmd>lua require('telescope.builtin').registers()<cr>", "Registers" },
				s = { "<cmd>lua require('telescope').extensions.luasnip.luasnip()<cr>", "Luasnip" },
				t = { "<cmd>lua require('telescope.builtin').tags()<cr>", "Tags" },
				y = { "<cmd>lua require('telescope').extensions.neoclip.default()<cr>", "Yank History" },
				Y = { "<cmd>lua require('telescope').extensions.macroscope.default()<cr>", "Macroscope" },
			},
			["S"] = {
				name = "Search & Replace",
				o = { "<cmd>lua require('spectre').open()<CR>", "Open" },
				w = { "<cmd>lua require('spectre').open_visual({select_word=true})<CR>", "Search Word" },
				f = { "viw:lua require('spectre').open_file_search()<cr>", "Search in File" },
			},
			["t"] = {
				name = "Terminal",
				a = { "<cmd>ToggleTermToggleAll<cr>", "All" },
				c = helper.term_id_cmds("Send Line", "ToggleTermSendCurrentLine"),
				f = { "<cmd>ToggleTerm direction=float<cr>", "Float" },
				h = helper.term_multi_hv("Horizontal", 0.3, "horizontal"),
				q = { "<cmd>q<cr>", "Background" },
				Q = { "<cmd>q<cr>", "Finish" },
				s = {
					name = "Specific",
					d = { "<cmd>lua _DLV_DEBUG_TOGGLE()<cr>", "Delve" },
					g = {
						function()
							if filetype_check({ "c", "cpp", "rust" }) then
								local prog = vim.fn.input("Path to program: ", vim.fn.getcwd(), "file")
								vim.cmd(string.format("GdbStart gdb %s", prog))
							end
						end,
						"GDB",
					},
					G = { "<cmd>lua _LAZYGIT_TOGGLE()<cr>", "Lazygit" },
					l = {
						function()
							if helper.filetype_check({ "c", "cpp", "rust" }) then
								local prog = vim.fn.input("Path to program: ", vim.fn.getcwd(), "file")
								vim.cmd(string.format("GdbStartLLDB lldb %s", prog))
							end
						end,
						"LLDB",
					},
					p = { "<cmd>lua _PYTHON3_TOGGLE()<cr>", "Python3" },
					r = {
						function()
							if helper.filetype_check("rust") then
								local prog = vim.fn.input("Path to program: ", vim.fn.getcwd(), "file")
								vim.cmd(string.format("GdbStartLLDB rust-lldb %s", prog))
							end
						end,
						"Rust LLDB",
					},
					R = {
						function()
							if helper.filetype_check("rust") then
								local prog = vim.fn.input("Path to program: ", vim.fn.getcwd(), "file")
								vim.cmd(string.format("GdbStart rust-gdb %s", prog))
							end
						end,
						"Rust GDB",
					},
				},
				t = { "<cmd>ToggleTerm direction=tab<cr>", "Tab" },
				v = helper.term_multi_hv("Vertical", 0.4, "vertical"),
				w = { "<cmd>terminal<cr>", "Window" },
			},
			["T"] = {
				name = "Tab",
				c = { "<cmd>tabclose<cr>", "Close" },
				n = { "<cmd>tabnew %<cr>", "New" },
			},
			--[[ ["u"] = { "<cmd>UndotreeToggle<cr>", "Undotree" }, ]]
			["u"] = { "<cmd>lua require('telescope').extensions.undo.undo()<cr>", "Undotree" },
			["w"] = { "<cmd>w<cr>", "Save" },
			["W"] = { "<cmd>SudaWrite<cr>", "Force Save" },
			["x"] = {
				name = "Trouble",
				d = { "<cmd>TroubleToggle document_diagnostics<cr>", "Document Diagnostics" },
				l = { "<cmd>TroubleToggle loclist", "LocList" },
				q = { "<cmd>TroubleToggle quickfix<cr>", "Quickfix" },
				r = { "<cmd>TroubleToggle lsp_references<cr>", "References" },
				w = { "<cmd>TroubleToggle workspace_diagnostics<cr>", "Workspace Diagnostics" },
				x = { "<cmd>TroubleToggle<cr>", "Trouble" },
			},
			["<leader>"] = {
				name = "Ext",
				c = {
					name = "Colorizer",
					a = { "<cmd>ColorizerAttachToBuffer<cr>", "Attach" },
					d = { "<cmd>ColorizerDetachFromBuffer<cr>", "Detach" },
					r = { "<cmd>ColorizerReloadAllBuffers<cr>", "Reload" },
					t = { "<cmd>ColorizerToggle<cr>", "Toggle" },
				},
				m = { ":lua require('nabla').popup()<CR>", "Show Math Equation" },
				n = { "<cmd>lua require('notify').dismiss()<cr>", "Dismiss All Notifications" },
				p = {
					name = "Lazy",
					i = { "<cmd>Lazy install<cr>", "Install" },
					s = { "<cmd>Lazy sync<cr>", "Sync" },
					S = { "<cmd>Lazy health<cr>", "Status" },
					u = { "<cmd>Lazy update<cr>", "Update" },
					p = { "<cmd>Lazy profile<cr>", "Profile" },
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
			F = "Neorg Hop Link",
			j = "Move Text Down",
			i = "Goto Implementation",
			k = "Move Text Up",
			h = "Signature Help",
			l = "Show Diagnostic",
			q = "Diagnostic List",
			r = "References",
			R = "Rename",
			S = "Split Line",
			J = "Join Block",
			t = "Next Tab",
			T = "Prev Tab",
			w = { "<cmd>BufferLinePick<cr>", "Pick Buffer" },
		},
		["z"] = {
			d = "Delete Fold",
			D = "Recursion Delete Fold",
			E = "Eliminate All Folds",
			f = "Create Fold",
			F = "Create Fold Lines",
			j = "Next Fold Begin",
			k = "Prev Fold End",
			i = "Toggle Fold ",
			n = "Disable Fold ",
			N = "Enable Fold",
		},
		["["] = {
			d = "Prev Diagnostic",
			z = "Current Fold Begin",
		},
		["]"] = {
			d = "Next Diagnostic",
			z = "Current Fold End",
		},
	}

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
			b = "Block Comment",
			c = "Line Comment",
			d = "Dap Eval",
			l = "ToggleTermSendVisualLines",
			L = {
				name = "Language Specific",
				r = {
					name = "Rust Crate",
					u = "Update",
					i = "Upgrade",
				},
				t = {
					name = "Latex",
					L = { "<plug>(vimtex-compile-selected)", "Compile" },
				},
			},
			["m"] = {
				name = "Motion",
				b = "2-Char",
				c = "Char",
				l = "Line",
				w = "Word",
			},
			-- r = "SnipRun",
			s = "ToggleTermSendVisualSelection",
			S = "Search & Replace",
		},
		["g"] = {
			u = "Lower",
			U = "Upper",
		},
		["z"] = {
			f = "Create Fold",
		},
	}

	which_key.register(v_mappings, v_opts)
end
