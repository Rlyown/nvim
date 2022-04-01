M = {}

local g = vim.g

function M.setup()
	g.python3_host_prog = "/opt/homebrew/bin/python3" -- specify the python3 path if there are multiple versions

    -- vim-go settings
    g.go_list_type = "quickfix" -- enforce vim-go use quickfix
    g.go_fmt_autosave = 0 -- disable vim-go auto format, use builtin-lsp instead.
    g.go_imports_autosave = 0 -- disable vim-go auto format, use builtin-lsp instead.
    g.go_mod_fmt_autosave = 0 -- disable vim-go auto format, use builtin-lsp instead.
    g.go_metalinter_autosave = 0 -- use staticcheck
    g.go_metalinter_autosave_enabled = {} -- use builtin-lsp instead
    g.go_metalinter_enabled = {} -- use builtin-lsp instead
    g.go_metalinter_command = "gopls" -- dont use golangci-lint, use staticcheck instead
    g.go_fmt_fail_silently = 1 -- dont show quickfix when gofmt encounter any errors during parsing the file
    g.go_addtags_transform = "camelcase" -- snake_case or camelcase
    g.go_code_completion_enabled = 0 -- Enable code completion with 'omnifunc'
    g.go_test_show_name = 1 -- Show the name of each failed test before the errors and logs output by the test
    g.go_term_enabled = 1
    g.go_term_reuse = 1
    g.go_term_mode = "split"
    g.go_term_height = 15
    g.go_term_width = 20
    g.go_addtags_skip_unexported = 1
    g.go_addtags_transform = "camelcase"
end

return M
