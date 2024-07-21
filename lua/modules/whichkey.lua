return function()
    local which_key = require("which-key")

    local setup = {
        preset = "classic",
        plugins = {
            presets = {
                operators = false,   -- adds help for operators like d, y, ... and registers them for motion / text object completion
                motions = true,      -- adds help for motions
                text_objects = true, -- help for text objects triggered after entering an operator
                windows = true,      -- default bindings on <c-w>
                nav = true,          -- misc bindings to work with windows
                z = true,            -- bindings for folds, spelling and others prefixed with z
                g = true,            -- bindings for prefixed with g
            },
        },
        -- sort = { "local", "order", "group", "alphanum", "mod" },
        icons = { mappings = false, },
        show_help = true, -- show help message on the command line when the popup is visible
        disable = {
            ft = { "TelescopePrompt", "spectre_panel" },
        },
    }
    which_key.setup(setup)

    local wk_maps = require("modules.which-key-maps")

    for _, value in pairs(wk_maps) do
        which_key.add(value)
    end
end
