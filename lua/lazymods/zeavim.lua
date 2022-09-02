local zeal_path = require("core.gvariable").zeal_path

return function()
	vim.g.zv_zeal_executable = "zeal"
	vim.g.zv_disable_mapping = true
	vim.g.zv_file_types = {
		["python"] = "python_3",
	}
end
