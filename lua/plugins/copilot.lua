return {
    { "zbirenbaum/copilot.lua", event = "InsertEnter", cmd = "Copilot", opts = {
        suggestion = { enabled = true, auto_trigger = true, keymap = { accept = "<M-l>" } },
        panel = { enabled = false },
    } },
}
