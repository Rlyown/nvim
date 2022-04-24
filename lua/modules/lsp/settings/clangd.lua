-- this is used for fixing offsetEncoding conflict with null-ls
-- relative issue: https://github.com/jose-elias-alvarez/null-ls.nvim/issues/428
-- local capabilities = vim.lsp.protocol.make_client_capabilities()
-- capabilities.offsetEncoding = { "utf-16" }

local llvm_path = require("core.gvariable").llvm_bin_path
local os = require("core.gvariable").os

local query_driver = "--query-driver=/use/bin/clang,/usr/bin/clang++"

if os == "mac" then
	if vim.fn.isdirectory(llvm_path) then
		query_driver = string.format(
			"--query-driver=%s/clang,%s/clang++,/use/bin/clang,/usr/bin/clang++",
			llvm_path,
			llvm_path
		)
	else
		query_driver = "--query-driver=/use/bin/clang,/usr/bin/clang++"
	end
elseif os == "unix" then
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
