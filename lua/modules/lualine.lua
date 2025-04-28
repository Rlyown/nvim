return function()
    local lualine = require("lualine")
    local ainput = require("core.gfunc").fn.async_ui_input_wrap()

    local colors = {
        bg       = '#202328',
        fg       = '#bbc2cf',
        yellow   = '#ECBE7B',
        cyan     = '#008080',
        darkblue = '#081633',
        green    = '#98be65',
        orange   = '#FF8800',
        violet   = '#a9a1e1',
        magenta  = '#c678dd',
        blue     = '#51afef',
        red      = '#ec5f67',
    }

    local conditions = {
        buffer_not_empty = function()
            return vim.fn.empty(vim.fn.expand('%:t')) ~= 1
        end,
        hide_in_width = function()
            return vim.fn.winwidth(0) > 80
        end,
        check_git_workspace = function()
            local filepath = vim.fn.expand('%:p:h')
            local gitdir = vim.fn.finddir('.git', filepath .. ';')
            return gitdir and #gitdir > 0 and #gitdir < #filepath
        end,
    }


    local diagnostics = {
        "diagnostics",
        sources = { "nvim_diagnostic" },
        sections = { "error", "warn" },
        symbols = { error = " ", warn = " ", info = ' ' },
        colored = false,
        -- diagnostics_color = {
        --     error = { fg = colors.magenta },
        --     warn = { fg = colors.orange },
        --     info = { fg = colors.cyan },
        -- },
        update_in_insert = false,
        always_visible = true,
    }

    local diff = {
        "diff",
        symbols = { added = " ", modified = " ", removed = " " }, -- changes diff symbols
        diff_color = {
            added = { fg = colors.green },
            modified = { fg = colors.orange },
            removed = { fg = colors.red },
        },
        cond = conditions.hide_in_width,
    }

    local mode = {
        "mode",
        fmt = function(str)
            return "-- " .. str .. " --"
        end,
    }

    local filename = {
        "filename",
        file_status = true, -- Displays file status (readonly status, modified status)
        path = 0,           -- 0: Just the filename
        -- 1: Relative path
        -- 2: Absolute path

        shorting_target = 30, -- Shortens path to leave 40 spaces in the window
        -- for other components. (terrible name, any suggestions?)
        symbols = {
            modified = "", -- Text to show when the file is modified.
            readonly = " ", -- Text to show when the file is non-modifiable or readonly.
            unnamed = "[No Name]", -- Text to show for unnamed buffers.
        },
        cond = conditions.buffer_not_empty,
        color = { fg = colors.magenta, gui = 'bold' },
    }

    local filetype = {
        "filetype",
        colored = true,    -- Displays filetype icon in color if set to true
        icon_only = false, -- Display only an icon for filetype
        color = { fg = colors.green, gui = 'bold' },
        on_click = function()
            local opts = {
                prompt = "Enter the new filetype:",
                kind = "center",
            }

            local on_confirm = function(input)
                if input == "" then
                    return
                end
                vim.bo.ft = input
            end

            ainput(opts, on_confirm)
        end,
    }

    local branch = {
        "branch",
        icons_enabled = true,
        icon = "",
    }

    local location = {
        "location",
        padding = 0,
    }

    local encoding = {
        "encoding",
        cond = conditions.hide_in_width,
        color = { fg = colors.green, gui = 'bold' },
        on_click = function()
            local opts = {
                prompt = "Enter the new encoding name:",
                kind = "center",
            }

            local on_confirm = function(input)
                if input == "" then
                    return
                end
                vim.bo.fileencoding = input
            end

            ainput(opts, on_confirm)
        end,
    }

    -- cool function for progress
    local progress = function()
        local current_line = vim.fn.line(".")
        local total_lines = vim.fn.line("$")
        local chars = { "__", "▁▁", "▂▂", "▃▃", "▄▄", "▅▅", "▆▆", "▇▇", "██" }
        local line_ratio = current_line / total_lines
        local index = math.ceil(line_ratio * #chars)
        return chars[index]
    end

    local spaces = {
        function()
            return "spaces: " .. vim.api.nvim_get_option_value("shiftwidth", { buf = 0 })
        end,
        color = { fg = colors.green, gui = 'bold' },
        on_click = function()
            local opts = {
                prompt = "Enter the new value of shift width:",
                kind = "center",
            }
            local function on_confirm(input)
                if input == "" then
                    return
                end
                vim.bo.shiftwidth = tonumber(input)
            end

            ainput(opts, on_confirm)
        end,
    }

    local navic = {
        function()
            local disable_func = require("core.gfunc").fn.disable_check_buf

            local navic_plug = require("nvim-navic")
            if (not disable_func(0)) and navic_plug.is_available() then
                return navic_plug.get_location()
            else
                return ""
            end
        end,
        color = { fg = colors.violet, gui = 'bold' },
        cond = conditions.hide_in_width
    }



    lualine.setup({
        options = {
            theme = "catppuccin",
            component_separators = { left = "", right = "" },
            section_separators = { left = "", right = "" },
            disabled_filetypes = {
                "alpha",
                -- "dashboard",
                -- "NvimTree",
                -- "Outline",
                -- "dapui_scopes",
                -- "dapui_breakpoints",
                -- "dapui_stacks",
                -- "dapui_watches",
                -- "dap-repl",
                -- "startuptime",
                -- "TelescopePrompt",
            },
            always_divide_middle = true,
            globalstatus = true,
        },
        sections = {
            lualine_a = { branch, diagnostics },
            lualine_b = { mode },
            lualine_c = { navic },
            -- lualine_x = { "encoding", "fileformat", "filetype" },
            lualine_x = { diff, spaces, encoding, filetype, filename, { require('mcphub.extensions.lualine') } },
            lualine_y = { location },
            lualine_z = { progress },
        },
        inactive_sections = {
            lualine_a = {},
            lualine_b = {},
            lualine_c = { "filename" },
            lualine_x = { "location" },
            lualine_y = {},
            lualine_z = {},
        },
        tabline = {},
        winbar = {
            lualine_a = {},
            lualine_b = {},
            lualine_c = {},
            lualine_x = {},
            lualine_y = {},
            lualine_z = {},
        },
        inactive_winbar = {
            lualine_a = {},
            lualine_b = {},
            lualine_c = {},
            lualine_x = {},
            lualine_y = {},
            lualine_z = {},
        },
        extensions = { "toggleterm" },
    })
end
