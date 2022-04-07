-- this is used for fixing offsetEncoding conflict with null-ls
-- relative issue: https://github.com/jose-elias-alvarez/null-ls.nvim/issues/428
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities.offsetEncoding = { "utf-16" }

local query_driver = "--query-driver=/use/bin/clang,/usr/bin/clang++"
local clang_tidy_check = "--clang-tidy-checks=performance-*,bugprone-*,linuxkernel-*"

if vim.fn.has("mac") then
	query_driver = "--query-driver=/use/bin/clang,/usr/bin/clang++"
elseif vim.fn.has("unix") then
	query_driver = "--query-driver=/use/bin/clang,/usr/bin/clang++,/usr/bin/gcc,/usr/bin/g++"
end

return {
	cmd = {
		"clangd",
		"--fallback-style=google",
		"--background-index",
		"--suggest-missing-includes",
		"-j=2",
		"--clang-tidy",
		clang_tidy_check,
		"--all-scopes-completion",
		"--header-insertion=iwyu",
		"--completion-style=detailed",
		query_driver,
		"--inlay-hints",
	},
	capabilities = capabilities,
}
