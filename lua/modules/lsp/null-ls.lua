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
	-- on_init = function(new_client, _)
	-- 	new_client.offset_encoding = "utf-8"
	-- end,

	-- https://github.com/jose-elias-alvarez/null-ls.nvim/blob/main/doc/BUILTINS.md
	sources = {
		-- format
		formatting.asmfmt,
		formatting.stylua,
		formatting.prettier,
		formatting.black.with({ extra_args = { "--fast" } }),
		formatting.shfmt,

		-- Disable it because command line arguments take precedence over .clang-format file
		-- c/cpp
		-- formatting.clang_format.with({
		-- 	extra_args = {
		-- 		"--sort-includes",
		-- 		"-style",
		-- 		"{BasedOnStyle: google, IndentWidth: 4}",
		-- 	},
		-- }),

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

		-- code action
		-- code_actions.gitsigns,

		-- lint

		-- diagnostics
		-- diagnostics.markdownlint
		-- diagnostics.flake8
	},
})
