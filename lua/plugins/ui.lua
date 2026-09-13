local config = require("config")
local groups = {
    { "<leader>b", group = "Buffers" },
    { "<leader>x", group = "Windows" },
    { "<leader>u", group = "UI and Config" },
}
local function add(enabled, lhs, label)
    if enabled then table.insert(groups, { lhs, group = label }) end
end
add(config.enabled("ai"), "<leader>a", "AI")
add(config.enabled("dap"), "<leader>d", "Debug")
add(config.enabled("git"), "<leader>g", "Git")
add(config.enabled("session"), "<leader>p", "Sessions")
add(config.enabled("search"), "<leader>s", "Search")
add(config.enabled("terminal"), "<leader>t", "Terminal")
for _, enabled in pairs(config.get().languages) do
    if enabled then
        add(true, "<leader>c", "Language")
        break
    end
end

return {
    { "kwkarlwang/bufresize.nvim", event = "VeryLazy", config = function()
        require("bufresize").setup({})
        vim.api.nvim_create_autocmd("VimResized", { group = vim.api.nvim_create_augroup("ConfigResize", { clear = true }), callback = function() require("bufresize").resize() end })
    end },
    { "kevinhwang91/nvim-ufo", event = "BufReadPost", dependencies = { "kevinhwang91/promise-async" }, opts = { provider_selector = function() return { "treesitter", "indent" } end } },
    { "folke/which-key.nvim", event = "VeryLazy", opts = { preset = "classic", spec = groups } },
    { "nvim-lualine/lualine.nvim", event = "VeryLazy", dependencies = { "nvim-tree/nvim-web-devicons" }, opts = {
        options = { theme = "catppuccin", globalstatus = true },
        sections = { lualine_a = { "mode" }, lualine_b = { "branch", "diff", "diagnostics" }, lualine_c = { "filename" }, lualine_x = { "encoding", "filetype" }, lualine_y = { "progress" }, lualine_z = { "location" } },
    } },
    { "akinsho/bufferline.nvim", event = "VeryLazy", dependencies = { "nvim-tree/nvim-web-devicons" }, opts = {} },
    { "folke/noice.nvim", event = "VeryLazy", dependencies = { "MunifTanjim/nui.nvim" }, opts = { presets = { command_palette = true }, notify = { enabled = false } } },
    { "norcalli/nvim-colorizer.lua", event = "BufReadPost", opts = {} },
    { "andrewferrier/wrapping.nvim", opts = { create_keymaps = false, create_commands = false }, keys = {
        { "<leader>uw", function() require("wrapping").toggle_wrap_mode() end, desc = "Toggle Wrap" },
    } },
}
