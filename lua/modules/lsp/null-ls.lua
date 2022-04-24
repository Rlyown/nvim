local null_ls_status_ok, null_ls = pcall(require, "null-ls")
if not null_ls_status_ok then
	return
end

local code_actions = null_ls.builtins.code_actions
-- https://github.com/jose-elias-alvarez/null-ls.nvim/tree/main/lua/null-ls/builtins/formatting
local formatting = null_ls.builtins.formatting
-- https://github.com/jose-elias-alvarez/null-ls.nvim/tree/main/lua/null-ls/builtins/diagnostics
local diagnostics = null_ls.builtins.diagnostics

null_ls.setup({
	debug = false,
	-- https://github.com/jose-elias-alvarez/null-ls.nvim/blob/main/doc/BUILTINS.md
	sources = {
		-- asm
		formatting.asmfmt,

		-- Disable it because command line arguments take precedence over .clang-format file
		-- c/cpp
		-- formatting.clang_format.with({
		-- 	extra_args = {
		-- 		"--sort-includes",
		-- 		"-style",
		-- 		"{BasedOnStyle: google, IndentWidth: 4}",
		-- 	},
		-- }),

		-- lua
		formatting.stylua,

		-- python
		formatting.black.with({ extra_args = { "--fast" } }),
		-- diagnostics.flake8

		-- rust
		-- formatting.rustfmt.with({
		-- 	extra_args = function(params)
		-- 		local Path = require("plenary.path")
		-- 		local cargo_toml = Path:new(params.root .. "/" .. "Cargo.toml")
		--
		-- 		if cargo_toml:exists() and cargo_toml:is_file() then
		-- 			for _, line in ipairs(cargo_toml:readlines()) do
		-- 				local edition = line:match([[^edition%s*=%s*%"(%d+)%"]])
		-- 				if edition then
		-- 					return { "--edition=" .. edition }
		-- 				end
		-- 			end
		-- 		end
		-- 		-- default edition when we don't find `Cargo.toml` or the `edition` in it.
		-- 		return { "--edition=2021" }
		-- 	end,
		-- }),

		-- shell
		formatting.shfmt,
	},
})
