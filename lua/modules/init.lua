local M = {}

local modules_dir = require("core.gvariable").modules_dir
local rev_table = require("core.gvariable").fn.rev_table

function M.setup(user_conf)
	local ignore = user_conf.ignore or {}

	local rev_ignore_list = rev_table(ignore, true)

	local plugins = vim.fn.readdir(modules_dir)

	for _, f in ipairs(plugins) do
		local pname = vim.fn.fnamemodify(f, ":r")

		if not rev_ignore_list[pname] then
			require("modules." .. pname)
		end
	end
end

return M
