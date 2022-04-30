-- vim.g.loaded_nvimgdb = 1

vim.cmd([[
    function! NvimGdbEnter()
      noremap <silent> <buffer> i <c-w>j
    endfunction
]])

vim.g.nvimgdb_config_override = {
	-- key_next = "n",
	-- key_step = "s",
	-- key_finish = "f",
	-- key_continue = "c",
	-- key_until = "u",
	key_breakpoint = "<space>",
}
