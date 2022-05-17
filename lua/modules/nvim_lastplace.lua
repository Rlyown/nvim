require("nvim-lastplace").setup({
	lastplace_ignore_buftype = { "quickfix", "nofile", "help" },
	lastplace_ignore_filetype = {
		"gitcommit",
		"gitrebase",
		"svn",
		"hgcommit",
		"Outline",
		"NvimTree",
		"dapui_breakpoints",
		"dapui_scopes",
		"dapui_stacks",
		"dapui_watches",
		"dap-rel",
	},
	lastplace_open_folds = true,
})
