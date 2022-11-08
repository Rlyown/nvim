-- this is used for fixing offsetEncoding conflict with null-ls
-- relative issue: https://github.com/jose-elias-alvarez/null-ls.nvim/issues/428
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities.offsetEncoding = { "utf-16" }

local os = require("core.gvariable").os
local compiler = require("core.gvariable").compiler

local query_driver = "--query-driver="
for cpr, cpr_path in pairs(compiler) do
	if cpr_path ~= "" then
		query_driver = query_driver .. cpr .. "=" .. cpr_path .. ","
	end
end

if query_driver ~= "--query-driver=" then
	query_driver = query_driver:sub(1, -2)
else
	query_driver = ""
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
	capabilities = capabilities,
}
