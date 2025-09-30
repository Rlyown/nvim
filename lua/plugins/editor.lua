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
            icons = {
                separator = "",
                mappings = false,
            },
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
                { "<leader>B",        group = "BufferLine" },
            },
        },
    }, -- Create key bindings that stick.
    {
        "nvimtools/hydra.nvim",
        config = true,
        lazy = true
    }, -- Bind a bunch of key bindings together.
    {
        "michaelb/sniprun",
        branch = "master",
        build = "sh install.sh 1",
        -- do 'sh install.sh 1' if you want to force compile locally
        -- (instead of fetching a binary from the github release). Requires Rust >= 1.65
        config = function()
            require("sniprun").setup({
                -- your options
            })
        end,
        keys = {
            { "<leader>r", "<Plug>SnipRun", mode = { "n", "v" }, desc = "Run Code" },
        }
    },
}
