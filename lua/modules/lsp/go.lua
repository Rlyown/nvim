return function()
	vim.g.go_list_type = "quickfix" -- enforce vim-go use quickfix
	vim.g.go_fmt_autosave = 0 -- disable vim-go auto format, use builtin-lsp instead.
	vim.g.go_imports_autosave = 0 -- disable vim-go auto format, use builtin-lsp instead.
	vim.g.go_mod_fmt_autosave = 0 -- disable vim-go auto format, use builtin-lsp instead.
	vim.g.go_metalinter_autosave = 0 -- use staticcheck
	vim.g.go_metalinter_autosave_enabled = {} -- use builtin-lsp instead
	vim.g.go_metalinter_enabled = {} -- use builtin-lsp instead
	vim.g.go_metalinter_command = "gopls" -- dont use golangci-lint, use staticcheck instead
	vim.g.go_fmt_fail_silently = 1 -- dont show quickfix when gofmt encounter any errors during parsing the file
	vim.g.go_addtags_transform = "camelcase" -- snake_case or camelcase
	vim.g.go_code_completion_enabled = 0 -- Enable code completion with 'omnifunc'
	vim.g.go_test_show_name = 1 -- Show the name of each failed test before the errors and logs output by the test
	vim.g.go_term_enabled = 1
	vim.g.go_term_reuse = 1
	vim.g.go_term_mode = "split"
	vim.g.go_term_height = 15
	vim.g.go_term_width = 20
	vim.g.go_addtags_skip_unexported = 1
	vim.g.go_addtags_transform = "camelcase"
end
