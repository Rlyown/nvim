local config = require("config")
local groups = {
    { "<leader>u", group = "UI" },
    { "<leader>x", group = "Other and Maintenance", icon = { icon = "󰒓 ", color = "orange" } },
}
local function add(enabled, lhs, label, icon)
    if enabled then table.insert(groups, { lhs, group = label, icon = icon }) end
end
add(config.enabled("ai"), "<leader>a", "AI")
add(config.enabled("dap"), "<leader>d", "Debug")
add(config.enabled("git"), "<leader>g", "Git")
add(config.enabled("session"), "<leader>p", "Sessions")
add(config.enabled("search"), "<leader>s", "Search")
add(config.enabled("terminal"), "<leader>t", "Terminal")
local language_enabled = config.enabled("treesitter")
for _, enabled in pairs(config.get().languages) do
    language_enabled = language_enabled or enabled
end
add(language_enabled, "<leader>l", "Language", { icon = "󰌌 ", color = "cyan" })
add(language_enabled, "<leader>la", "Language Actions")

return {
    { "kwkarlwang/bufresize.nvim", event = "VeryLazy", config = function()
        require("bufresize").setup({})
        vim.api.nvim_create_autocmd("VimResized", { group = vim.api.nvim_create_augroup("ConfigResize", { clear = true }), callback = function() require("bufresize").resize() end })
    end },
    { "kevinhwang91/nvim-ufo", event = "BufReadPost", dependencies = { "kevinhwang91/promise-async" },
        init = function()
            -- UFO preserves manually closed folds; a low foldlevel closes open folds on refresh.
            vim.o.foldlevel = 99
            vim.o.foldlevelstart = 99
        end,
        opts = {
            provider_selector = function(_, ft)
                return { ft == "markdown" and require("modules.folds").markdown or "treesitter", "indent" }
            end,
            close_fold_kinds_for_ft = { markdown = { "section" } },
        },
        keys = {
            { "zR", function() require("ufo").openAllFolds() end, desc = "Open All Folds" },
            { "zM", function() require("ufo").closeAllFolds() end, desc = "Close All Folds" },
        },
    },
    {
        "folke/which-key.nvim",
        event = "VeryLazy",
        opts = {
            preset = "classic",
            spec = groups,
            icons = {
                rules = {
                    { pattern = "^save$", icon = " ", color = "azure" },
                    { pattern = "reload", icon = " ", color = "cyan" },
                    { pattern = "jump to characters", icon = "󰆋 ", color = "green" },
                    { pattern = "symbol outline", icon = "󰙅 ", color = "purple" },
                    { pattern = "go to definition", icon = "󰈮 ", color = "blue" },
                    { pattern = "open link", icon = "󰌷 ", color = "azure" },
                    { pattern = "fold", icon = "󰐕 ", color = "purple" },
                    { pattern = "escape", icon = "󱊷 ", color = "red" },
                },
            },
        },
    },
    { "nvim-lualine/lualine.nvim", event = "VeryLazy", dependencies = { "nvim-tree/nvim-web-devicons" }, opts = {
        options = { theme = "catppuccin-mocha", globalstatus = true },
        sections = { lualine_a = { "mode" }, lualine_b = { "branch", "diff", "diagnostics" }, lualine_c = { "filename" }, lualine_x = { "encoding", "filetype" }, lualine_y = { "progress" }, lualine_z = { "location" } },
    } },
    { "akinsho/bufferline.nvim", event = "VeryLazy", dependencies = { "nvim-tree/nvim-web-devicons" }, opts = {} },
    { "folke/noice.nvim", event = "VeryLazy", dependencies = { "MunifTanjim/nui.nvim" }, opts = { presets = { command_palette = true }, notify = { enabled = false } } },
    { "norcalli/nvim-colorizer.lua", event = "BufReadPost", opts = {} },
    { "andrewferrier/wrapping.nvim", opts = { create_keymaps = false, create_commands = false }, keys = {
        { "<leader>uw", function() require("wrapping").toggle_wrap_mode() end, desc = "Toggle Wrap" },
    } },
}
