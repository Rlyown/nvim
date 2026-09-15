-- The installer and runtime share this capability catalog.
return {
    languages = {
        cpp = { ft = { "c", "cpp", "cmake" }, servers = { "clangd", "cmake" }, tools = { "clangd", "cmake-language-server" }, parsers = { "c", "cpp", "cmake" }, system = { "cmake" }, format = "clangd", debug = { "codelldb" } },
        go = { ft = { "go", "gomod", "gowork", "gotmpl" }, servers = { "gopls" }, tools = { "gopls" }, parsers = { "go", "gomod", "gosum", "gowork", "gotmpl" }, system = { "go" }, format = "gopls", debug = { "delve" } },
        rust = { ft = { "rust" }, tools = { "rust-analyzer" }, parsers = { "rust", "toml" }, system = { "rust" }, format = "rust-analyzer", debug = { "codelldb" } },
        python = { ft = { "python" }, servers = { "pyright" }, tools = { "pyright", "black" }, parsers = { "python" }, system = { "python" }, format = "null-ls", formatter = "black", debug = { "debugpy" } },
        tex = { ft = { "tex", "bib" }, parsers = { "latex", "bibtex" }, system = { "latex" } },
        sql = { ft = { "sql" }, tools = { "sqlfluff" }, parsers = { "sql" }, formatter = "sqlfluff", format = "null-ls" },
        lua = { ft = { "lua" }, servers = { "lua_ls" }, tools = { "lua-language-server", "stylua" }, parsers = { "lua", "luadoc" }, formatter = "stylua", format = "null-ls" },
        shell = { ft = { "sh", "bash" }, servers = { "bashls" }, tools = { "bash-language-server", "shfmt" }, parsers = { "bash" }, formatter = "shfmt", format = "null-ls" },
        web = { ft = { "html", "css", "javascript", "typescript", "typescriptreact", "vue", "svelte" }, tools = { "prettier" }, parsers = { "html", "css", "javascript", "typescript", "tsx", "vue", "svelte" }, formatter = "prettier", format = "null-ls" },
        data = { ft = { "json", "yaml", "toml", "xml" }, servers = { "jsonls", "yamlls", "taplo", "lemminx" }, tools = { "json-lsp", "yaml-language-server", "taplo", "lemminx" }, parsers = { "json", "yaml", "toml", "xml" } },
        docker = { ft = { "dockerfile" }, servers = { "dockerls" }, tools = { "dockerfile-language-server" }, parsers = { "dockerfile" } },
        asm = { ft = { "asm" }, servers = { "asm_lsp" }, tools = { "asm-lsp" } },
        csv = { ft = { "csv" }, parsers = { "csv" } },
        markdown = { ft = { "markdown" }, servers = { "markdown_oxide" }, tools = { "markdown-oxide" }, parsers = { "markdown", "markdown_inline" } },
    },
    features = {
        editor = true, search = true, git = true, terminal = true, explorer = true,
        completion = true, ui = true, session = true, treesitter = true,
        dap = false, ai = false, copilot = false, remote = false, images = false,
        formulas = false, fonts = false, kitty = false,
    },
    base_parsers = { "vim", "vimdoc", "lua", "markdown", "markdown_inline", "query" },
}
