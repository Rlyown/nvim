return {
    { "nvim-treesitter/nvim-treesitter", branch = "main", lazy = false,
        dependencies = { "MeanderingProgrammer/treesitter-modules.nvim" },
        config = function()
            require("treesitter-modules").setup({
                ensure_installed = {}, auto_install = false,
                highlight = { enable = true }, indent = { enable = true, disable = { "python", "yaml" } },
            })
        end,
    },
    { "Wansmer/treesj", dependencies = { "nvim-treesitter/nvim-treesitter" }, opts = { use_default_keymaps = false }, keys = {
        { "gJ", function() require("treesj").join() end, desc = "合并代码块" },
        { "gS", function() require("treesj").split() end, desc = "拆分代码块" },
    } },
    { "nvim-treesitter/nvim-treesitter-context", event = "BufReadPost", opts = { max_lines = 3 } },
}
