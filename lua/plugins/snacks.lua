local config = require("config")
local keys = {}
local function key(lhs, callback, desc, mode)
    table.insert(keys, { lhs, callback, desc = desc, mode = mode })
end
if config.enabled("search") then
    key("<leader>ff", function() Snacks.picker.files() end, "查找文件")
    key("<leader>fo", function() Snacks.picker.recent() end, "最近文件")
    key("<leader>sg", function() Snacks.picker.grep() end, "搜索项目")
    key("<leader>sw", function() Snacks.picker.grep_word() end, "搜索光标词", { "n", "x" })
    key("<leader>sb", function() Snacks.picker.lines() end, "搜索当前文件")
    key("<leader>sh", function() Snacks.picker.help() end, "帮助")
    key("<leader>sk", function() Snacks.picker.keymaps() end, "快捷键")
    key("<leader>su", function() Snacks.picker.undo() end, "撤销历史")
    key("<leader>sd", function() Snacks.picker.diagnostics() end, "诊断")
    key("<leader>sc", function() Snacks.picker.command_history() end, "命令历史")
    key("<leader>bb", function() Snacks.picker.buffers() end, "选择缓冲区")
end
if config.enabled("explorer") then
    key("<leader>fe", function() Snacks.explorer() end, "文件树及当前文件定位")
end
if config.enabled("terminal") then
    for suffix, layout in pairs({ h = "horizontal", v = "vertical", f = "float", t = "tab" }) do
        key("<leader>t" .. suffix, function() require("modules.terminal").toggle(vim.v.count1, layout) end, "终端 " .. layout)
    end
    key("<C-\\>", function() require("modules.terminal").toggle() end, "切换终端", { "n", "t" })
    key("<leader>ta", function() require("modules.terminal").toggle_all() end, "切换全部终端")
    key("<leader>tc", function() require("modules.terminal").prompt_send("line") end, "发送当前行")
    key("<leader>tl", function() require("modules.terminal").prompt_send("lines") end, "发送选中整行", "x")
    key("<leader>ts", function() require("modules.terminal").prompt_send("selection") end, "发送精确选区", "x")
end
return {
    require("modules.groups").spec(vim.tbl_extend("force", config.enabled("search") and { ["<leader>s"] = "搜索" } or {}, config.enabled("terminal") and { ["<leader>t"] = "终端" } or {})),
    { "folke/snacks.nvim", lazy = false, keys = keys, opts = {
        bigfile = { enabled = true }, quickfile = { enabled = true },
        input = { enabled = true }, notifier = { enabled = config.enabled("ui") },
        image = { enabled = config.enabled("images") },
        explorer = { enabled = config.enabled("explorer"), replace_netrw = true },
        picker = {
            enabled = config.enabled("search") or config.enabled("explorer"),
            sources = { explorer = {
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
        { "<leader>sr", "<cmd>GrugFar<cr>", desc = "搜索替换" },
    } },
}
