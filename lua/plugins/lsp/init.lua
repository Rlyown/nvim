return {
    { "hedyhli/outline.nvim", cmd = "Outline", opts = {}, keys = { { "<leader>co", "<cmd>Outline<cr>", desc = "Symbol Outline" } } },
    { "neovim/nvim-lspconfig", keys = require("modules.run").keys(), event = { "BufReadPre", "BufNewFile" }, config = function()
        require("modules.lsp").setup()
        local mason = vim.fn.stdpath("data") .. "/mason/bin"
        vim.env.PATH = mason .. ":" .. vim.env.PATH
        for _, name in ipairs(require("config").plan().servers) do
            if name == "lua_ls" then vim.lsp.config(name, { settings = { Lua = { diagnostics = { globals = { "vim" } } } } }) end
            if name == "jsonls" then vim.lsp.config(name, { settings = { json = { schemas = {}, validate = { enable = true } } } }) end
            if require("config").get().offline then
                if name == "jsonls" then vim.lsp.config(name, { settings = { json = { schemaDownload = { enable = false } } } }) end
                if name == "yamlls" then vim.lsp.config(name, { settings = { yaml = { schemaStore = { enable = false, url = "" } } } }) end
            end
            vim.lsp.enable(name)
        end
    end },
    { "nvimtools/none-ls.nvim", event = { "BufReadPre", "BufNewFile" }, dependencies = { "nvim-lua/plenary.nvim" }, config = function()
        local n = require("null-ls")
        local sources = {}
        for name, enabled in pairs(require("config").get().languages) do
            local pack = require("config.capabilities").languages[name]
            if enabled and pack.formatter then
                local source = n.builtins.formatting[pack.formatter]
                assert(source, "Missing formatter source: " .. pack.formatter)
                table.insert(sources, source.with({ filetypes = pack.ft }))
            end
        end
        n.setup({ sources = sources })
    end },
}
