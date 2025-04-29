return {
    {
        "nvim-treesitter/nvim-treesitter",
        build = ":TSUpdate",
        config = function()
            local configs = require("nvim-treesitter.configs")
            local disable_func = require("core.gfunc").fn.disable_check_buf

            require('nvim-dap-repl-highlights').setup()

            configs.setup({
                ensure_installed = {
                    "bash",
                    "bibtex",
                    "c",
                    "cmake",
                    "comment",
                    "cpp",
                    "csv",
                    -- "cuda",
                    'dap_repl',
                    "diff",
                    "dockerfile",
                    "dot",
                    "doxygen",
                    "git_config",
                    "git_rebase",
                    "gitattributes",
                    "gitcommit",
                    "gitignore",
                    "go",
                    "gomod",
                    "gosum",
                    "gowork",
                    "gotmpl",
                    "json",
                    "json5",
                    "jsonc",
                    "kconfig",
                    "latex",
                    "llvm",
                    "lua",
                    "luadoc",
                    "luap",
                    "make",
                    "markdown",
                    "meson",
                    "ninja",
                    "norg",
                    "python",
                    "regex",
                    "requirements",
                    "regex",
                    "rust",
                    "strace",
                    "sql",
                    "toml",
                    "vim",
                    "vimdoc",
                    "verilog",
                    "xml",
                    "yaml",
                },                                      -- one of "all", or a list of languages
                sync_install = false,                   -- install languages synchronously (only applied to `ensure_installed`)
                ignore_install = { "swift", "phpdoc" }, -- List of parsers to ignore installing
                highlight = {
                    enable = true,                      -- false will disable the whole extension
                    disable = function(lang, buf)
                        if disable_func(buf) then
                            return true
                        end
                        return false
                    end,
                    additional_vim_regex_highlighting = true,
                },
                indent = {
                    enable = true,
                    disable = function(lang, buf)
                        if lang == "python" then
                            return true
                        elseif lang == "yaml" then
                            return true
                        else
                            return disable_func(buf)
                        end
                    end
                },
                matchup = {
                    enable = true, -- mandatory, false will disable the whole extension
                    --[[ disable = { "c", "ruby" }, -- optional, list of language that will be disabled ]]
                    disable = function(lang, buf)
                        if disable_func(buf) then
                            return true
                        end
                        return false
                    end,
                },
            })
        end
    }, -- Nvim Treesitter configurations and abstraction layer
    {
        "Wansmer/treesj",
        dependencies = {
            "nvim-treesitter/nvim-treesitter",
        },
        config = function()
            require('treesj').setup({ --[[ your config ]] })
        end,
        keys = {
            { 'J',  function() require('treesj').join() end,  desc = "Join" },
            { 'gS', function() require('treesj').split() end, desc = "Split" },
        },
    },
    {
        "romgrk/nvim-treesitter-context",
        opts = {

            enable = true,   -- Enable this plugin (Can be enabled/disabled later via commands)
            throttle = true, -- Throttles plugin updates (may improve performance)
            max_lines = 0,   -- How many lines the window should span. Values <= 0 mean no limit.
            patterns = {     -- Match patterns for TS nodes. These get wrapped to match at word boundaries.
                -- For all filetypes
                -- Note that setting an entry here replaces all other patterns for this entry.
                -- By setting the 'default' entry below, you can control which nodes you want to
                -- appear in the context window.
                default = {
                    "class",
                    "function",
                    "method",
                    -- 'for', -- These won't appear in the context
                    -- 'while',
                    -- 'if',
                    -- 'switch',
                    -- 'case',
                },
                -- Example for a specific filetype.
                -- If a pattern is missing, *open a PR* so everyone can benefit.
                --   rust = {
                --       'impl_item',
                --   },
            },
            exact_patterns = {
                -- Example for a specific filetype with Lua patterns
                -- Treat patterns.rust as a Lua pattern (i.e "^impl_item$" will
                -- exactly match "impl_item" only)
                -- rust = true,
            },
        },
    }, -- SHOW CODE CONTEXT
}
