return function()
	local nvim_tree = require("nvim-tree")

	local nvim_tree_config = require("nvim-tree.config")

	-- vim.g.nvim_tree_respect_buf_cwd = 1

	local tree_cb = nvim_tree_config.nvim_tree_callback

	nvim_tree.setup({
		auto_reload_on_write = true,
		disable_netrw = true,
		hijack_netrw = true,
		open_on_tab = false,
		hijack_cursor = true,
		update_cwd = true,
		diagnostics = {
			enable = true,
			show_on_dirs = true,
			icons = {
				hint = "",
				info = "",
				warning = "",
				error = "",
			},
		},
		update_focused_file = {
			enable = true,
			update_cwd = false,
			ignore_list = {},
		},
		filesystem_watchers = {
			enable = true,
			debounce_delay = 100,
		},
		git = {
			enable = true,
			ignore = true,
			timeout = 500,
		},
		view = {
			width = 30,
			hide_root_folder = false,
			side = "left",
			preserve_window_proportions = false,
			mappings = {
				custom_only = false,
				list = {
					{ key = { "l", "<CR>", "o" }, cb = tree_cb("edit") },
					{ key = "h", cb = tree_cb("close_node") },
					{ key = "v", cb = tree_cb("vsplit") },
					{ key = "?", cb = tree_cb("toggle_help") },
					{ key = "d", cb = tree_cb("trash") },
					{ key = "D", cb = tree_cb("remove") },
					{ key = "+", cb = tree_cb("cd") },
					{ key = "M", action = "bulk_move" },
				},
			},
			number = false,
			relativenumber = false,
			float = {
				enable = false,
				open_win_config = {
					relative = "editor",
					border = "rounded",
					width = 30,
					height = 30,
					row = 1,
					col = 1,
				},
			},
		},
		renderer = {
			indent_markers = {
				enable = true,
				icons = {
					corner = "└",
					edge = "│",
					item = "├",
					none = " ",
				},
			},
			icons = {
				webdev_colors = true,
				glyphs = {
					-- following options are the default
					-- each of these are documented in `:help nvim-tree.OPTION_NAME`
					default = "",
					symlink = "",
					git = {
						unstaged = "",
						staged = "S",
						unmerged = "",
						renamed = "➜",
						deleted = "",
						untracked = "U",
						ignored = "◌",
					},
					folder = {
						default = "",
						open = "",
						empty = "",
						empty_open = "",
						symlink = "",
					},
				},
			},
		},
		trash = {
			cmd = "trash",
			require_confirm = true,
		},
		actions = {
			use_system_clipboard = true,
			change_dir = {
				enable = true,
				global = false,
				restrict_above_cwd = false,
			},
			open_file = {
				quit_on_open = false,
				resize_window = false,
				window_picker = {
					enable = true,
					chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890",
					exclude = {
						filetype = { "notify", "packer", "qf", "diff", "fugitive", "fugitiveblame" },
						buftype = { "nofile", "terminal", "help" },
					},
				},
			},
		},
		log = {
			enable = false,
			truncate = false,
			types = {
				all = false,
				config = false,
				copy_paste = false,
				diagnostics = false,
				git = false,
				profile = false,
			},
		},
	})
end
