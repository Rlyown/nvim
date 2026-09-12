return {
    {
        "catppuccin/nvim",
        name = "catppuccin",
        lazy = false,
        opts = { flavour = "mocha", integrations = { snacks = true, which_key = true } },
        config = function(_, opts)
            require("catppuccin").setup(opts)
            vim.cmd.colorscheme("catppuccin")
        end,
    },
}
