return {
    require("modules.groups").spec({ ["<leader>a"] = "AI" }),
    { "folke/sidekick.nvim", opts = { nes = { enabled = false }, cli = { mux = { enabled = false } } }, keys = {
        { "<leader>aa", function() require("sidekick.cli").toggle() end, desc = "AI 终端" },
        { "<leader>as", function() require("sidekick.cli").select() end, desc = "选择 AI" },
        { "<leader>af", function() require("sidekick.cli").send({ msg = "{file}" }) end, desc = "发送文件" },
        { "<leader>av", function() require("sidekick.cli").send({ msg = "{selection}" }) end, mode = "x", desc = "发送选区" },
        { "<leader>ap", function() require("sidekick.cli").prompt() end, mode = { "n", "x" }, desc = "选择提示词" },
    } },
}
