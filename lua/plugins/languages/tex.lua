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
            callback = function() require("modules.tex").focus_terminal() end,
        })
    end, keys = {
        { "<localleader>b", "<plug>(vimtex-compile)", ft = "tex", desc = "Compile LaTeX" },
        { "<localleader>r", "<plug>(vimtex-view)", ft = "tex", desc = "View PDF" },
        { "<localleader>h", "<plug>(vimtex-info)", ft = "tex", desc = "LaTeX Information" },
        { "<localleader>at", "<plug>(vimtex-toc-toggle)", ft = "tex", desc = "Toggle Table of Contents" },
        { "<localleader>ac", "<plug>(vimtex-clean)", ft = "tex", desc = "Clean Build" },
    } },
}
