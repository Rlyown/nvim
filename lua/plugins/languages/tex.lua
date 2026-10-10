return {
    { "saghen/blink.cmp", optional = true, opts = { sources = { per_filetype = { tex = { "omni", "path", "snippets", "buffer" } } } } },
    { "lervag/vimtex", lazy = false, init = function()
        vim.g.vimtex_mappings_enabled = 0
        vim.g.vimtex_imaps_enabled = 0
        vim.g.vimtex_view_automatic = 0
        vim.g.vimtex_quickfix_mode = 2
        vim.g.vimtex_quickfix_open_on_warning = 0
        vim.g.vimtex_compiler_method = "latexmk"
        -- Keep SyncTeX enabled even when overriding VimTeX's compiler defaults.
        vim.g.vimtex_compiler_latexmk = {
            options = { "-verbose", "-file-line-error", "-synctex=1", "-interaction=nonstopmode" },
        }
        vim.g.tex_flavor = "latex"
        -- The viewer is implemented in Neovim via Snacks.image + Kitty.
        vim.g.vimtex_view_enabled = 0
        require("modules.tex_preview").setup()
    end, keys = {
        { "<leader>lb", "<plug>(vimtex-compile)", ft = "tex", desc = "Compile LaTeX" },
        { "<leader>lr", function() require("modules.tex_preview").open() end, ft = "tex", desc = "Preview PDF (Kitty)" },
        { "<leader>lat", "<plug>(vimtex-toc-toggle)", ft = "tex", desc = "Toggle Table of Contents" },
        { "<leader>le", "<cmd>VimtexErrors<cr>", ft = "tex", desc = "LaTeX Errors" },
        { "<leader>lv", "<cmd>VimtexCompileOutput<cr>", ft = "tex", desc = "LaTeX Compilation Output" },
    } },
}
