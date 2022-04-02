M = {}

local g = vim.g

function M.setup()
	g.python3_host_prog = "/opt/homebrew/bin/python3" -- specify the python3 path if there are multiple versions
end

return M
