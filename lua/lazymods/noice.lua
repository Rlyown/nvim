-- 
return function()
	require("noice").setup({
		cmdline = {
			enabled = true,
			view = "cmdline", -- view for rendering the cmdline. Change to `cmdline` to get a classic cmdline at the bottom
			opts = { buf_options = { filetype = "vim" } }, -- enable syntax highlighting in the cmdline
			icons = {
				["/"] = { icon = " ", hl_group = "DiagnosticWarn" },
				["?"] = { icon = " ", hl_group = "DiagnosticWarn" },
				[":"] = { icon = " ", hl_group = "DiagnosticInfo", firstc = false },
			},
		},
		popupmenu = {
			enabled = true, -- disable if you use something like cmp-cmdline
			---@type 'nui'|'cmp'
			backend = "nui", -- backend to use to show regular cmdline completions
			-- You can specify options for nui under `config.views.popupmenu`
		},
		history = {
			-- options for the message history that you get with `:Noice`
			view = "split",
			opts = { enter = true },
			filter = { event = "msg_show", ["not"] = { kind = { "search_count", "echo" } } },
		},
		notify = {
			-- Noice can be used as `vim.notify` so you can route any notification like other messages
			-- Notification messages have their level and other properties set.
			-- event is always "notify" and kind can be any log level as a string
			-- The default routes will forward notifications to nvim-notify
			enabled = false,
		},
		throttle = 1000 / 30, -- how frequently does Noice need to check for ui updates? This has no effect when in blocking mode.
		---@type table<string, NoiceViewOptions>
		views = {}, -- @see the section on views below
		---@type NoiceRouteConfig[]
		routes = {
			{
				view = "notify",
				filter = { event = "msg_showmode" },
			},
			{
				filter = {
					event = "msg_show",
					kind = "",
					find = "written",
				},
				opts = { skip = true },
			},
			{
				filter = {
					event = "msg_show",
					kind = "",
					find = "^<$",
				},
				opts = { skip = true },
			},
			{
				filter = {
					event = "msg_show",
					kind = "",
					find = "not a git repository",
				},
				opts = { skip = true },
			},
			{
				filter = {
					event = "cmdline",
					find = "^%s*[/?]",
				},
				view = "cmdline",
			},
			{
				filter = {
					event = "msg_show",
					kind = "confirm_sub",
				},
				view = "cmdline",
			},
		}, -- @see the section on routes below
		---@type table<string, NoiceFilter>
		status = {}, --@see the section on statusline components below
		hacks = {
			-- due to https://github.com/neovim/neovim/issues/20416
			-- messages are resent during a redraw. Noice detects this in most cases, but
			-- some plugins (mostly vim plugns), can still cause loops.
			-- When a loop is detected, Noice exits.
			-- Enable this option to simply skip duplicate messages instead.
			skip_duplicate_messages = true,
		},
	})
end
