return {
    { "folke/sidekick.nvim", opts = { nes = { enabled = false }, cli = { mux = { enabled = false } } }, keys = {
        { "<leader>aa", function() require("sidekick.cli").toggle() end, desc = "AI Terminal" },
        { "<leader>as", function() require("sidekick.cli").select() end, desc = "Select AI" },
        { "<leader>af", function() require("sidekick.cli").send({ msg = "{file}" }) end, desc = "Send File" },
        { "<leader>av", function() require("sidekick.cli").send({ msg = "{selection}" }) end, mode = "x", desc = "Send Selection" },
        { "<leader>ap", function() require("sidekick.cli").prompt() end, mode = { "n", "x" }, desc = "Select Prompt" },
    } },
}
