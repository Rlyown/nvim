-- NOTE: The plguins in this file are related to editor functionality.
return {
    { "nvim-lua/plenary.nvim" }, -- Useful lua functions used ny lots of plugins
    {
        "Shatur/neovim-session-manager",
        config = function()
            local Path = require("plenary.path")
            local session_manager = require("session_manager")
            local config = require("session_manager.config")

            session_manager.setup({
                sessions_dir = Path:new(vim.fn.stdpath("data"), "sessions"), -- The directory where the session files will be saved.
                path_replacer = "__",                                        -- The character to which the path separator will be replaced for session files.
                colon_replacer = "++",                                       -- The character to which the colon symbol will be replaced for session files.
                autoload_mode = config.AutoloadMode.Disabled,                -- Define what to do when Neovim is started without arguments. Possible values: Disabled, CurrentDir, LastSession
                autosave_last_session = true,                                -- Automatically save last session on exit and on session switch.
                autosave_ignore_not_normal = true,                           -- Plugin will not save a session when no buffers are opened, or all of them aren't writable or listed.
                autosave_ignore_filetypes = {                                -- All buffers of these file types will be closed before the session is saved.
                    "Outline",
                    "gitcommit",
                    "NvimTree",
                    "TelescopePrompt",
                },
                autosave_only_in_session = false, -- Always autosaves session. If true, only autosaves after a session is active.
                max_path_length = 80,             -- Shorten the display path if length exceeds this threshold. Use 0 if don't want to shorten the path at all.
            })
        end,
        event = "BufRead",
        cmd = "SessionManager",
        lazy = true,
        keys = {
            { "<leader>Pc", "<cmd>SessionManager load_current_dir_session<cr>", desc = "Load Current Dirtectory" },
            { "<leader>Pd", "<cmd>SessionManager delete_session<cr>",           desc = "Delete Session" },
            { "<leader>Pl", "<cmd>SessionManager load_last_session<cr>",        desc = "Last Session" },
            { "<leader>Ps", "<cmd>SessionManager load_session<cr>",             desc = "Select Session" },
            { "<leader>Pw", "<cmd>SessionManager save_current_session<cr>",     desc = "Save Current Dirtectory" },
        }
    }, -- A simple wrapper around :mksession
    {
        "ethanholz/nvim-lastplace",
        opts = {
            lastplace_ignore_buftype = { "quickfix", "nofile", "help" },
            lastplace_ignore_filetype = {
                "gitcommit",
                "gitrebase",
                "svn",
                "hgcommit",
                "Outline",
                "NvimTree",
                "dapui_breakpoints",
                "dapui_scopes",
                "dapui_stacks",
                "dapui_watches",
                "dap-rel",
            },
            lastplace_open_folds = true,
        },
        event = "BufRead",
        lazy = true
    }, -- Intelligently reopen files at your last edit position
    {
        "cvigilv/esqueleto.nvim",
        opts = {

            -- Directory where templates are stored
            directories = { vim.fn.stdpath("config") .. "/templates/" },

            -- Patterns to match when creating new file
            -- Can be either (i) file names or (ii) file types.
            -- Exact file name match have priority
            patterns = {
                -- file name
                ".clang-format",
                ".clang-tidy",

                -- file type
                "c",
                "cpp",
            },
        },
    },
    {
        "famiu/bufdelete.nvim",
        keys = {
            {
                "<leader>c",
                function()
                    local toggleterm_pattern = "^term://.*#toggleterm#%d+"
                    if string.find(vim.fn.bufname(), toggleterm_pattern) then
                        vim.cmd("bdelete!")
                    else
                        vim.cmd("lua require('bufdelete').bufdelete(0, true)")
                    end
                end,
                desc = "Close Buffer"
            },
        },
        lazy = true
    },                                                                 -- delete buffers (close files) without closing your windows or messing up your layout
    -- TODO: https://gist.github.com/kylechui/a5c1258cd2d86755f97b10fc921315c3
    { "tpope/vim-repeat",       event = "BufRead" },                   -- enable repeating supported plugin maps with "."
    { "kylechui/nvim-surround", opts = {},        event = "BufRead" }, -- Add/change/delete surrounding delimiter pairs with ease
    { "RaafatTurki/hex.nvim",   opts = {},        cmd = { "HexDump", "HexAssemble", "HexToggle" } },
    {
        "lambdalisue/suda.vim",
        keys = {
            { "<leader>e", "<cmd>edit<cr>",      desc = "Reopen" },
            { "<leader>w", "<cmd>w<cr>",         desc = "Save" },
            { "<leader>E", "<cmd>SudaRead<cr>",  desc = "Sudo Reopen" },
            { "<leader>W", "<cmd>SudaWrite<cr>", desc = "Force Save" },
        },
        cmd = { "SudaRead", "SudaWrite" }
    }, -- An alternative sudo.vim for Vim and Neovim
    {
        'smoka7/hop.nvim',
        version = "*",
        opts = {
            keys = 'etovxqpdygfblzhckisuran',
        },
        cmd = { "HopWord", "HopLine", "HopChar1", "HopChar2", "HopPattern" },
        keys = {
            { "<leader>m", "<cmd>HopChar2<cr>", desc = "2-Char" },
        }
    }, -- Neovim motions on speed
    {
        "ojroques/nvim-osc52",
        event = "BufReadPre",
        opts = { silent = true },
        init = function()
            local au_copy = function()
                if vim.v.event.operator == "y" and vim.v.event.regname == "+" then
                    require("osc52").copy_register("+")
                end
                if vim.v.event.operator == "y" and vim.v.event.regname == "" then
                    require("osc52").copy_register("")
                end
            end
            vim.api.nvim_create_autocmd("TextYankPost", { callback = au_copy })
        end,
    },
    {
        "rainbowhxch/accelerated-jk.nvim",
        config = true,
        keys = {
            { "j", "<Plug>(accelerated_jk_gj)" },
            { "k", "<Plug>(accelerated_jk_gk)" },
        },
        lazy = true
    },
    {
        "chrishrb/gx.nvim",
        event = { "BufEnter" },
        config = true, -- default settings
    },
    {
        "folke/which-key.nvim",
        event = "VeryLazy",
        opts = {
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
            spec = {
                { "<leader><leader>", group = "Ext" },
                { "<leader>a",        group = "AI-Assistant" },
                { "<leader>d",        group = "Dugger" },
                { "<leader>g",        group = "Git" },
                { "<leader>l",        group = "Language" },
                { "<leader>lc",       group = "C/C++" },
                { "<leader>lg",       group = "Golang" },
                { "<leader>lr",       group = "Rust" },
                { "<leader>lrc",      group = "Crates" },
                { "<leader>lt",       group = "Latex" },
                { "<leader>lgh",      group = "Helper" },
                { "<leader>lgt",      group = "Tests" },
                { "<leader>lgx",      group = "Code Lens" },
                { "<leader>L",        group = "LSP" },
                { "<leader>P",        group = "Session" },
                { "<leader>s",        group = "Search" },
                { "<leader>sd",       group = "Dap" },
                { "<leader>t",        group = "Terminal" },
                { "<leader>ts",       group = "Specific" },
                { "<leader>x",        group = "Trouble" },
                { "<leader>B",        group = "BufferLine" },
            },
        },
    }, -- Create key bindings that stick.
    {
        "anuvyklack/hydra.nvim",
        dependencies = "anuvyklack/keymap-layer.nvim", -- needed only for pink hydras
        config = function()
            local Hydra = require("hydra")

            ---@diagnostic disable-next-line: redundant-parameter
            local dap_hydra = Hydra({
                name = "Debug Adapter Protocol",
                mode = { "n" },
                body = "<leader>ds",
                hint = [[
_c_: continue
_n_: next
_o_: step out
_i_: step into
_q_: terminate
_<esc>_
            ]],
                config = {
                    color = "pink",
                    hint = {
                        position = "middle-right",
                        border = "rounded",
                    },
                },
                heads = {
                    { 'c',     function() require('dap').continue() end, },
                    { 'n',     function() require('dap').step_over() end, },
                    { 'o',     function() require('dap').step_into() end, },
                    { 'i',     function() require('dap').step_out() end, },
                    { 'q',     function() require('dap').terminate() end, { exit = true } },
                    { '<esc>', nil,                                       { exit = true, nowait = true } },
                }
            })

            ---@diagnostic disable-next-line: redundant-parameter
            local resize_hydra = Hydra({
                name = "Resize Window",
                mode = { "n" },
                body = "<leader>r",
                hint = [[
 _<_: desc weight   _-_: desc height   ___: max height   _o_: max both
 _>_: incr weight   _+_: incr height   _|_: max weight   _=_: equalize
 ^
 _h_: move left     _j_: move down     _k_: move up      _o_: move right
 ^
 ^ ^                ^ ^                ^ ^               _<esc>_
]],
                config = {
                    -- color = "pink",
                    hint = {
                        border = "rounded",
                        position = "bottom",
                    },
                },
                heads = {
                    -- move window
                    { "h",     "<C-w>h" },
                    { "j",     "<C-w>j" },
                    { "k",     "<C-w>k" },
                    { "l",     "<C-w>l" },

                    -- resizing window
                    { "<",     "30<C-w><" },
                    { ">",     "30<C-w>>" },
                    { "+",     "10<C-w>+" },
                    { "-",     "10<C-w>-" },
                    { "_",     "<C-w>_" },
                    { "|",     "<C-w>|" },
                    { "o",     "<C-w>|<C-w>_" },
                    { "=",     "<C-w>=" },

                    -- exit this Hydra
                    { "<Esc>", nil,           { exit = true, nowait = true } },
                },
            })

            local gitsigns = require("gitsigns")
            ---@diagnostic disable-next-line: redundant-parameter
            local git_hydra = Hydra({
                name = "Git",
                hint = [[
 _J_: next hunk   _s_: stage hunk        _d_: show deleted   _b_: blame line
 _K_: prev hunk   _u_: undo stage hunk   _p_: preview hunk   _B_: blame show full
 ^ ^              _S_: stage buffer      ^ ^                 _/_: show base file
 ^
 ^ ^  _c_: checkout branch    _C_: checkout commit    _o_: open changed file
 ^
 _<Enter>_: lazygit    _n_: neogit       _D_: diffview       _<esc>_
]],
                config = {
                    color = "pink",
                    invoke_on_body = true,
                    hint = {
                        position = "bottom",
                        border = "rounded",
                    },
                    -- on_enter = function()
                    -- 	vim.bo.modifiable = false
                    -- gitsigns.toggle_signs(true)
                    -- gitsigns.toggle_linehl(true)
                    -- end,
                    -- on_exit = function()
                    -- gitsigns.toggle_signs(false)
                    -- gitsigns.toggle_linehl(false)
                    -- gitsigns.toggle_deleted(false)
                    -- end,
                },
                mode = { "n", "x" },
                body = "<leader>g",
                heads = {
                    {
                        "J",
                        function()
                            if vim.wo.diff then
                                return "]c"
                            end
                            vim.schedule(function()
                                gitsigns.next_hunk()
                            end)
                            return "<Ignore>"
                        end,
                        { expr = true },
                    },
                    {
                        "K",
                        function()
                            if vim.wo.diff then
                                return "[c"
                            end
                            vim.schedule(function()
                                gitsigns.prev_hunk()
                            end)
                            return "<Ignore>"
                        end,
                        { expr = true },
                    },
                    { "s", ":Gitsigns stage_hunk<CR>", { silent = true } },
                    { "u", gitsigns.undo_stage_hunk },
                    { "S", gitsigns.stage_buffer },
                    { "p", gitsigns.preview_hunk },
                    { "d", gitsigns.toggle_deleted,    { nowait = true } },
                    { "b", gitsigns.blame_line },
                    {
                        "B",
                        function()
                            gitsigns.blame_line({ full = true })
                        end,
                    },
                    { "/",       gitsigns.show,                                              { exit = true } }, -- show the base of the file
                    { "c",       "<cmd>lua require('telescope.builtin').git_branches()<cr>", { exit = true } },
                    { "C",       "<cmd>lua require('telescope.builtin').git_commits()<cr>",  { exit = true } },
                    { "o",       "<cmd>lua require('telescope.builtin').git_status()<cr>",   { exit = true } },
                    { "<Enter>", "<cmd>lua _LAZYGIT_TOGGLE()<cr>",                           { exit = true } },
                    { "n",       "<cmd>Neogit<cr>",                                          { exit = true } },
                    { "D",       "<cmd>DiffviewOpen<cr>",                                    { exit = true } },
                    { "<esc>",   nil,                                                        { exit = true, nowait = true } },
                },
            })

            Hydra.spawn = function(head)
                if head == "git-hydra" then
                    git_hydra:activate()
                elseif head == "resize-hydra" then
                    resize_hydra:activate()
                elseif head == "dap-hydra" then
                    dap_hydra:activate()
                end
            end
        end,
        lazy = true
    }, -- Bind a bunch of key bindings together.
}
