return {
    {
        "nvim-neorg/neorg",
        lazy = true, -- Disable lazy loading as some `lazy.nvim` distributions set `lazy = true` by default
        ft = "norg",
        cmd = "Neorg",
        version = "*", -- Pin Neorg to the latest stable release
        enabled = false,
        opts = {
            load = {
                ["core.defaults"] = {},
                ["core.keybinds"] = {
                    config = {
                        default_keybinds = true,
                        neorg_leader = "<Leader>N",
                        hook = function(keybinds)
                            local leader = keybinds.leader
                            -- Marks the task under the cursor as "undone"
                            keybinds.remap_key("norg", "n", "gtu", leader .. "gu")

                            -- Marks the task under the cursor as "pending"
                            keybinds.remap_key("norg", "n", "gtp", leader .. "gp")

                            -- Marks the task under the cursor as "done"
                            keybinds.remap_key("norg", "n", "gtd", leader .. "gd")

                            -- Marks the task under the cursor as "on_hold"
                            keybinds.remap_key("norg", "n", "gth", leader .. "gh")

                            -- Marks the task under the cursor as "cancelled"
                            keybinds.remap_key("norg", "n", "gtc", leader .. "gc")

                            -- Marks the task under the cursor as "recurring"
                            keybinds.remap_key("norg", "n", "gtr", leader .. "gr")

                            -- Marks the task under the cursor as "important"
                            keybinds.remap_key("norg", "n", "gti", leader .. "gi")

                            -- Switches the task under the cursor between a select few states
                            keybinds.remap_key("norg", "n", "<C-Space>", leader .. "gn")
                        end,
                    },
                },
                ["core.dirman"] = {
                    config = {
                        workspaces = {
                            work = require("core.gvariable").neorg_dir .. "/work",
                        },
                        index = "index.norg", -- The name of the main (root) .norg file
                    },
                },
                ["core.completion"] = {
                    config = { -- Note that this table is optional and doesn't need to be provided
                        -- Configuration here
                        engine = "nvim-cmp",
                    },
                },
                ["core.concealer"] = {},
                ["core.presenter"] = {
                    config = { -- Note that this table is optional and doesn't need to be provided
                        -- Configuration here
                        zen_mode = "truezen",
                    },
                },
                ["core.export"] = {
                    config = { -- Note that this table is optional and doesn't need to be provided
                        -- Configuration here
                    },
                },
                ["core.integrations.telescope"] = {},
            },
        }
    },
    { "nvim-neorg/neorg-telescope", dependencies = { "neorg", "telescope" }, lazy = true },
}
