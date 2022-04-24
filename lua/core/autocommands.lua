-- To get your imports ordered on save, like goimports does
function _G.OrgImports(wait_ms)
	local params = vim.lsp.util.make_range_params()
	params.context = { only = { "source.organizeImports" } }
	local result = vim.lsp.buf_request_sync(0, "textDocument/codeAction", params, wait_ms)
	for _, res in pairs(result or {}) do
		for _, r in pairs(res.result or {}) do
			if r.edit then
				vim.lsp.util.apply_workspace_edit(r.edit, "UTF-8")
			else
				vim.lsp.buf.execute_command(r.command)
			end
		end
	end
end

local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

augroup("_general_settings", { clear = true })
autocmd("FileType", {
	group = "_general_settings",
	pattern = { "qf", "help", "man", "lspinfo", "startuptime" },
	command = "nnoremap <silent> <buffer> q :close<CR>",
})
autocmd("TextYankPost", {
	group = "_general_settings",
	pattern = "*",
	command = "silent!lua require('vim.highlight').on_yank({higroup = 'Visual', timeout = 200})",
})
autocmd("BufWinEnter", {
	group = "_general_settings",
	pattern = "*",
	command = ":set formatoptions-=cro",
})
autocmd("FileType", {
	group = "_general_settings",
	pattern = "qf",
	command = "set nobuflisted",
})

augroup("_git", { clear = true })
autocmd("FileType", {
	group = "_git",
	pattern = "gitcommit",
	command = "setlocal wrap",
})
autocmd("FileType", {
	group = "_git",
	pattern = "gitcommit",
	command = "setlocal spell",
})

augroup("_markdown", { clear = true })
autocmd("FileType", {
	group = "_markdown",
	pattern = "markdown",
	command = "setlocal wrap",
})
autocmd("FileType", {
	group = "_markdown",
	pattern = "markdown",
	command = "setlocal spell",
})

augroup("_auto_resize", { clear = true })
autocmd("VimResized", {
	group = "_auto_resize",
	pattern = "*",
	command = "tabdo wincmd =",
})

augroup("_alpha", { clear = true })
autocmd("User", {
	group = "_alpha",
	pattern = "AlphaReady",
	command = "set showtabline=0 | autocmd BufUnload <buffer> set showtabline=2",
})

augroup("_lsp", { clear = true })
autocmd("BufWritePre", {
	group = "_lsp",
	pattern = "*",
	callback = function()
		vim.lsp.buf.formatting_sync()
	end,
	desc = "auto format",
})
autocmd("BufWritePre", {
	group = "_lsp",
	pattern = "*.go",
	callback = function()
		OrgImports(1000)
	end,
})

augroup("_auto_close", { clear = true })
autocmd("BufEnter", {
	group = "_auto_close",
	pattern = "*",
	callback = function()
		if vim.fn.winnr("$") == 1 then
			if vim.fn.bufname() == "NvimTree_" .. vim.fn.tabpagenr() then
				vim.cmd("quit")
			elseif vim.bo.filetype == "aerial" then
				vim.cmd("quit")
			end
		end
	end,
	nested = true,
})
