return {
    { "ray-x/go.nvim", ft = { "go", "gomod" }, dependencies = { "ray-x/guihua.lua", "neovim/nvim-lspconfig" },
        opts = {
            lsp_cfg = false,
            lsp_keymaps = false,
            gopls_remote_auto = false,
            dap_debug = false,
            dap_debug_keymap = false,
            dap_debug_gui = false,
            dap_debug_vt = false,
        },
        keys = {
            { "<leader>lr", "<cmd>GoRun<cr>", ft = "go", desc = "Run Go" },
            { "<leader>lt", "<cmd>GoTest<cr>", ft = "go", desc = "Test Go" },
            { "<leader>lb", "<cmd>GoBuild<cr>", ft = "go", desc = "Build Go" },
            { "<leader>lae", "<cmd>GoIfErr<cr>", ft = "go", desc = "Add Error Handling" },
            { "<leader>lat", "<cmd>GoAddTag<cr>", ft = "go", desc = "Add Tags" },
            { "<leader>las", "<cmd>GoFillStruct<cr>", ft = "go", desc = "Fill Struct" },
            { "<leader>lk", "<cmd>GoDoc<cr>", ft = "go", desc = "Go Help" },
        },
    },
}
