_G.LSP_SERVERS = {
    "asm_lsp",
    "bashls",
    "clangd",
    "cmake",
    "dockerls",
    "jsonls",
    "texlab",
    "markdown_oxide",
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
        keys = {
            { "<leader>LI", "<cmd>Mason<cr>", desc = "Mason Info" },
        },
        lazy = false,
    },
    {
        "williamboman/mason-lspconfig.nvim", -- Extension to mason.nvim that makes it easier to use lspconfig with mason.nvim
        opts = {
            ensure_installed = LSP_SERVERS,
            automatic_enable = false
        },
        dependencies = {
            "williamboman/mason.nvim",
        },
        cmd = { "LspInstall", "LspUninstall" },
        event = "User FileOpened",
        lazy = false,
    },
    {
        "neovim/nvim-lspconfig", -- enable LSP
        config = function()
            local function get_config_path(server_name)
                return string.format("plugins.lsp.lsp_configs.%s", server_name)
            end

            for _, server_name in pairs(LSP_SERVERS) do
                local has_config, server_opts = pcall(require, get_config_path(server_name))
                if has_config then
                    vim.lsp.config(server_name, server_opts)
                end
                vim.lsp.enable(server_name)
                ::continue::
            end
        end,
        keys = {
            {
                'gD',
                vim.lsp.buf.declaration,
                desc = "Goto declaration"
            },
            {
                'gd',
                vim.lsp.buf.definition,
                desc = "Goto definition"
            },
            {
                'grr',
                "<cmd>Trouble lsp_references<cr>",
                desc = "Show references"
            },
            {
                'gl',
                function()
                    vim.diagnostic.open_float({ border = "rounded" })
                end,
                desc = "Show diagnostic"
            },
            {
                '[d',
                function()
                    vim.diagnostic.jump({ count = -1, float = true, border = "rounded" })
                end,
                desc = "Previous diagnostic"
            },
            {
                ']d',
                function()
                    vim.diagnostic.jump({ count = 1, float = true, border = "rounded" })
                end,
                desc = "Next diagnostic"
            },
            {
                "<leader>Lf",
                function() vim.lsp.buf.format({ async = false }) end,
                desc = "Format"
            },
            {
                "<leader>LF",
                function()
                    if vim.g.custom_enable_auto_format then
                        vim.g.custom_enable_auto_format = false
                        vim.notify("File autoformat is disabled", "info", { title = "LSP Autoformat" })
                    else
                        vim.g.custom_enable_auto_format = true
                        vim.notify("File autoformat is enabled", "info", { title = "LSP Autoformat" })
                    end
                end,
                desc = "Auto Format Toggle",
            },
            {
                "<leader>LK",
                function()
                    vim.lsp.buf.hover()
                end,
                desc = "Hover"
            },
            { "<leader>LH", "<cmd>LspInfo<cr>",   desc = "Info" },
            { "<leader>LL", vim.lsp.codelens.run, desc = "CodeLens Action" },
            {
                "<leader>Ln",
                vim.lsp.diagnostic.goto_next,
                desc = "Next Diagnostic",
            },
            {
                "<leader>Lp",
                vim.lsp.diagnostic.goto_prev,
                desc = "Prev Diagnostic",
            },
            {
                "<leader>LR",
                vim.lsp.buf.rename,
                desc = "Rename"
            },

            -- Language
            -- C/C++
            { "<leader>lct", "<cmd>edit .clang-tidy<cr>",   desc = "Clang Tidy", },
            { "<leader>lcf", "<cmd>edit .clang-format<cr>", desc = "Clang Format" },
        },
        dependencies = {
            "williamboman/mason-lspconfig.nvim",
        },
        lazy = false,
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
                "sqlfluff",

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
                "gopls"
            }
        },
        dependencies = {
            "williamboman/mason.nvim",
        },
    }, -- Install and upgrade third party tools automatically
    {
        "nvimtools/none-ls.nvim",
        config = function()
            local null_ls = require("null-ls")
            null_ls.setup({
                sources = {
                    null_ls.builtins.formatting.prettier,
                    null_ls.builtins.formatting.black,
                    null_ls.builtins.formatting.shfmt,

                    null_ls.builtins.diagnostics.sqlfluff,
                }
            })
        end,
        keys = {
            { "<leader>LN", "<cmd>NullLsInfo<cr>", desc = "Null-Ls Info" },
        },
        lazy = false,
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
        lazy = true,
        keys = {
            { "<leader>o", "<cmd>SymbolsOutline<cr>", desc = "Code OutLine" },
        }
    }, -- A tree like view for symbols
    { "andymass/vim-matchup",     lazy = true, keys = { "%" } },

    -- debugging
    { import = "plugins.lsp.dap" },
    { import = "plugins.lsp.lang" },
}
