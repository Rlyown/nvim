-- this is used for fixing offsetEncoding conflict with null-ls
-- relative issue: https://github.com/jose-elias-alvarez/null-ls.nvim/issues/428
-- local capabilities = vim.lsp.protocol.make_client_capabilities()
-- capabilities.offsetEncoding = { "utf-16" }

local query_driver = "--query-driver=/use/bin/clang,/usr/bin/clang++"

if vim.fn.has("mac") then
	if vim.fn.executable("brew") then
		query_driver =
			"--query-driver=/opt/homebrew/opt/llvm/bin/clang,/opt/homebrew/opt/llvm/bin/clang++,/use/bin/clang,/usr/bin/clang++"
	else
		query_driver = "--query-driver=/use/bin/clang,/usr/bin/clang++"
	end
elseif vim.fn.has("unix") then
	query_driver = "--query-driver=/use/bin/clang,/usr/bin/clang++,/usr/bin/gcc,/usr/bin/g++"
end

-- .clang-tidy and .clang-format set by local file
return {
	cmd = {
		"clangd",
		-- "--fallback-style=llvm",
		"--background-index",
		"--compile-commands-dir=build",
		"-j=2",
		"--clang-tidy",
		"--all-scopes-completion",
		"--header-insertion=iwyu",
		"--completion-style=detailed",
		query_driver,
		"--inlay-hints",
		"--pch-storage=disk",
		-- "--log=verbose",
	},
	-- capabilities = capabilities,
}
