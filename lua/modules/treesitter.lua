return function()
    local configs = require("nvim-treesitter.configs")

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
        },
        highlight = {
            enable = true,    -- false will disable the whole extension
            disable = { "" }, -- list of language that will be disabled
            additional_vim_regex_highlighting = true,
        },
        indent = { enable = true, disable = { "python", "yaml" } },
        context_commentstring = {
            enable = true,
            enable_autocmd = false,
        },
        matchup = {
            enable = true, -- mandatory, false will disable the whole extension
            --[[ disable = { "c", "ruby" }, -- optional, list of language that will be disabled ]]
            -- [options]
        },
    })
end
