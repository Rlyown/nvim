return function()
	local node_path = require("core.gvariable").node_path
	-- set a proxy
	vim.g.copilot_proxy = "localhost:7890"

	-- set node path, if it has multi-versions
	vim.g.copilot_node_command = node_path
	vim.g.copilot_no_tab_map = true
	vim.g.copilot_assume_mapped = true
	vim.g.copilot_tab_fallback = ""
end
