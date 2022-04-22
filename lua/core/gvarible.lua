local M = {}

M.modules_dir = vim.fn.stdpath("config") .. "/lua/modules"

function M.setup()
	vim.g.python3_host_prog = "/opt/homebrew/bin/python3" -- specify the python3 path if there are multiple versions

	-- set default colorscheme
	local catppuccin_status_ok, _ = pcall(require, "catppuccin")
	if catppuccin_status_ok then
		vim.cmd([[colorscheme catppuccin]])
	end

	-- set default notify function
	local notify_status_ok, notify = pcall(require, "notify")
	if notify_status_ok then
		vim.notify = notify
	end

	-- If you want to toggle git-editor with current nvim instead of a nested one after ":terminal", you can uncomment the following settings
	-- if vim.fn.has("nvim") and vim.fn.executable("nvr") then
	-- 	vim.cmd([[let $GIT_EDITOR = "nvr -cc split --remote-wait +'set bufhidden=delete'" ]])
	-- end
end

M.fn = {
	["async_ui_input_wrap"] = function()
		local async = require("plenary.async")

		return async.wrap(function(opts, callback)
			vim.ui.input(opts, callback)
		end, 2)
	end,
}

return M
