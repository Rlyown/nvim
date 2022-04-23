local notify_status_ok, notify = pcall(require, "notify")
if not notify_status_ok then
	return
end

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
	timeout = 5000,

	-- Max number of columns for messages
	max_width = 80,
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
})

-- Utility functions shared between progress reports for LSP and DAP
local client_notifs = {}

local function get_notif_data(client_id, token)
	if not client_notifs[client_id] then
		client_notifs[client_id] = {}
	end

	if not client_notifs[client_id][token] then
		client_notifs[client_id][token] = {}
	end

	return client_notifs[client_id][token]
end

local spinner_frames = { "⣾", "⣽", "⣻", "⢿", "⡿", "⣟", "⣯", "⣷" }

local function update_spinner(client_id, token)
	local notif_data = get_notif_data(client_id, token)

	if notif_data.spinner then
		local new_spinner = (notif_data.spinner + 1) % #spinner_frames
		notif_data.spinner = new_spinner

		notif_data.notification = vim.notify(nil, nil, {
			hide_from_history = true,
			icon = spinner_frames[new_spinner],
			replace = notif_data.notification,
		})

		vim.defer_fn(function()
			update_spinner(client_id, token)
		end, 100)
	end
end

local function format_title(title, client_name)
	return client_name .. (#title > 0 and ": " .. title or "")
end

local function format_message(message, percentage)
	return (percentage and percentage .. "%\t" or "") .. (message or "")
end

-- LSP integration
-- Make sure to also have the snippet with the common helper functions in your config!
vim.lsp.handlers["$/progress"] = function(_, result, ctx)
	local client_id = ctx.client_id

	local val = result.value

	if not val.kind then
		return
	end

	local notif_data = get_notif_data(client_id, result.token)

	if val.kind == "begin" then
		local message = format_message(val.message, val.percentage)

		notif_data.notification = vim.notify(message, "info", {
			title = format_title(val.title, vim.lsp.get_client_by_id(client_id).name),
			icon = spinner_frames[1],
			timeout = false,
			hide_from_history = false,
		})

		notif_data.spinner = 1
		update_spinner(client_id, result.token)
	elseif val.kind == "report" and notif_data then
		notif_data.notification = vim.notify(format_message(val.message, val.percentage), "info", {
			replace = notif_data.notification,
			hide_from_history = false,
		})
	elseif val.kind == "end" and notif_data then
		notif_data.notification = vim.notify(val.message and format_message(val.message) or "Complete", "info", {
			icon = " ",
			replace = notif_data.notification,
			timeout = 3000,
		})

		notif_data.spinner = nil
	end
end
