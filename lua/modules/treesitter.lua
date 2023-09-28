return function()
    local configs = require("nvim-treesitter.configs")
    local disable_func = require("core.gfunc").fn.diable_check_buf


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
            "toml",
            "vim",
            "vimdoc",
            "verilog",
            "xml",
            "yaml",
        },                                      -- one of "all", or a list of languages
        sync_install = false,                   -- install languages synchronously (only applied to `ensure_installed`)
        ignore_install = { "swift", "phpdoc" }, -- List of parsers to ignore installing
        autopairs = {
            enable = true,
            disable = function(lang, buf)
                if disable_func("nvim-treesitter", "autopairs", buf) then
                    return true
                end
                return false
            end
        },
        highlight = {
            enable = true, -- false will disable the whole extension
            disable = function(lang, buf)
                if disable_func("nvim-treesitter", "highlight", buf) then
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
                    return disable_func("nvim-treesitter", "indent", buf)
                end
            end
        },
        context_commentstring = {
            enable = true,
            enable_autocmd = false,
            disable = function(lang, buf)
                if disable_func("nvim-treesitter", "context_commentstring", buf) then
                    return true
                end
                return false
            end,
        },
        matchup = {
            enable = true, -- mandatory, false will disable the whole extension
            --[[ disable = { "c", "ruby" }, -- optional, list of language that will be disabled ]]
            disable = function(lang, buf)
                if disable_func("nvim-treesitter", "matchup", buf) then
                    return true
                end
                return false
            end,
        },
    })
end
