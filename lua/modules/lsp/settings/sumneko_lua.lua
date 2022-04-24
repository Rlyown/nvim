local runtime_path = vim.split(package.path, ";")
table.insert(runtime_path, "lua/?.lua")
table.insert(runtime_path, "lua/?/init.lua")

return {
	settings = {

		Lua = {
			diagnostics = {
				globals = { "vim" },
			},
			workspace = {
				library = {
					[vim.fn.expand("$VIMRUNTIME/lua")] = true,
					[vim.fn.stdpath("config") .. "/lua"] = true,
				},
			},
			format = {
				enable = false,
				-- Put format options here
				defaultConfig = {
					indent_style = "space",
					indent_size = "4",
					quote_style = "double",
					continuation_indent_size = "8",
					local_assign_continuation_align_to_first_expression = true,
					align_call_args = true,
					label_no_indent = false,
					if_condition_no_continuation_indent = false,
					table_append_expression_no_space = false,
					if_condition_align_with_each_other = false,
				},
			},
		},
	},
}
