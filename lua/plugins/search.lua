return {
    {
        "nvim-telescope/telescope.nvim",
        config = function()
            local telescope = require("telescope")

            local actions = require("telescope.actions")
            local themes = require("telescope.themes")

            local qlist = function()
                local trouble_status_ok, trouble = pcall(require, "trouble.sources.telescope")
                if not trouble_status_ok then
                    return actions.send_to_qflist + actions.open_qflist
                else
                    return trouble.open
                end
            end

            telescope.setup({
                defaults = {
                    prompt_prefix = " ",
                    selection_caret = " ",
                    path_display = { "smart" },

                    mappings = {
                        -- i means insert mode in telescope
                        i = {
                            ["<C-n>"] = actions.cycle_history_next,
                            ["<C-p>"] = actions.cycle_history_prev,

                            ["<C-j>"] = actions.move_selection_next,
                            ["<C-k>"] = actions.move_selection_previous,

                            ["<C-c>"] = actions.close,

                            ["<Down>"] = actions.move_selection_next,
                            ["<Up>"] = actions.move_selection_previous,

                            ["<CR>"] = actions.select_default,
                            ["<C-x>"] = actions.select_horizontal,
                            ["<C-v>"] = actions.select_vertical,
                            ["<C-t>"] = actions.select_tab,

                            ["<C-u>"] = actions.preview_scrolling_up,
                            ["<C-d>"] = actions.preview_scrolling_down,

                            ["<PageUp>"] = actions.results_scrolling_up,
                            ["<PageDown>"] = actions.results_scrolling_down,

                            ["<Tab>"] = actions.toggle_selection + actions.move_selection_worse,
                            ["<S-Tab>"] = actions.toggle_selection + actions.move_selection_better,
                            ["<C-q>"] = qlist(),
                            -- ["<M-q>"] = actions.send_selected_to_qflist + actions.open_qflist,
                            ["<C-l>"] = actions.complete_tag,
                            ["<C-_>"] = actions.which_key, -- keys from pressing <C-/>
                        },

                        -- n means normal mode in telescope
                        n = {
                            ["<esc>"] = actions.close,
                            ["<CR>"] = actions.select_default,
                            ["<C-x>"] = actions.select_horizontal,
                            ["<C-v>"] = actions.select_vertical,
                            ["<C-t>"] = actions.select_tab,

                            ["<Tab>"] = actions.toggle_selection + actions.move_selection_worse,
                            ["<S-Tab>"] = actions.toggle_selection + actions.move_selection_better,
                            ["<C-q>"] = qlist(),
                            -- ["<M-q>"] = actions.send_selected_to_qflist + actions.open_qflist,

                            ["j"] = actions.move_selection_next,
                            ["k"] = actions.move_selection_previous,
                            ["H"] = actions.move_to_top,
                            ["M"] = actions.move_to_middle,
                            ["L"] = actions.move_to_bottom,

                            ["<Down>"] = actions.move_selection_next,
                            ["<Up>"] = actions.move_selection_previous,
                            ["gg"] = actions.move_to_top,
                            ["G"] = actions.move_to_bottom,

                            ["<C-u>"] = actions.preview_scrolling_up,
                            ["<C-d>"] = actions.preview_scrolling_down,

                            ["<PageUp>"] = actions.results_scrolling_up,
                            ["<PageDown>"] = actions.results_scrolling_down,

                            ["?"] = actions.which_key,
                        },
                    },
                },
                pickers = {
                    -- Default configuration for builtin pickers goes here:
                    -- picker_name = {
                    --   picker_config_key = value,
                    --   ...
                    -- }
                    -- Now the picker_config_key will be applied every time you call this
                    -- builtin picker
                    live_grep = {
                        theme = "ivy",
                    },
                },
                extensions = {
                    -- Your extension configuration goes here:
                    -- extension_name = {
                    --   extension_config_key = value,
                    -- }
                    -- please take a look at the readme of the extension you want to configure
                    fzf = {
                        fuzzy = true,                   -- false will only do exact matching
                        override_generic_sorter = true, -- override the generic sorter
                        override_file_sorter = true,    -- override the file sorter
                        case_mode = "smart_case",       -- or "ignore_case" or "respect_case"
                        -- the default case_mode is "smart_case"
                    },
                    frecency = {
                        show_scores = false,
                        show_unindexed = true,
                        ignore_patterns = { "*.git/*", "*/tmp/*" },
                        disable_devicons = false,
                        workspaces = {
                            -- ["conf"]    = vim.fn.expand("~/.config"),
                        },
                        db_safe_mode = false,
                    },
                    dash = {
                        -- your config here
                    },
                    undo = {
                        side_by_side = true,
                        layout_strategy = "vertical",
                        layout_config = {
                            preview_height = 0.7,
                        },
                    },
                },
            })
        end,
        lazy = true,
        cmd = "Telescope",
        dependencies = { "folke/trouble.nvim" },
        keys = {
            {
                "<leader>b",
                function()
                    require('telescope.builtin').buffers(require('telescope.themes').get_dropdown { previewer = false })
                end,
                desc = "Buffers",
            },
            {
                "<leader>f",
                function()
                    require('telescope.builtin').find_files(require('telescope.themes').get_dropdown { previewer = false })
                end,
                desc = "Find files",
            },
            {
                "<leader>F",
                function() require('telescope.builtin').live_grep() end
                ,
                desc = "Find Text"
            },
            {
                "<leader>gc",
                function() require('telescope.builtin').git_branches() end,
                mode = { "n", "x" },
                desc = "Git Branches"
            },
            {
                "<leader>gC",
                function() require('telescope.builtin').git_commits() end,
                mode = { "n", "x" },
                desc = "Git Commits"
            },
            {
                "<leader>go",
                function() require('telescope.builtin').git_status() end,
                mode = { "n", "x" },
                desc = "Git Status"
            },

            { "<leader>s",  group = "Search" },
            { "<leader>sc", function() require('telescope.builtin').commands() end,    desc = "Commands" },
            { "<leader>sC", function() require('telescope.builtin').colorscheme() end, desc = "Colorscheme" },
            { "<leader>sh", function() require('telescope.builtin').help_tags() end,   desc = "Find Help" },
            { "<leader>sk", function() require('telescope.builtin').keymaps() end,     desc = "Keymaps" },
            { "<leader>sm", function() require('telescope.builtin').man_pages() end,   desc = "Man Pages" },
            { "<leader>sr", function() require('telescope.builtin').oldfiles() end,    desc = "Open Recent File" },
            { "<leader>sR", function() require('telescope.builtin').registers() end,   desc = "Registers" },
            { "<leader>st", function() require('telescope.builtin').tags() end,        desc = "Tags" },
        }
    }, -- Find, Filter, Preview, Pick.
    {
        "nvim-telescope/telescope-fzf-native.nvim",
        build = "make",
        lazy = true,
        config = function()
            require("telescope").load_extension("fzf")
        end,
    }, -- FZF sorter for telescope
    {
        "nvim-telescope/telescope-frecency.nvim",
        dependencies = { "kkharji/sqlite.lua" },
        lazy = true,
        config = function()
            require("telescope").load_extension("frecency")
        end,
    }, -- offers intelligent prioritization
    {
        "debugloop/telescope-undo.nvim",
        config = function()
            require("telescope").load_extension("undo")
            -- optional: vim.keymap.set("n", "<leader>u", "<cmd>Telescope undo<cr>")
        end,
        lazy = true,
        keys = {
            {
                "<leader>u",
                function() require('telescope').extensions.undo.undo() end,
                desc = "Undotree"
            },
        }
    },
    {
        "AckslD/nvim-neoclip.lua",
        dependencies = {
            { 'kkharji/sqlite.lua', module = 'sqlite' },
            -- you'll need at least one of these
            "nvim-telescope/telescope.nvim",
            -- {'ibhagwan/fzf-lua'},
        },
        opts = {},
        lazy = true,
        keys = {
            {
                "<leader>sy",
                function() require('telescope').extensions.neoclip.default() end,
                desc = "Yank History"
            },
            {
                "<leader>sY",
                function() require('telescope').extensions.macroscope.default() end,
                desc = "Macroscope"
            },
        }
    },
    {
        'nvim-telescope/telescope-dap.nvim',
        dependencies = { "mfussenegger/nvim-dap",
            "nvim-telescope/telescope.nvim",
        },
        config = function()
            require("telescope").load_extension("dap")
        end,
        lazy = true,
        keys = {
            { "<leader>sd", group = "Dap" },
            {
                "<leader>sdc",
                function() require 'telescope'.extensions.dap.commands {} end,
                desc = "Commands"
            },
            {
                "<leader>sdC",
                function() require 'telescope'.extensions.dap.configurations {} end,
                desc = "Configs"
            },
            {
                "<leader>sdb",
                function() require 'telescope'.extensions.dap.list_breakpoints {} end,
                desc = "Breakpoints"
            },
            {
                "<leader>sdv",
                function() require 'telescope'.extensions.dap.variables {} end,
                desc = "Variables"
            },
            {
                "<leader>sdf",
                function() require 'telescope'.extensions.dap.frames {} end,
                desc = "Frames"
            },
        }
    },
    {
        'MagicDuck/grug-far.nvim',
        opts = {},
        cmd = { "GrugFar" },
        keys = {
            { "<leader>S", "<cmd>GrugFar<cr>", desc = "Search & Replace" },
        }
    },

}
