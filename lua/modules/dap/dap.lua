return function()
	local dap = require("dap")
	local dapui = require("dapui")

	dap.listeners.after.event_initialized["dapui_config"] = function()
		dapui.open()
	end
	dap.listeners.before.event_terminated["dapui_config"] = function()
		dapui.close()
		dap.repl.close()
	end
	dap.listeners.before.event_exited["dapui_config"] = function()
		dapui.close()
		dap.repl.close()
	end

	require("modules.dap.util").dap_signs_scheme(3)

	-- setup adapter and language
	require("modules.dap.settings.lldb_vscode") -- for C/Cpp/Rust
	require("modules.dap.settings.delve") -- for Golang
	require("modules.dap.settings.debugpy") -- for Python, default interpreter is /usr/bin/python3

	-- Notify dap integration
	local notify_status_ok, _ = pcall(require, "notify")
	if notify_status_ok then
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

		-- DAP integration
		-- Make sure to also have the snippet with the common helper functions in your config!
		dap.listeners.before["event_progressStart"]["progress-notifications"] = function(session, body)
			local notif_data = get_notif_data("dap", body.progressId)

			local message = format_message(body.message, body.percentage)
			notif_data.notification = vim.notify(message, "info", {
				title = format_title(body.title, session.config.type),
				icon = spinner_frames[1],
				timeout = false,
				hide_form_history = false,
			})

			notif_data.notification.spinner = 1
			update_spinner("dap", body.progressId)
		end

		dap.listeners.before["event_progressUpdate"]["progress-notifications"] = function(session, body)
			local notif_data = get_notif_data("dap", body.progressId)
			notif_data.notification = vim.notify(format_message(body.message, body.percentage), "info", {
				replace = notif_data.notification,
				hide_form_history = false,
			})
		end

		dap.listeners.before["event_progressEnd"]["progress-notifications"] = function(session, body)
			local notif_data = client_notifs["dap"][body.progressId]
			notif_data.notification = vim.notify(body.message and format_message(body.message) or "Complete", "info", {
				icon = "?",
				replace = notif_data.notification,
				timeout = 1500,
			})
			notif_data.spinner = nil
		end
	end
end