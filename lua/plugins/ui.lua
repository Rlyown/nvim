return {
    { "kwkarlwang/bufresize.nvim", event = "VeryLazy", config = function()
        require("bufresize").setup({})
        vim.api.nvim_create_autocmd("VimResized", { group = vim.api.nvim_create_augroup("ConfigResize", { clear = true }), callback = function() require("bufresize").resize() end })
    end },
    { "kevinhwang91/nvim-ufo", event = "BufReadPost", dependencies = { "kevinhwang91/promise-async" }, opts = { provider_selector = function() return { "treesitter", "indent" } end } },
    require("modules.groups").spec({ ["<leader>b"] = "缓冲区", ["<leader>W"] = "窗口", ["<leader>u"] = "显示与配置" }),
    { "folke/which-key.nvim", event = "VeryLazy", opts = { preset = "classic" } },
    { "nvim-lualine/lualine.nvim", event = "VeryLazy", dependencies = { "nvim-tree/nvim-web-devicons" }, opts = {
        options = { theme = "catppuccin", globalstatus = true },
        sections = { lualine_a = { "mode" }, lualine_b = { "branch", "diff", "diagnostics" }, lualine_c = { "filename" }, lualine_x = { "encoding", "filetype" }, lualine_y = { "progress" }, lualine_z = { "location" } },
    } },
    { "akinsho/bufferline.nvim", event = "VeryLazy", dependencies = { "nvim-tree/nvim-web-devicons" }, opts = {} },
    { "folke/noice.nvim", event = "VeryLazy", dependencies = { "MunifTanjim/nui.nvim" }, opts = { presets = { command_palette = true }, notify = { enabled = false } } },
    { "norcalli/nvim-colorizer.lua", event = "BufReadPost", opts = {} },
    { "andrewferrier/wrapping.nvim", opts = { create_keymaps = false, create_commands = false }, keys = {
        { "<leader>uw", function() require("wrapping").toggle_wrap_mode() end, desc = "切换折行" },
    } },
}
