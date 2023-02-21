return function()
	local notify = require("notify")

	-- enable 24-bit colour
	vim.opt.termguicolors = true

	notify.setup({
		-- Minimum level to show
		level = "info",

		-- Animation style (see below for details)
		stages = "fade_in_slide_out",

		-- Function called when a new window is opened, use for changing win settings/config
		on_open = function(win)
			-- enable wrap line
			vim.fn.setwinvar(win, "&wrap", 1)
		end,

		-- Function called when a window is closed
		on_close = nil,

		-- Render function for notifications. See notify-render()
		render = "default",

		-- Default timeout for notifications
		timeout = 1500,

		-- Max number of columns for messages
		max_width = 50,
		-- Max number of lines for a message
		max_height = 40,

		-- For stages that change opacity this is treated as the highlight behind the window
		-- Set this to either a highlight group, an RGB hex value e.g. "#000000" or a function returning an RGB code for dynamic values
		background_colour = "Normal",

		-- Minimum width for notification windows
		minimum_width = 50,

		-- Icons for the different levels
		icons = {
			ERROR = " ",
			WARN = " ",
			INFO = " ",
			DEBUG = " ",
			TRACE = "✎ ",
		},

		top_down = true,
	})

	require("telescope").load_extension("notify")

	-- Similar plugin https://github.com/j-hui/fidget.nvim
end
