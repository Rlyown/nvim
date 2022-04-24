-- To get your imports ordered on save, like goimports does
function OrgImports(wait_ms)
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

vim.cmd([[
    augroup _general_settings
        autocmd!
        autocmd FileType qf,help,man,lspinfo nnoremap <silent> <buffer> q :close<CR> 
        autocmd TextYankPost * silent!lua require('vim.highlight').on_yank({higroup = 'Visual', timeout = 200}) 
        autocmd BufWinEnter * :set formatoptions-=cro
        autocmd FileType qf set nobuflisted
    augroup end

    augroup _git
        autocmd!
        autocmd FileType gitcommit setlocal wrap
        autocmd FileType gitcommit setlocal spell
    augroup end

    augroup _markdown
        autocmd!
        autocmd FileType markdown setlocal wrap
        autocmd FileType markdown setlocal spell
    augroup end

    augroup _auto_resize
        autocmd!
        autocmd VimResized * tabdo wincmd = 
    augroup end

    augroup _alpha
        autocmd!
        autocmd User AlphaReady set showtabline=0 | autocmd BufUnload <buffer> set showtabline=2
    augroup end

    " Autoformat
    augroup _lsp
        autocmd!
        autocmd BufWritePre * lua vim.lsp.buf.formatting_sync()
    augroup end
    "
    augroup _golang
        autocmd!
        autocmd BufWritePre *.go lua OrgImports(1000)
    augroup end

    " auto close nvim-tree"
    augroup _nvim_tree
        autocmd!
        autocmd BufEnter * ++nested if winnr('$') == 1 && bufname() == 'NvimTree_' . tabpagenr() | quit | endif
    augroup end

    " auto close aerial window
    augroup _aerial
        autocmd!
        autocmd BufEnter * ++nested if winnr('$') == 1 && &filetype == 'aerial' | quit | endif
    augroup end
]])
