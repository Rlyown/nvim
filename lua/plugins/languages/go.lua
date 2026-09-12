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
            { "<localleader>r", "<cmd>GoRun<cr>", ft = "go", desc = "运行 Go" },
            { "<localleader>t", "<cmd>GoTest<cr>", ft = "go", desc = "测试 Go" },
            { "<localleader>b", "<cmd>GoBuild<cr>", ft = "go", desc = "构建 Go" },
            { "<localleader>ae", "<cmd>GoIfErr<cr>", ft = "go", desc = "添加错误处理" },
            { "<localleader>at", "<cmd>GoAddTag<cr>", ft = "go", desc = "添加标签" },
            { "<localleader>as", "<cmd>GoFillStruct<cr>", ft = "go", desc = "填充结构体" },
            { "<localleader>h", "<cmd>GoDoc<cr>", ft = "go", desc = "Go 帮助" },
        },
    },
}
