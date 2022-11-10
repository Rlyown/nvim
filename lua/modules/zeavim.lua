return function()
	local zeal_path = require("core.gvariable").zeal_path
	vim.g.zv_zeal_executable = zeal_path
	vim.g.zv_disable_mapping = true
	vim.g.zv_file_types = {
		["python"] = "python_3",
	}
end
