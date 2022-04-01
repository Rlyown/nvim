local util = require("lspconfig/util")
return {
	cmd = { "gopls", "serve" },
	filetypes = { "go", "gomod" , "gotmpl"},
	root_dir = util.root_pattern("go.work", "go.mod", ".git"),
	settings = {
		gopls = {
			analyses = {
				unusedparams = true,
			},
			staticcheck = true,
		},
	},
}
