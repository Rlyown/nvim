-- TODO: https://github.com/folke/snacks.nvim
return {
    { "norcalli/nvim-colorizer.lua", config = true, cmd = "ColorizerToggle", lazy = true },
    {
        "folke/trouble.nvim",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        opts = {},
        cmd = { "Trouble" }

    }, -- A pretty diagnostics, references, telescope results, quickfix and location list to help you solve all the trouble your code is causing
    {
        "cbochs/portal.nvim",
        -- Optional dependencies
        dependencies = {
            "cbochs/grapple.nvim",
            "ThePrimeagen/harpoon",
        },
        config = true,
        keys = {
            {
                "<C-o>",
                "<cmd>Portal jumplist backward<cr>",
                desc = "Jump to previous location in jumplist",
                noremap = true,
                silent = true,
            },
            {
                "<C-i>",
                "<cmd>Portal jumplist forward<cr>",
                desc = "Jump to next location in jumplist",
                noremap = true,
                silent = true,
            },
        },
        lazy = true,
    },
    {
        "RRethy/vim-illuminate",
        config = function()
            require('illuminate').configure()
        end
    }, -- Highlight other uses of the word under the cursor
    {
        "karb94/neoscroll.nvim",
        opts = {}
    },
    { "nvim-tree/nvim-web-devicons", lazy = true }, -- a lua fork from vim-devicons
    {
        "nvim-tree/nvim-tree.lua",
        config = function()
            local nvim_tree = require("nvim-tree")

            local api = require("nvim-tree.api")

            local trash_cmd = "gio trash"
            if require("core.gvariable").os == "mac" then
                trash_cmd = "trash"
            end

            local on_attach = function(bufnr)
                local opts = function(desc)
                    return { desc = "nvim-tree: " .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
                end

                -- Default mappings. Feel free to modify or remove as you wish.
                --
                -- BEGIN_DEFAULT_ON_ATTACH
                vim.keymap.set("n", "<C-]>", api.tree.change_root_to_node, opts("CD"))
                vim.keymap.set("n", "<C-e>", api.node.open.replace_tree_buffer, opts("Open: In Place"))
                vim.keymap.set("n", "<C-k>", api.node.show_info_popup, opts("Info"))
                vim.keymap.set("n", "<C-r>", api.fs.rename_sub, opts("Rename: Omit Filename"))
                vim.keymap.set("n", "<C-t>", api.node.open.tab, opts("Open: New Tab"))
                vim.keymap.set("n", "<C-v>", api.node.open.vertical, opts("Open: Vertical Split"))
                vim.keymap.set("n", "<C-x>", api.node.open.horizontal, opts("Open: Horizontal Split"))
                vim.keymap.set("n", "<BS>", api.node.navigate.parent_close, opts("Close Directory"))
                vim.keymap.set("n", "<CR>", api.node.open.edit, opts("Open"))
                vim.keymap.set("n", "<Tab>", api.node.open.preview, opts("Open Preview"))
                vim.keymap.set("n", ">", api.node.navigate.sibling.next, opts("Next Sibling"))
                vim.keymap.set("n", "<", api.node.navigate.sibling.prev, opts("Previous Sibling"))
                vim.keymap.set("n", ".", api.node.run.cmd, opts("Run Command"))
                vim.keymap.set("n", "-", api.tree.change_root_to_parent, opts("Up"))
                vim.keymap.set("n", "a", api.fs.create, opts("Create"))
                vim.keymap.set("n", "bmv", api.marks.bulk.move, opts("Move Bookmarked"))
                vim.keymap.set("n", "B", api.tree.toggle_no_buffer_filter, opts("Toggle No Buffer"))
                vim.keymap.set("n", "c", api.fs.copy.node, opts("Copy"))
                vim.keymap.set("n", "C", api.tree.toggle_git_clean_filter, opts("Toggle Git Clean"))
                vim.keymap.set("n", "[c", api.node.navigate.git.prev, opts("Prev Git"))
                vim.keymap.set("n", "]c", api.node.navigate.git.next, opts("Next Git"))
                vim.keymap.set("n", "d", api.fs.remove, opts("Delete"))
                vim.keymap.set("n", "D", api.fs.trash, opts("Trash"))
                vim.keymap.set("n", "E", api.tree.expand_all, opts("Expand All"))
                vim.keymap.set("n", "e", api.fs.rename_basename, opts("Rename: Basename"))
                vim.keymap.set("n", "]e", api.node.navigate.diagnostics.next, opts("Next Diagnostic"))
                vim.keymap.set("n", "[e", api.node.navigate.diagnostics.prev, opts("Prev Diagnostic"))
                vim.keymap.set("n", "F", api.live_filter.clear, opts("Clean Filter"))
                vim.keymap.set("n", "f", api.live_filter.start, opts("Filter"))
                vim.keymap.set("n", "g?", api.tree.toggle_help, opts("Help"))
                vim.keymap.set("n", "gy", api.fs.copy.absolute_path, opts("Copy Absolute Path"))
                vim.keymap.set("n", "H", api.tree.toggle_hidden_filter, opts("Toggle Dotfiles"))
                vim.keymap.set("n", "I", api.tree.toggle_gitignore_filter, opts("Toggle Git Ignore"))
                vim.keymap.set("n", "J", api.node.navigate.sibling.last, opts("Last Sibling"))
                vim.keymap.set("n", "K", api.node.navigate.sibling.first, opts("First Sibling"))
                vim.keymap.set("n", "m", api.marks.toggle, opts("Toggle Bookmark"))
                vim.keymap.set("n", "o", api.node.open.edit, opts("Open"))
                vim.keymap.set("n", "O", api.node.open.no_window_picker, opts("Open: No Window Picker"))
                vim.keymap.set("n", "p", api.fs.paste, opts("Paste"))
                vim.keymap.set("n", "P", api.node.navigate.parent, opts("Parent Directory"))
                vim.keymap.set("n", "q", api.tree.close, opts("Close"))
                vim.keymap.set("n", "r", api.fs.rename, opts("Rename"))
                vim.keymap.set("n", "R", api.tree.reload, opts("Refresh"))
                vim.keymap.set("n", "s", api.node.run.system, opts("Run System"))
                vim.keymap.set("n", "S", api.tree.search_node, opts("Search"))
                vim.keymap.set("n", "U", api.tree.toggle_custom_filter, opts("Toggle Hidden"))
                vim.keymap.set("n", "W", api.tree.collapse_all, opts("Collapse"))
                vim.keymap.set("n", "x", api.fs.cut, opts("Cut"))
                vim.keymap.set("n", "y", api.fs.copy.filename, opts("Copy Name"))
                vim.keymap.set("n", "Y", api.fs.copy.relative_path, opts("Copy Relative Path"))
                vim.keymap.set("n", "<2-LeftMouse>", api.node.open.edit, opts("Open"))
                vim.keymap.set("n", "<2-RightMouse>", api.tree.change_root_to_node, opts("CD"))
                -- END_DEFAULT_ON_ATTACH

                -- Mappings migrated from view.mappings.list
                --
                -- You will need to insert "your code goes here" for any mappings with a custom action_cb
                vim.keymap.set("n", "l", api.node.open.edit, opts("Open"))
                vim.keymap.set("n", "<CR>", api.node.open.edit, opts("Open"))
                vim.keymap.set("n", "o", api.node.open.edit, opts("Open"))
                vim.keymap.set("n", "h", api.node.navigate.parent_close, opts("Close Directory"))
                vim.keymap.set("n", "v", api.node.open.vertical, opts("Open: Vertical Split"))
                vim.keymap.set("n", "?", api.tree.toggle_help, opts("Help"))
                vim.keymap.set("n", "d", api.fs.trash, opts("Trash"))
                vim.keymap.set("n", "D", api.fs.remove, opts("Delete"))
                vim.keymap.set("n", "+", api.tree.change_root_to_node, opts("CD"))
                vim.keymap.set("n", "M", api.marks.bulk.move, opts("Move Bookmarked"))
            end
            -- vim.g.nvim_tree_respect_buf_cwd = 1

            nvim_tree.setup({
                on_attach = on_attach,
                auto_reload_on_write = true,
                disable_netrw = true,
                hijack_netrw = true,
                open_on_tab = false,
                hijack_cursor = true,
                update_cwd = true,
                diagnostics = {
                    enable = true,
                    show_on_dirs = true,
                    icons = {
                        hint = "",
                        info = "",
                        warning = "",
                        error = "",
                    },
                },
                update_focused_file = {
                    enable = true,
                    update_cwd = false,
                    ignore_list = {},
                },
                filesystem_watchers = {
                    enable = true,
                    debounce_delay = 100,
                },
                git = {
                    enable = true,
                    ignore = true,
                    timeout = 500,
                },
                view = {
                    width = 30,
                    side = "left",
                    preserve_window_proportions = false,
                    number = false,
                    relativenumber = false,
                    float = {
                        enable = false,
                        open_win_config = {
                            relative = "editor",
                            border = "rounded",
                            width = 30,
                            height = 30,
                            row = 1,
                            col = 1,
                        },
                    },
                },
                renderer = {
                    root_folder_label = ":~",
                    indent_markers = {
                        enable = true,
                        icons = {
                            corner = "└",
                            edge = "│",
                            item = "├",
                            none = " ",
                        },
                    },
                    icons = {
                        webdev_colors = true,
                        glyphs = {
                            -- following options are the default
                            -- each of these are documented in `:help nvim-tree.OPTION_NAME`
                            default = "",
                            symlink = "",
                            git = {
                                unstaged = "",
                                staged = "S",
                                unmerged = "",
                                renamed = "➜",
                                deleted = "",
                                untracked = "U",
                                ignored = "◌",
                            },
                            folder = {
                                default = "",
                                open = "",
                                empty = "",
                                empty_open = "",
                                symlink = "",
                            },
                        },
                    },
                },
                trash = {
                    cmd = trash_cmd,
                    require_confirm = true,
                },
                actions = {
                    use_system_clipboard = true,
                    change_dir = {
                        enable = true,
                        global = false,
                        restrict_above_cwd = false,
                    },
                    open_file = {
                        quit_on_open = false,
                        resize_window = false,
                        window_picker = {
                            enable = true,
                            chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890",
                            exclude = {
                                filetype = { "notify", "packer", "qf", "diff", "fugitive", "fugitiveblame" },
                                buftype = { "nofile", "terminal", "help" },
                            },
                        },
                    },
                },
                log = {
                    enable = false,
                    truncate = false,
                    types = {
                        all = false,
                        config = false,
                        copy_paste = false,
                        diagnostics = false,
                        git = false,
                        profile = false,
                    },
                },
            })
        end,
        cmd = { "NvimTreeToggle", "NvimTreeOpen", "NvimTreeFocus", "NvimTreeFindFileToggle" },
        event = "User DirOpened",
    }, -- file explorer
    {
        "akinsho/bufferline.nvim",
        opts = {
            options = {
                numbers = "none", -- | "ordinal" | "buffer_id" | "both" | function({ ordinal, id, lower, raise }): string,
                close_command = function(bufnum)
                    require("bufdelete").bufdelete(bufnum, true)
                end,
                right_mouse_command = function(bufnum)
                    require("bufdelete").bufdelete(bufnum, true)
                end,
                left_mouse_command = "buffer %d", -- can be a string | function, see "Mouse actions"
                middle_mouse_command = nil, -- can be a string | function, see "Mouse actions"
                indicator = {
                    icon = "▎", -- this should be omitted if indicator style is not 'icon'
                    style = "icon",
                },
                buffer_close_icon = "",
                modified_icon = "●",
                close_icon = "",
                left_trunc_marker = "",
                right_trunc_marker = "",
                max_name_length = 21,
                max_prefix_length = 18, -- prefix used when a buffer is de-duplicated
                tab_size = 21,
                diagnostics = false,    -- | "nvim_lsp" | "coc",
                diagnostics_update_in_insert = false,
                offsets = {
                    { filetype = "NvimTree", text = "", padding = 1 },
                    { filetype = "Outline",  text = "", padding = 1 },
                },
                show_buffer_icons = true,
                show_buffer_close_icons = true,
                show_close_icon = true,
                show_tab_indicators = true,
                persist_buffer_sort = true, -- whether or not custom sorted buffers should persist
                separator_style = "thin",   -- | "thick" | "thin" | { 'any', 'any' },
                enforce_regular_tabs = false,
                always_show_bufferline = true,
            },
            highlights = require("catppuccin.groups.integrations.bufferline").get(),
        }
    }, -- buffer line plugin
    {
        "nvim-lualine/lualine.nvim",
        config = function()
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
                path = 0, -- 0: Just the filename 1: Relative path 2: Absolute path
                shorting_target = 30, -- Shortens path to leave 40 spaces in the window
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



            require("lualine").setup({
                options = {
                    theme = "catppuccin",
                    component_separators = { left = "", right = "" },
                    section_separators = { left = "", right = "" },
                    disabled_filetypes = {
                        "alpha",
                    },
                    always_divide_middle = true,
                    globalstatus = true,
                },
                sections = {
                    lualine_a = { branch, diagnostics },
                    lualine_b = { mode },
                    lualine_c = { navic },
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
    }, -- statusline plugin
    {
        "lukas-reineke/indent-blankline.nvim",
        main = "ibl",
        opts = {
            exclude = {
                filetypes = {
                    "Outline",
                    "help",
                    "startify",
                    "dashboard",
                    "packer",
                    "neogitstatus",
                    "NvimTree",
                    "Trouble",
                    "undotree",
                    "checkhealth",
                },
            }
        },
    }, -- Indent guides for Neovim
    {
        "SmiteshP/nvim-navic",
        dependencies = { "neovim/nvim-lspconfig" },
        config = function()
            local symbols = require("core.gvariable").symbol_map

            local format_symbols = {}
            for key, value in pairs(symbols) do
                format_symbols[key] = value .. " "
            end

            require("nvim-navic").setup({
                icons = format_symbols,
                highlight = true,
                separator = " > ",
                depth_limit = 3,
                depth_limit_indicator = "..",
            })
        end,
        lazy = true
    }, -- shows your current code context
    -- lazy.nvim
    {
        "stevearc/dressing.nvim",
        config = function()
            local dressing = require("dressing")

            local themes = require("telescope.themes")

            dressing.setup({
                input = {
                    -- Set to false to disable the vim.ui.input implementation
                    enabled = true,

                    -- Default prompt string
                    default_prompt = "Input:",

                    -- Can be 'left', 'right', or 'center'
                    prompt_align = "left",

                    -- When true, <Esc> will close the modal
                    insert_only = true,

                    -- These are passed to nvim_open_win
                    border = "rounded",
                    -- 'editor' and 'win' will default to being centered
                    relative = "cursor",

                    -- These can be integers or a float between 0 and 1 (e.g. 0.4 for 40%)
                    prefer_width = 40,
                    width = nil,
                    -- min_width and max_width can be a list of mixed types.
                    -- min_width = {20, 0.2} means "the greater of 20 columns or 20% of total"
                    max_width = { 140, 0.9 },
                    min_width = { 20, 0.2 },

                    override = function(conf)
                        -- This is the config that will be passed to nvim_open_win.
                        -- Change values here to customize the layout
                        return conf
                    end,

                    -- see :help dressing_get_config
                    get_config = function(opts)
                        if opts.kind == "center" then
                            return {
                                relative = "editor",
                            }
                        end
                    end,
                },
                select = {
                    -- Set to false to disable the vim.ui.select implementation
                    enabled = true,

                    -- Priority list of preferred vim.select implementations
                    backend = { "telescope", "builtin" },

                    -- Options for telescope selector
                    -- These are passed into the telescope picker directly. Can be used like:
                    -- telescope = require('telescope.themes').get_ivy({...})
                    telescope = themes.get_dropdown({
                        previewer = false,
                    }),

                    -- Options for fzf selector
                    -- fzf = {
                    -- 	window = {
                    -- 		width = 0.5,
                    -- 		height = 0.4,
                    -- 	},
                    -- },

                    -- Options for fzf_lua selector
                    -- fzf_lua = {
                    -- 	winopts = {
                    -- 		width = 0.5,
                    -- 		height = 0.4,
                    -- 	},
                    -- },

                    -- Options for nui Menu
                    -- nui = {
                    -- 	position = "50%",
                    -- 	size = nil,
                    -- 	relative = "editor",
                    -- 	border = {
                    -- 		style = "rounded",
                    -- 	},
                    -- 	max_width = 80,
                    -- 	max_height = 40,
                    -- },

                    -- Options for built-in selector
                    builtin = {
                        -- These are passed to nvim_open_win
                        border = "rounded",
                        -- 'editor' and 'win' will default to being centered
                        relative = "editor",

                        -- These can be integers or a float between 0 and 1 (e.g. 0.4 for 40%)
                        -- the min_ and max_ options can be a list of mixed types.
                        -- max_width = {140, 0.8} means "the lesser of 140 columns or 80% of total"
                        width = nil,
                        max_width = { 140, 0.8 },
                        min_width = { 40, 0.2 },
                        height = nil,
                        max_height = 0.9,
                        min_height = { 10, 0.2 },

                        override = function(conf)
                            -- This is the config that will be passed to nvim_open_win.
                            -- Change values here to customize the layout
                            return conf
                        end,
                    },

                    -- Used to override format_item. See :help dressing-format
                    format_item_override = {},

                    -- see :help dressing_get_config
                    get_config = nil,
                },
            })
        end
    }, -- Neovim plugin to improve the default vim.ui interfaces
    {
        "rcarriga/nvim-notify",
        config = function()
            require("notify").setup({
                -- Minimum level to show
                level = "info",

                -- Animation style (see below for details)
                stages = "fade_in_slide_out",

                -- Function called when a new window is opened, use for changing win settings/config
                on_open = function(win)
                    -- enable wrap line
                    vim.fn.setwinvar(win, "&wrap", 1)
                end,

                -- Function called when a window is closed
                on_close = nil,

                -- Render function for notifications. See notify-render()
                render = "wrapped-compact",

                -- Default timeout for notifications
                timeout = 1500,

                -- Max number of columns for messages
                max_width = 50,
                -- Max number of lines for a message
                max_height = 40,

                -- For stages that change opacity this is treated as the highlight behind the window
                -- Set this to either a highlight group, an RGB hex value e.g. "#000000" or a function returning an RGB code for dynamic values
                background_colour = "Normal",

                -- Minimum width for notification windows
                minimum_width = 50,

                -- Icons for the different levels
                icons = {
                    ERROR = " ",
                    WARN = " ",
                    INFO = " ",
                    DEBUG = " ",
                    TRACE = "✎ ",
                },

                top_down = true,
            })

            require("telescope").load_extension("notify")
        end,
        lazy = true
    }, -- A fancy, configurable, notification manager for NeoVim
    {
        "kwkarlwang/bufresize.nvim",
        lazy = true,
        keys = {
            { "<C-w><", "<C-w><<cmd>lua require('bufresize').register()<cr>", noremap = true, silent = true },
            { "<C-w>>", "<C-w>><cmd>lua require('bufresize').register()<cr>", noremap = true, silent = true },
            { "<C-w>+", "<C-w>+<cmd>lua require('bufresize').register()<cr>", noremap = true, silent = true },
            { "<C-w>-", "<C-w>-<cmd>lua require('bufresize').register()<cr>", noremap = true, silent = true },
            { "<C-w>_", "<C-w>_<cmd>lua require('bufresize').register()<cr>", noremap = true, silent = true },
            { "<C-w>|", "<C-w>|<cmd>lua require('bufresize').register()<cr>", noremap = true, silent = true },
            { "<C-w>=", "<C-w>=<cmd>lua require('bufresize').register()<cr>", noremap = true, silent = true },
        },
    }, -- Keep buffer dimensions in proportion when terminal window is resized
    {
        "anuvyklack/pretty-fold.nvim",
        config = true,
        lazy = true
    }, -- Foldtext customization and folded region preview in Neovim
    {
        "folke/noice.nvim",
        config = function()
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
                lsp = {
                    -- override markdown rendering so that **cmp** and other plugins use **Treesitter**
                    override = {
                        ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
                        ["vim.lsp.util.stylize_markdown"] = true,
                        ["cmp.entry.get_documentation"] = true, -- requires hrsh7th/nvim-cmp
                    },
                },
                -- you can enable a preset for easier configuration
                presets = {
                    bottom_search = false,        -- use a classic bottom cmdline for search
                    command_palette = true,       -- position the cmdline and popupmenu together
                    long_message_to_split = true, -- long messages will be sent to a split
                    inc_rename = false,           -- enables an input dialog for inc-rename.nvim
                    lsp_doc_border = true,        -- add a border to hover docs and signature help
                },
                routes = custom_routes,           --- @see section on routes
            })

            require("telescope").load_extension("noice")
        end,
        enabled = true,
        dependencies = {
            -- if you lazy-load any plugin below, make sure to add proper `module="..."` entries
            "MunifTanjim/nui.nvim",
            "rcarriga/nvim-notify",
        },
        event = "VeryLazy",
    },
    {
        "andrewferrier/wrapping.nvim",
        config = function()
            require("wrapping").setup({
                create_commands = false,
                create_keymaps = false,
                notify_on_switch = true,
                auto_set_mode_heuristically = false,
            })
        end,
    },
}
