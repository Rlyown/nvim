local config = require("config")
local keys = {}
local function key(lhs, callback, desc, mode)
    table.insert(keys, { lhs, callback, desc = desc, mode = mode })
end
if config.enabled("search") then
    key("<leader>f", function()
        Snacks.picker.smart({
            layout = { preset = "dropdown", preview = false, layout = { height = 0.4 } },
        })
    end, "Smart Find")
    key("<leader>F", function() Snacks.picker.grep({ layout = { preset = "bottom" } }) end, "Find Text")
    key("<leader>sg", function() Snacks.picker.grep() end, "Search Project")
    key("<leader>sw", function() Snacks.picker.grep_word() end, "Search Word", { "n", "x" })
    key("<leader>sb", function() Snacks.picker.lines() end, "Search Buffer")
    key("<leader>sh", function() Snacks.picker.help() end, "Help")
    key("<leader>sk", function() Snacks.picker.keymaps() end, "Keymaps")
    key("<leader>su", function() Snacks.picker.undo() end, "Undo History")
    key("<leader>sd", function() Snacks.picker.diagnostics() end, "Diagnostics")
    key("<leader>sc", function() Snacks.picker.command_history() end, "Command History")
    key("<leader>b", function() Snacks.picker.buffers() end, "Buffers")
    key("<leader>ss", function() Snacks.picker.lsp_symbols() end, "Search Document Symbols")
end
if config.enabled("explorer") then
    key("<leader>n", function() Snacks.explorer() end, "Explorer")
end
if config.enabled("terminal") then
    for suffix, layout in pairs({ h = "horizontal", v = "vertical", f = "float", t = "tab" }) do
        key("<leader>t" .. suffix, function() require("modules.terminal").toggle(vim.v.count1, layout) end, "Terminal " .. layout)
    end
    key("<C-\\>", function() require("modules.terminal").toggle() end, "Toggle Terminal", { "n", "t" })
    key("<leader>ta", function() require("modules.terminal").toggle_all() end, "Toggle All Terminals")
    key("<leader>tc", function() require("modules.terminal").prompt_send("line") end, "Send Current Line")
    key("<leader>tl", function() require("modules.terminal").prompt_send("lines") end, "Send Selected Lines", "x")
    key("<leader>ts", function() require("modules.terminal").prompt_send("selection") end, "Send Selection", "x")
end
return {
    { "folke/snacks.nvim", lazy = false, keys = keys,
        init = function() if config.enabled("explorer") then require("modules.explorer").setup() end end,
        opts = {
        bigfile = { enabled = true }, quickfile = { enabled = true },
        input = { enabled = true }, notifier = { enabled = config.enabled("ui") },
        image = { enabled = config.enabled("images") },
        explorer = { enabled = config.enabled("explorer"), replace_netrw = true },
        picker = {
            enabled = config.enabled("search") or config.enabled("explorer"),
            sources = { explorer = {
                layout = { layout = { width = 0.2, min_width = 0 } },
                on_show = function(p) require("modules.explorer").on_show(p) end,
                on_close = function(p) require("modules.explorer").on_close(p) end,
                actions = {
                    config_cut = function(p) require("modules.explorer").cut(p) end,
                    config_paste = function(p) require("modules.explorer").paste(p) end,
                    config_trash = function(p) require("modules.explorer").delete(p, false) end,
                    config_delete = function(p) require("modules.explorer").delete(p, true) end,
                },
                win = { list = { keys = { d = "config_trash", D = "config_delete", ["<C-t>"] = "tab", ["<C-x>"] = "split", ["<C-v>"] = "vsplit", x = "config_cut", p = "config_paste" } } },
            } },
        },
    } },
    { "MagicDuck/grug-far.nvim", enabled = config.enabled("search"), opts = {}, keys = {
        { "<leader>sr", "<cmd>GrugFar<cr>", desc = "Search and Replace" },
    } },
}
