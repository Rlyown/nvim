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
            { "<localleader>r", "<cmd>GoRun<cr>", ft = "go", desc = "Run Go" },
            { "<localleader>t", "<cmd>GoTest<cr>", ft = "go", desc = "Test Go" },
            { "<localleader>b", "<cmd>GoBuild<cr>", ft = "go", desc = "Build Go" },
            { "<localleader>ae", "<cmd>GoIfErr<cr>", ft = "go", desc = "Add Error Handling" },
            { "<localleader>at", "<cmd>GoAddTag<cr>", ft = "go", desc = "Add Tags" },
            { "<localleader>as", "<cmd>GoFillStruct<cr>", ft = "go", desc = "Fill Struct" },
            { "<localleader>h", "<cmd>GoDoc<cr>", ft = "go", desc = "Go Help" },
        },
    },
}
