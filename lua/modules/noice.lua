return function()
    local custom_routes = {
        {
            view = "notify",
            filter = { event = "msg_showmode" },
        },
        {
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
                kind = "",
                find = "^<$",
            },
            opts = { skip = true },
        },
        {
            filter = {
                event = "msg_show",
                kind = "",
                find = "not a git repository",
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
            filter = {
                event = "msg_show",
                kind = "",
                find =
                "^Error running notification service: ...art/nvim-notify/lua/notify/service/buffer/highlights.lua:153: Invalid buffer id:",
            },
            opts = { skip = true },
        },
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
        views = {
            cmdline_popup = {
                position = {
                    row = 5,
                    col = "50%",
                },
                size = {
                    width = 60,
                    height = "auto",
                },
            },
            popupmenu = {
                relative = "editor",
                position = {
                    row = 8,
                    col = "50%",
                },
                size = {
                    width = 60,
                    height = 10,
                },
                border = {
                    style = "rounded",
                    padding = { 0, 1 },
                },
                win_options = {
                    winhighlight = { Normal = "Normal", FloatBorder = "DiagnosticInfo" },
                },
            },
        },
    })

    require("telescope").load_extension("noice")
end
