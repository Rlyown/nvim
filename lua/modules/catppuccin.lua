return function()
    local catppuccin = require("catppuccin")

    -- configure it
    catppuccin.setup({
        transparent_background = false,
        term_colors = true,
        integrations = {
            lsp_trouble = true,
            nvimtree = {
                enabled = true,
                show_root = true,
                transparent_panel = false,
            },
            which_key = true,
            -- This option will override ts_rainbow colors in treesitter.lua
            ts_rainbow = true,
            dap = {
                enabled = true,
                enable_ui = true,
            },
            indent_blankline = {
                enabled = true,
                colored_indent_levels = false,
            },
            native_lsp = {
                enabled = true,
                virtual_text = {
                    errors = { "italic" },
                    hints = { "italic" },
                    warnings = { "italic" },
                    information = { "italic" },
                },
                underlines = {
                    errors = { "underline" },
                    hints = { "underline" },
                    warnings = { "underline" },
                    information = { "underline" },
                },
            },
            navic = {
                enabled = true,
                custom_bg = "NONE",
            },
        },
        compile_path = vim.fn.stdpath "cache" .. "/catppuccin"
    })
end
