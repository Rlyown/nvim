local M = {}
local args_parse = require("core.gvariable").fn.args_parse

M.get_args = function()
	local data_in = vim.fn.input("Set args(sep: space): ")
	if not data_in or (data_in == "") then
		return {}
	end
	return args_parse(data_in, " ")
end

-- Note: the sign might be overwritten by lsp diagnostics.
-- Change line number color to fix it.
M.dap_signs_scheme = function(num)
	if num == 1 then
		vim.fn.sign_define("DapBreakpoint", { text = "", texthl = "DiagnosticSignHint", linehl = "", numhl = "" })
		vim.fn.sign_define(
			"DapBreakpointCondition",
			{ text = "", texthl = "DiagnosticSignHint", linehl = "", numhl = "" }
		)
		vim.fn.sign_define("DapLogPoint", { text = "ﱴ", texthl = "DiagnosticSignHint", linehl = "", numhl = "" })
		vim.fn.sign_define("DapStopped", {
			text = "",
			texthl = "DiagnosticSignInfo",
			linehl = "QuickFixLine",
			numhl = "CursorLineNr",
		})
		vim.fn.sign_define(
			"DapBreakpointRejected",
			{ text = "", texthl = "DiagnosticSignError", linehl = "", numhl = "" }
		)
	elseif num == 2 then
		vim.fn.sign_define("DapBreakpoint", { text = "", texthl = "", linehl = "", numhl = "TSWarning" })
		vim.fn.sign_define("DapBreakpointCondition", { text = "", texthl = "", linehl = "", numhl = "TSWarning" })
		vim.fn.sign_define("DapLogPoint", { text = "", texthl = "", linehl = "", numhl = "TSWarning" })
		vim.fn.sign_define("DapStopped", {
			text = "",
			texthl = "",
			linehl = "QuickFixLine",
			numhl = "TSNote",
		})
		vim.fn.sign_define("DapBreakpointRejected", { text = "", texthl = "", linehl = "", numhl = "TSDanger" })
	elseif num == 3 then
		vim.fn.sign_define("DapBreakpoint", { text = "", texthl = "", linehl = "", numhl = "lualine_b_command" })
		vim.fn.sign_define(
			"DapBreakpointCondition",
			{ text = "", texthl = "", linehl = "", numhl = "lualine_b_command" }
		)
		vim.fn.sign_define("DapLogPoint", { text = "", texthl = "", linehl = "", numhl = "lualine_b_command" })
		vim.fn.sign_define("DapStopped", {
			text = "",
			texthl = "",
			linehl = "QuickFixLine",
			numhl = "lualine_b_normal",
		})
		vim.fn.sign_define(
			"DapBreakpointRejected",
			{ text = "", texthl = "", linehl = "", numhl = "lualine_b_replace" }
		)
	end
end

return M
