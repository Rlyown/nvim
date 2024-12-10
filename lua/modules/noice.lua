return function()
    local custom_routes = {
        {
            view = "notify",
            filter = { event = "msg_showmode" },
        },
        {
            -- Avoid written messages
            filter = {
                event = "msg_show",
                kind = "",
                find = "written",
            },
            opts = { skip = true },
        },
        {
            filter = {
                event = "msg_show",
                kind = "confirm_sub",
            },
            view = "cmdline",
        },
        {
            -- skil all
            filter = {
                event = "msg_show",
                kind = "",
            },
            opts = { skip = true },
        }
    }

    require("noice").setup({
        cmdline = {
            view = "cmdline_popup", -- view for rendering the cmdline. Change to `cmdline` to get a classic cmdline at the bottom
        },
        popupmenu = {
            enabled = true, -- enables the Noice popupmenu UI
            backend = "cmp",
        },
        lsp = {
            hover = {
                enabled = true,
            },
            signature = {
                enabled = false,
            },
        },
        ---@type NoicePresets
        presets = {
            bottom_search = false, -- use a classic bottom cmdline for search
            command_palette = true,
        },
        routes = custom_routes, --- @see section on routes
    })

    require("telescope").load_extension("noice")
end
