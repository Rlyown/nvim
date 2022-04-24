local M = {}
local args_parse = require("core.gvariable").fn.args_parse

M.get_args = function()
	local data_in = vim.fn.input("Set args(<space> sep): ")
	if not data_in or (data_in == "") then
		return {}
	end
	return args_parse(data_in, " ")
end

return M
