return {
    { "saghen/blink.cmp", optional = true, opts = { sources = { per_filetype = { tex = { "omni", "path", "snippets", "buffer" } } } } },
    { "lervag/vimtex", lazy = false, init = function()
        vim.g.vimtex_mappings_enabled = 0
        vim.g.vimtex_imaps_enabled = 0
        vim.g.vimtex_view_automatic = 0
        vim.g.tex_flavor = "latex"
        vim.api.nvim_create_autocmd("User", {
            group = vim.api.nvim_create_augroup("ConfigVimtexFocus", { clear = true }),
            pattern = "VimtexEventViewReverse",
            callback = function()
                local app = vim.g.config_tex_focus_app or "iTerm"
                if vim.fn.has("mac") == 1 and vim.fn.executable("open") == 1 then
                    vim.fn.jobstart({ "open", "-a", app })
                end
            end,
        })
    end, keys = {
        { "<localleader>b", "<plug>(vimtex-compile)", ft = "tex", desc = "编译 LaTeX" },
        { "<localleader>r", "<plug>(vimtex-view)", ft = "tex", desc = "查看 PDF" },
        { "<localleader>h", "<plug>(vimtex-info)", ft = "tex", desc = "LaTeX 信息" },
        { "<localleader>at", "<plug>(vimtex-toc-toggle)", ft = "tex", desc = "目录" },
        { "<localleader>ac", "<plug>(vimtex-clean)", ft = "tex", desc = "清理构建" },
    } },
}
