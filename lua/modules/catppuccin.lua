return function()
    local catppuccin = require("catppuccin")

    -- configure it
    catppuccin.setup({
        transparent_background = false,
        term_colors = true,
        highlight_overrides = {
            -- all = function(colors)
            --     return {
            --         NvimTreeNormal = { fg = colors.none },
            --         CmpBorder = { fg = "#3e4145" },
            --     }
            -- end,
            -- latte = function(latte)
            --     return {
            --         Normal = { fg = latte.base },
            --     }
            -- end,
            -- frappe = function(frappe)
            --     return {
            --         ["@comment"] = { fg = frappe.surface2, style = { "italic" } },
            --     }
            -- end,
            -- macchiato = function(macchiato)
            --     return {
            --         LineNr = { fg = macchiato.overlay1 },
            --     }
            -- end,
            mocha = function(mocha)
                return {
                    Comment = { fg = "#b3e0ff" },
                    -- Comment = { fg = "#cccccc" },
                    -- Comment = { fg = "#ffffcc" }
                    Normal = { fg = "#ffffff" }
                }
            end,
        },
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
            semantic_tokens = true
        },
        compile_path = vim.fn.stdpath "cache" .. "/catppuccin"
    })
end
