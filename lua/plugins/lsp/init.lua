LSP_SERVERS = {
    "asm_lsp",
    "bashls",
    "clangd",
    "cmake",
    "dockerls",
    "gopls",
    "jsonls",
    -- "ltex",
    "texlab",
    "lua_ls",
    "taplo",
    "pyright",
    "yamlls",
    "lemminx",
    -- "mesonlsp",
}

return {
    {
        "williamboman/mason.nvim", -- Portable package manager for Neovim that runs everywhere Neovim runs.
        opts = {
            pip = {
                install_args = {
                    "-i",
                    "https://pypi.tuna.tsinghua.edu.cn/simple",
                },
            },
        },
        cmd = { "Mason", "MasonInstall", "MasonUninstall", "MasonUninstallAll", "MasonLog" },
        event = "User FileOpened",
        lazy = true,
    },
    {
        "williamboman/mason-lspconfig.nvim", -- Extension to mason.nvim that makes it easier to use lspconfig with mason.nvim
        opts = {
            ensure_installed = LSP_SERVERS,
        },
        dependencies = {
            "mason.nvim",
        },
        cmd = { "LspInstall", "LspUninstall" },
        event = "User FileOpened",
        lazy = true,
    },
    {
        "neovim/nvim-lspconfig", -- enable LSP
        config = function()
            vim.diagnostic.config({
                -- disable virtual text
                virtual_text = false,
                -- show signs
                signs = {
                    active = {
                        { name = "DiagnosticSignError", text = "" },
                        { name = "DiagnosticSignWarn", text = "" },
                        { name = "DiagnosticSignHint", text = "" },
                        { name = "DiagnosticSignInfo", text = "" },
                    },
                },
                update_in_insert = true,
                underline = true,
                severity_sort = true,
                float = {
                    focusable = false,
                    style = "minimal",
                    border = "rounded",
                    source = true,
                    header = "",
                    prefix = "",
                },
            })

            vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
                border = "rounded",
            })

            vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, {
                border = "rounded",
            })

            local function get_config_path(server_name)
                return string.format("plugins.lsp.settings.%s", server_name)
            end

            for _, server_name in pairs(LSP_SERVERS) do
                local has_config, server_opts = pcall(require, get_config_path(server_name))
                if has_config then
                    vim.lsp.config(server_name, server_opts)
                end
                vim.lsp.enable(server_name)
            end
        end,
        dependencies = {
            "williamboman/mason-lspconfig.nvim",

        },
        lazy = true,
    },
    {
        "WhoIsSethDaniel/mason-tool-installer.nvim",
        opts = {
            -- a list of all tools you want to ensure are installed upon
            -- start; they should be the names Mason uses for each tool
            ensure_installed = {
                -- Lint
                --[[ "markdownlint", ]]
                "shellcheck",
                "vim-language-server",
                "cmakelang",

                -- Format
                "black",
                "shfmt",
                "prettier",
                "latexindent",

                -- DAP
                "codelldb",
                "debugpy",
                "delve",

                -- LSP
                -- setup by 3rd party plugins not lspconfig
                "rust_analyzer",
            }
        },
        dependencies = { "mason.nvim" },
    }, -- Install and upgrade third party tools automatically
    {
        "nvimtools/none-ls.nvim",
        config = function()
            local null_ls = require("null-ls")
            null_ls.setup({
                sources = {
                    require("null-ls").builtins.formatting.prettier,
                    require("null-ls").builtins.formatting.black,
                    require("null-ls").builtins.formatting.shfmt,
                }
            })
        end
    }, -- for formatters and linters

    {
        "simrat39/symbols-outline.nvim",
        opts = {
            highlight_hovered_item = true,
            show_guides = true,
            auto_preview = false,
            position = "right",
            relative_width = true,
            width = 25,
            auto_close = false,
            show_numbers = false,
            show_relative_numbers = false,
            show_symbol_details = true,
            preview_bg_highlight = "Pmenu",
            autofold_depth = nil,
            auto_unfold_hover = true,
            fold_markers = { "", "" },
            wrap = false,
            keymaps = { -- These keymaps can be a string or a table for multiple keys
                close = { "<Esc>", "q" },
                goto_location = "<Cr>",
                focus_location = "o",
                hover_symbol = "<C-space>",
                toggle_preview = "K",
                rename_symbol = "r",
                code_actions = "a",
                fold = "h",
                unfold = "l",
                fold_all = "W",
                unfold_all = "E",
                fold_reset = "R",
            },
            symbols = {
                File = { icon = require("core.gvariable").symbol_map.File, hl = "TSURI" },
                Module = { icon = require("core.gvariable").symbol_map.Module, hl = "TSNamespace" },
                Namespace = { icon = require("core.gvariable").symbol_map.Namespace, hl = "TSNamespace" },
                Package = { icon = require("core.gvariable").symbol_map.Package, hl = "TSNamespace" },
                Class = { icon = require("core.gvariable").symbol_map.Class, hl = "TSType" },
                Method = { icon = require("core.gvariable").symbol_map.Method, hl = "TSMethod" },
                Property = { icon = require("core.gvariable").symbol_map.Property, hl = "TSMethod" },
                Field = { icon = require("core.gvariable").symbol_map.Field, hl = "TSField" },
                Constructor = { icon = require("core.gvariable").symbol_map.Constructor, hl = "TSConstructor" },
                Enum = { icon = require("core.gvariable").symbol_map.Enum, hl = "TSType" },
                Interface = { icon = require("core.gvariable").symbol_map.Interface, hl = "TSType" },
                Function = { icon = require("core.gvariable").symbol_map.Function, hl = "TSFunction" },
                Variable = { icon = require("core.gvariable").symbol_map.Variable, hl = "TSConstant" },
                Constant = { icon = require("core.gvariable").symbol_map.Constant, hl = "TSConstant" },
                String = { icon = require("core.gvariable").symbol_map.String, hl = "TSString" },
                Number = { icon = require("core.gvariable").symbol_map.Number, hl = "TSNumber" },
                Boolean = { icon = require("core.gvariable").symbol_map.Boolean, hl = "TSBoolean" },
                Array = { icon = require("core.gvariable").symbol_map.Array, hl = "TSConstant" },
                Object = { icon = require("core.gvariable").symbol_map.Object, hl = "TSType" },
                Key = { icon = require("core.gvariable").symbol_map.Keyword, hl = "TSType" },
                Null = { icon = "NULL", hl = "TSType" },
                EnumMember = { icon = require("core.gvariable").symbol_map.EnumMember, hl = "TSField" },
                Struct = { icon = require("core.gvariable").symbol_map.Struct, hl = "TSType" },
                Event = { icon = require("core.gvariable").symbol_map.Event, hl = "TSType" },
                Operator = { icon = require("core.gvariable").symbol_map.Operator, hl = "TSOperator" },
                TypeParameter = { icon = require("core.gvariable").symbol_map.TypeParameter, hl = "TSParameter" },
            },
        },
        cmd = "SymbolsOutline",
        lazy = true
    }, -- A tree like view for symbols
    { "andymass/vim-matchup",       lazy = true, keys = { "%" } },

    -- languages
    { import = "plugins.lsp.vimtex" },
    { import = "plugins.lsp.go" },
    { import = "plugins.lsp.neorg" },
    { import = "plugins.lsp.rust" },
}
