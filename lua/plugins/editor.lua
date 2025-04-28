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
        lazy = true
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
    { "famiu/bufdelete.nvim",   lazy = true },                                         -- delete buffers (close files) without closing your windows or messing up your layout
    -- TODO: https://gist.github.com/kylechui/a5c1258cd2d86755f97b10fc921315c3
    { "tpope/vim-repeat",       event = "BufRead" },                                   -- enable repeating supported plugin maps with "."
    { "kylechui/nvim-surround", opts = {},                        event = "BufRead" }, -- Add/change/delete surrounding delimiter pairs with ease
    { "RaafatTurki/hex.nvim",   opts = {},                        cmd = { "HexDump", "HexAssemble", "HexToggle" } },
    { "lambdalisue/suda.vim",   cmd = { "SudaRead", "SudaWrite" } },                   -- An alternative sudo.vim for Vim and Neovim
    {
        'smoka7/hop.nvim',
        version = "*",
        opts = {
            keys = 'etovxqpdygfblzhckisuran',
        },
        cmd = { "HopWord", "HopLine", "HopChar1", "HopChar2", "HopPattern" },
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
}
