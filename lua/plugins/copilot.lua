return {
    { "zbirenbaum/copilot.lua", event = "InsertEnter", cmd = "Copilot", opts = {
        suggestion = { enabled = true, auto_trigger = true, keymap = {
            accept = "<M-l>", accept_word = false, accept_line = false,
            next = "<M-]>", prev = "<M-[>", dismiss = "<M-e>",
        } },
        panel = { enabled = false },
    } },
}
