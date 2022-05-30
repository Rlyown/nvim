local configs = require("lazymods.configs")

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

-- Related issue: https://github.com/L3MON4D3/LuaSnip/issues/258
function _G.leave_snippet()
	if
		((vim.v.event.old_mode == "s" and vim.v.event.new_mode == "n") or vim.v.event.old_mode == "i")
		and require("luasnip").session.current_nodes[vim.api.nvim_get_current_buf()]
		and not require("luasnip").session.jump_active
	then
		require("luasnip").unlink_current()
	end
end

-- example: t = {{bname=bufname, filetype=filetype}}
function _G.check_last_special_win(t)
	local name_cases = {
		["NvimTree_" .. vim.fn.tabpagenr()] = true,
		["OUTLINE"] = true,
		-- ["DAP Scopes"] = true,
		-- ["DAP Breakpoints"] = true,
		-- ["DAP Stacks"] = true,
		-- ["DAP Watches"] = true,
		-- ["[dap-repl]"] = true,
	}

	local type_cases = {
		["Outline"] = true,
		-- ["dapui_breakpoints"] = true,
		-- ["dapui_scopes"] = true,
		-- ["dapui_stacks"] = true,
		-- ["dapui_watches"] = true,
		-- ["dap-rel"] = true,
	}

	if not t or #t == 0 then
		return false
	end

	for _, value in ipairs(t) do
		if value.bname and name_cases[value.bname] then
		elseif value.filetype and type_cases[value.btype] then
		else
			return false
		end
	end

	return true
end

local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

augroup("_CUSTOM_general_settings", { clear = true })
autocmd("FileType", {
	group = "_CUSTOM_general_settings",
	pattern = { "qf", "help", "man", "lspinfo", "startuptime" },
	command = "nnoremap <silent> <buffer> q :close<CR>",
})
autocmd("TextYankPost", {
	group = "_CUSTOM_general_settings",
	pattern = "*",
	command = "silent!lua require('vim.highlight').on_yank({higroup = 'Visual', timeout = 200})",
})
autocmd("BufWinEnter", {
	group = "_CUSTOM_general_settings",
	pattern = "*",
	command = ":set formatoptions-=cro",
})
autocmd("FileType", {
	group = "_CUSTOM_general_settings",
	pattern = "qf",
	command = "set nobuflisted",
})

augroup("_CUSTOM_git", { clear = true })
autocmd("FileType", {
	group = "_CUSTOM_git",
	pattern = "gitcommit",
	command = "setlocal wrap",
})
autocmd("FileType", {
	group = "_CUSTOM_git",
	pattern = "gitcommit",
	command = "setlocal spell",
})

augroup("_CUSTOM_markdown", { clear = true })
autocmd("FileType", {
	group = "_CUSTOM_markdown",
	pattern = "markdown",
	command = "setlocal wrap",
})
autocmd("FileType", {
	group = "_CUSTOM_markdown",
	pattern = "markdown",
	command = "setlocal spell",
})

augroup("_CUSTOM_auto_resize", { clear = true })
autocmd("VimResized", {
	group = "_CUSTOM_auto_resize",
	pattern = "*",
	command = "tabdo wincmd =",
})

augroup("_CUSTOM_alpha", { clear = true })
autocmd("User", {
	group = "_CUSTOM_alpha",
	pattern = "AlphaReady",
	command = "set showtabline=0 | autocmd BufUnload <buffer> set showtabline=2",
})

augroup("_CUSTOM_lsp", { clear = true })
autocmd("BufWritePre", {
	group = "_CUSTOM_lsp",
	pattern = "*",
	callback = function()
		if vim.g.custom_enable_auto_format then
			vim.lsp.buf.formatting_sync()
		end
	end,
	desc = "auto format",
})
autocmd("BufWritePre", {
	group = "_CUSTOM_lsp",
	pattern = "*.go",
	callback = function()
		OrgImports(1000)
	end,
})
-- Issue: https://github.com/nvim-telescope/telescope.nvim/issues/559
autocmd("BufRead", {
	group = "_CUSTOM_lsp",
	pattern = "*",
	callback = function()
		vim.api.nvim_create_autocmd("BufWinEnter", {
			once = true,
			command = "normal! zx zM zR",
		})
	end,
})
-- Question: https://superuser.com/questions/567352/how-can-i-set-foldlevelstart-in-vim-to-just-fold-nothing-initially-still-allowi
autocmd("BufWinEnter", {
	group = "_CUSTOM_lsp",
	pattern = "*",
	command = [[ let &foldlevel = max(map(range(1, line('$')), 'foldlevel(v:val)')) ]],
})

augroup("_CUSTOM_auto_close", { clear = true })
autocmd("BufEnter", {
	group = "_CUSTOM_auto_close",
	pattern = "*",
	callback = function()
		local wins = {}
		local winnr = vim.fn.winnr("$")

		for w = 1, winnr do
			local buf = vim.fn.winbufnr(w)
			wins[#wins + 1] = {
				bname = vim.fn.bufname(buf),
				btype = vim.fn.getbufvar(buf, "&filetype"),
			}
		end

		if check_last_special_win(wins) then
			vim.cmd("quit")
		end
	end,
	nested = true,
})

-- stop snippets when you leave to normal mode
augroup("_CUSTOM_luasnip", { clear = true })
autocmd("ModeChanged", {
	group = "_CUSTOM_luasnip",
	pattern = "*",
	callback = leave_snippet,
})

augroup("_CUSTOM_cmp", { clear = true })
autocmd("FileType", {
	group = "_CUSTOM_cmp",
	pattern = "toml",
	callback = function()
		require("cmp").setup.buffer({ sources = { { name = "crates" } } })
	end,
})

augroup("_CUSTOM_wilder", { clear = true })
autocmd("CmdlineEnter", {
	group = "_CUSTOM_wilder",
	pattern = "*",
	once = true,
	callback = function()
		configs.wilder()
		vim.cmd([[call g:wilder#main#start()]])
	end,
})
