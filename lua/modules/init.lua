local M = {}

local modules_dir = require("core.gvarible").modules_dir

function M.setup(user_conf)
	local ignore = user_conf.ignore or {}

	local rev_ignore_list = {}
	for _, name in ipairs(ignore) do
		rev_ignore_list[name] = true
	end

	local plugins = vim.fn.readdir(modules_dir)

	for _, f in ipairs(plugins) do
		local pname = f
		if f:sub(-4, -1) == ".lua" then
			pname = f:sub(0, -5)
		end

		if not rev_ignore_list[pname] then
			require("modules." .. pname)
		end
	end
end

return M
