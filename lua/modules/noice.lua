return function()
	local custom_routes = {
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
				event = "msg_show",
				kind = "confirm_sub",
			},
			view = "cmdline",
		},
		{
			filter = {
				event = "msg_show",
				kind = "",
				find = "^Error running notification service: ...art/nvim-notify/lua/notify/service/buffer/highlights.lua:153: Invalid buffer id:",
			},
			opts = { skip = true },
		},
	}

	require("noice").setup({
		cmdline = {
			view = "cmdline", -- view for rendering the cmdline. Change to `cmdline` to get a classic cmdline at the bottom
		},
		popupmenu = {
			enabled = false, -- enables the Noice popupmenu UI
			backend = "cmp",
		},
		lsp = {
			hover = {
				enabled = false,
			},
			signature = {
				enabled = false,
			},
		},
		---@type NoicePresets
		presets = {
			bottom_search = true, -- use a classic bottom cmdline for search
		},
		routes = custom_routes, --- @see section on routes
	})
end
