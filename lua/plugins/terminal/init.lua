return {
    {
        "akinsho/toggleterm.nvim",
        opts = {
            size = 20,
            open_mapping = [[<c-\>]],
            hide_numbers = true,
            shade_filetypes = {},
            shade_terminals = true,
            shading_factor = 2,
            start_in_insert = true,
            insert_mappings = true,
            persist_size = true,
            direction = "horizontal",
            close_on_exit = true,
            shell = vim.o.shell,
            float_opts = {
                border = "curved",
                winblend = 0,
                highlights = {
                    border = "Normal",
                    background = "Normal",
                },
            },
        },
        cmd = {
            "ToggleTerm",
            "TermExec",
            "ToggleTermToggleAll",
            "ToggleTermSendCurrentLine",
            "ToggleTermSendVisualLines",
            "ToggleTermSendVisualSelection",
        },
        lazy = true,
        keys = {
            { [[<c-\>]],    desc = "Terminal" },
            { "<leader>t",  group = "Terminal" },
            { "<leader>ta", "<cmd>ToggleTermToggleAll<cr>", desc = "All" },
            {
                "<leader>tc",
                require("plugins.terminal.utils").term_id_cmds("ToggleTermSendCurrentLine"),
                desc = "Send Line",
            },
            { "<leader>tf", "<cmd>ToggleTerm direction=float<cr>", desc = "Float" },
            {
                "<leader>th",
                require("plugins.terminal.utils").term_multi_hv(0.3, "horizontal"),
                desc = "Horizontal",
            },
            { "<leader>ts", group = "Specific" },
            {
                "<leader>tsG",
                function()
                    local Terminal = require("toggleterm.terminal").Terminal
                    local lazygit = Terminal:new({
                        cmd = [[VISUAL="nvim" EDITOR="nvim" lazygit]],
                        hidden = true,
                        direction = "float",
                    })
                    lazygit:toggle()
                end,
                desc = "Lazygit"
            },
            { "<leader>tt", "<cmd>ToggleTerm direction=tab<cr>",                              desc = "Tab" },
            { "<leader>tv", require('plugins.terminal.utils').term_multi_hv(0.4, "vertical"), desc = "Vertical" },
            { "<leader>tw", "<cmd>terminal<cr>",                                              desc = "Window" },

            {
                "<leader>l",
                ":ToggleTermSendVisualLines<cr>",
                mode = 'v',
                desc = "Send line to term"
            },
            {
                "<leader>s",
                ":ToggleTermSendVisualSelection<cr>",
                mode = 'v',
                desc = "Send selection to term"
            }
        }
    }, -- easily manage multiple terminal windows
    {
        "aserowy/tmux.nvim",
        opts = {
            -- overwrite default configuration
            -- here, e.g. to enable default bindings
            copy_sync = {
                -- enables copy sync. by default, all registers are synchronized.
                -- to control which registers are synced, see the `sync_*` options.
                enable = true,
                redirect_to_clipboard = true,
            },
            navigation = {
                -- enables default keybindings (C-hjkl) for normal mode
                enable_default_keybindings = true,
            },
            resize = {
                -- enables default keybindings (A-hjkl) for normal mode
                enable_default_keybindings = true,
            },

        },
        cond = function()
            return vim.fn.getenv("TMUX") ~= vim.NIL
        end,
    }, -- tmux integration for nvim features pane movement and resizing from within nvim.
}
