return {
    {
        "amitds1997/remote-nvim.nvim",
        -- "hmk114/remote-nvim.nvim",
        version = "*",                       -- Pin to GitHub releases
        dependencies = {
            "nvim-lua/plenary.nvim",         -- For standard functions
            "MunifTanjim/nui.nvim",          -- To build the plugin UI
            "nvim-telescope/telescope.nvim", -- For picking b/w different remote methods
        },
        opts = {
            offline_mode = {
                enabled = true,
                no_github = false,
            },
        },
        cmd = { "RemoteStart", "RemoteStop", "RemoteInfo" }
    }
}
