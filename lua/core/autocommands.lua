local group = vim.api.nvim_create_augroup("ConfigGeneral", { clear = true })
vim.api.nvim_create_autocmd("TextYankPost", {
    group = group,
    callback = function() vim.hl.on_yank({ higroup = "Visual", timeout = 200 }) end,
})
vim.api.nvim_create_autocmd("FileType", {
    group = group,
    callback = function(args)
        vim.opt_local.formatoptions:remove({ "c", "r", "o" })
        if vim.tbl_contains({ "qf", "help", "man" }, vim.bo[args.buf].filetype) then
            vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = args.buf, desc = "关闭窗口" })
        end
    end,
})
