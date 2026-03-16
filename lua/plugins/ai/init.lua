return {
    -- TODO: support sidekick.nvim
    {
        "folke/sidekick.nvim",
        opts = {
            -- add any options here
            cli = {
                mux = {
                    backend = "tmux",
                    enabled = true,
                },
            },
        },
        keys = {
            -- {
            --     "<tab>",
            --     function()
            --         -- if there is a next edit, jump to it, otherwise apply it if any
            --         if not require("sidekick").nes_jump_or_apply() then
            --             return "<Tab>" -- fallback to normal tab
            --         end
            --     end,
            --     expr = true,
            --     desc = "Goto/Apply Next Edit Suggestion",
            -- },
            {
                "<c-.>",
                function() require("sidekick.cli").toggle() end,
                desc = "Sidekick Toggle",
                mode = { "n", "t", "i", "x" },
            },
            {
                "<leader>aa",
                function() require("sidekick.cli").toggle() end,
                desc = "Sidekick Toggle CLI",
            },
            {
                "<leader>as",
                function() require("sidekick.cli").select() end,
                -- Or to select only installed tools:
                -- require("sidekick.cli").select({ filter = { installed = true } })
                desc = "Select CLI",
            },
            {
                "<leader>ad",
                function() require("sidekick.cli").close() end,
                desc = "Detach a CLI Session",
            },
            {
                "<leader>at",
                function() require("sidekick.cli").send({ msg = "{this}" }) end,
                mode = { "x", "n" },
                desc = "Send This",
            },
            {
                "<leader>af",
                function() require("sidekick.cli").send({ msg = "{file}" }) end,
                desc = "Send File",
            },
            {
                "<leader>av",
                function() require("sidekick.cli").send({ msg = "{selection}" }) end,
                mode = { "x" },
                desc = "Send Visual Selection",
            },
            {
                "<leader>ap",
                function() require("sidekick.cli").prompt() end,
                mode = { "n", "x" },
                desc = "Sidekick Select Prompt",
            },
            -- Example of a keybinding to open Claude directly
            {
                "<leader>ac",
                function() require("sidekick.cli").toggle({ name = "codex", focus = true }) end,
                desc = "Sidekick Toggle Codex",
            },
        },
    },
    {
        "NickvanDyke/opencode.nvim",
        version = "*",
        dependencies = {
            {
                "folke/snacks.nvim",
                optional = true,
                opts = function(_, opts)
                    opts.input = opts.input or {}
                    opts.picker = opts.picker or {}
                    opts.picker.actions = opts.picker.actions or {}
                    opts.picker.actions.opencode_send = function(...)
                        return require("opencode").snacks_picker_send(...)
                    end
                    opts.picker.win = opts.picker.win or {}
                    opts.picker.win.input = opts.picker.win.input or {}
                    opts.picker.win.input.keys = opts.picker.win.input.keys or {}
                    opts.picker.win.input.keys["<a-a>"] = { "opencode_send", mode = { "n", "i" } }
                end,
            },
        },
        keys = {
            {
                "<leader>ae",
                function() require("opencode").ask("@this: ", { submit = true }) end,
                mode = { "n", "x" },
                desc = "Opencode Ask",
            },
            {
                "<leader>ax",
                function() require("opencode").select() end,
                mode = { "n", "x" },
                desc = "Opencode Select",
            },
            {
                "<leader>ao",
                function() require("opencode").toggle() end,
                mode = { "n", "t" },
                desc = "Opencode Toggle",
            },
        },
    },
}
