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
        { "<leader>lj", function() require("treesj").join() end, desc = "Join Code Structure" },
        { "<leader>ls", function() require("treesj").split() end, desc = "Split Code Structure" },
    } },
    { "nvim-treesitter/nvim-treesitter-context", event = "BufReadPost", opts = { max_lines = 3 } },
}
