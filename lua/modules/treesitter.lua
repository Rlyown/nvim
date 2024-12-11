return function()
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
