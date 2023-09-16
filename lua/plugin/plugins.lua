local configs = require("modules.configs")

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable", -- latest stable release
        lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)

lazy_opts = {
    lockfile = vim.fn.stdpath("config") .. "/plugin/lazy-lock.json",
    ui = {
        custom_keys = {
            ["<localleader>l"] = false,
            ["<localleader>t"] = false,
        },
    },
}

local priorities = {
    first = 2000,
    second = 1000,
    third = 500,
}

-- TODO: remove useless plugin
require("lazy").setup({
    ----------------------------------------------------------------------------------------------
    -- Colorschemes
    ----------------------------------------------------------------------------------------------
    {
        "catppuccin/nvim",
        name = "catppuccin",
        config = configs.catppuccin,
        priority = priorities.second,
    },

    ----------------------------------------------------------------------------------------------
    -- Completions
    ----------------------------------------------------------------------------------------------
    {
        "hrsh7th/nvim-cmp",

        config = configs.cmp,
        event = "InsertEnter",
    },                                                                            -- The completion plugin
    { "hrsh7th/cmp-buffer",       dependencies = { "nvim-cmp" } },                -- buffer completions
    { "hrsh7th/cmp-path",         dependencies = { "nvim-cmp" } },                -- path completions
    { "tzachar/cmp-fuzzy-path",   dependencies = { "hrsh7th/nvim-cmp", "tzachar/fuzzy.nvim" } },
    { "hrsh7th/cmp-cmdline",      dependencies = { "nvim-cmp" } },                -- cmdline completions
    { "hrsh7th/cmp-nvim-lsp",     dependencies = { "nvim-cmp" } },                -- lsp completions
    { "saadparwaiz1/cmp_luasnip", dependencies = { "nvim-cmp", "LuaSnip" } },     -- snippet completions
    { "hrsh7th/cmp-nvim-lua",     dependencies = { "nvim-cmp" } },                -- neovim's lua api completions
    { "f3fora/cmp-spell",         dependencies = { "nvim-cmp" } },                -- spell source for nvim-cmp
    { "hrsh7th/cmp-copilot",      dependencies = { "nvim-cmp", "copilot.vim" } }, -- this is a experimental product
    {
        "github/copilot.vim",
        event = "InsertEnter",
        dependencies = { "nvim-cmp" },
        init = configs.copilot, -- it must be run before copilot.vim
    },                          -- gitHub Copilot
    {
        "saecki/crates.nvim",
        version = "*",
        event = { "BufRead Cargo.toml" },
        config = configs.crates,
    }, -- helps managing crates.io dependencies

    ----------------------------------------------------------------------------------------------
    -- DAP
    ----------------------------------------------------------------------------------------------
    { "mfussenegger/nvim-dap",             config = configs.dap.dap,                  lazy = true },                   -- Debug Adapter Protocol client implementation
    { "rcarriga/nvim-dap-ui",              config = configs.dap.dapui,                dependencies = { "nvim-dap" } }, -- A UI for nvim-dap
    { "theHamsta/nvim-dap-virtual-text",   config = configs.dap.vtext,                dependencies = { "nvim-dap" } }, -- show virtual text
    { "nvim-telescope/telescope-dap.nvim", dependencies = { "nvim-dap", "telescope" } },                               -- Integration for nvim-dap with telescope.nvim

    ----------------------------------------------------------------------------------------------
    -- Git
    ----------------------------------------------------------------------------------------------
    {
        "lewis6991/gitsigns.nvim",
        config = configs.gitsigns,
        --[[ version = "release"  ]]
    }, -- show git info in buffer
    {
        "sindrets/diffview.nvim",
        cmd = { "Neogit", "DiffviewOpen", "DiffviewFileHistory", "DiffviewToggleFiles", "DiffviewFocusFiles" },
        config = configs.diffview,
    }, -- Single tabpage interface for easily cycling through diffs for all modified files for any git rev.
    {
        "TimUntersberger/neogit",
        config = configs.neogit,
        dependencies = {
            "nvim-lua/plenary.nvim",  -- required
            "telescope",              -- optional
            "sindrets/diffview.nvim", -- optional
            -- "ibhagwan/fzf-lua",       -- optional
        },
    }, -- magit for neovim

    ----------------------------------------------------------------------------------------------
    -- LSP
    ----------------------------------------------------------------------------------------------
    {
        "williamboman/mason.nvim", -- Portable package manager for Neovim that runs everywhere Neovim runs.
        config = configs.lsp.mason,
    },
    {
        "williamboman/mason-lspconfig.nvim", -- Extension to mason.nvim that makes it easier to use lspconfig with mason.nvim
        config = configs.lsp.mason_lspconfig,
        dependencies = {
            "mason.nvim",
            -- All of the following must setup before lspconfig
            -- "neoconf.nvim",
            "neodev.nvim",
            "lsp_signature.nvim",
        },
    },
    {
        "neovim/nvim-lspconfig", -- enable LSP
        config = configs.lsp.lspconfig,
        dependencies = {
            "mason-lspconfig.nvim",
        },
    },
    -- {
    --     -- TODO: migrate current lsp setting method to neoconf
    --     "folke/neoconf.nvim",
    --     config = configs.neoconf,
    --     cmd = "Neoconf",
    -- },
    {
        "WhoIsSethDaniel/mason-tool-installer.nvim",
        config = configs.lsp.mason_tool_installer,
        dependencies = { "mason.nvim" },
    },                                                                                                    -- Install and upgrade third party tools automatically
    { "jose-elias-alvarez/null-ls.nvim", config = configs.lsp.null_ls },                                  -- for formatters and linters
    { "ray-x/lsp_signature.nvim",        version = "*",                 config = configs.lsp.signature }, -- LSP signature hint as you type
    { "folke/neodev.nvim",               config = configs.lsp.neodev },
    { "kosayoda/nvim-lightbulb",         config = configs.lsp.lightbulb },                                -- show lightbulb when code action is available
    {
        "lervag/vimtex",
        config = configs.lsp.vimtex,
        priority = priorities.second,
        cond = function()
            return vim.fn.executable("latexmk")
        end,
    },
    {
        "ray-x/go.nvim",
        dependencies = { -- optional packages
            "ray-x/guihua.lua",
            "neovim/nvim-lspconfig",
            "nvim-treesitter/nvim-treesitter",
        },
        config = configs.lsp.go,
        event = { "CmdlineEnter" },
        ft = { "go", "gomod" },
        build = ':lua require("go.install").update_all_sync()', -- if you need to install/update all binaries
    },

    {
        "simrat39/symbols-outline.nvim",
        config = configs.symbols_outline,
        cmd = "SymbolsOutline",
    }, -- A tree like view for symbols

    {
        "nvim-neorg/neorg",
        build = ":Neorg sync-parsers",
        dependencies = { "nvim-lua/plenary.nvim" },
        config = configs.neorg,
        plug,
    },

    { "nvim-neorg/neorg-telescope",    dependencies = { "neorg", "telescope" } },
    { "andymass/vim-matchup" },

    ----------------------------------------------------------------------------------------------
    -- Project
    ----------------------------------------------------------------------------------------------
    { "Shatur/neovim-session-manager", config = configs.session_manager }, -- A simple wrapper around :mksession
    { "ethanholz/nvim-lastplace",      config = configs.nvim_lastplace },  -- Intelligently reopen files at your last edit position

    ----------------------------------------------------------------------------------------------
    -- Snippets
    ----------------------------------------------------------------------------------------------
    {
        "L3MON4D3/LuaSnip",
        dependencies = { "rafamadriz/friendly-snippets" },
    }, --snippet engine
    { "evesdropper/luasnip-latex-snippets.nvim", dependencies = { "LuaSnip" } },
    { "cvigilv/esqueleto.nvim",                  config = configs.esqueleto },

    ----------------------------------------------------------------------------------------------
    -- Telescope
    ----------------------------------------------------------------------------------------------
    {
        "nvim-telescope/telescope.nvim",
        name = "telescope",
        config = configs.telescope,
        lazy = true,
        dependencies = { "trouble.nvim" },
    },                                                                                                               -- Find, Filter, Preview, Pick.
    { "nvim-telescope/telescope-fzf-native.nvim",   build = "make",                dependencies = { "telescope" } }, -- FZF sorter for telescope
    {
        "nvim-telescope/telescope-frecency.nvim",
        dependencies = { "kkharji/sqlite.lua", "telescope" },
    },                                                                                -- offers intelligent prioritization
    { "nvim-telescope/telescope-file-browser.nvim", dependencies = { "telescope" } }, -- File Browser extension
    {
        "benfowler/telescope-luasnip.nvim",
        dependencies = { "telescope", "LuaSnip" },
    },
    { "zane-/cder.nvim",       dependencies = { "telescope" } },
    {
        "debugloop/telescope-undo.nvim",
        config = function()
            require("telescope").load_extension("undo")
            -- optional: vim.keymap.set("n", "<leader>u", "<cmd>Telescope undo<cr>")
        end,
        dependencies = { "telescope" },
    },

    ----------------------------------------------------------------------------------------------
    -- Terminal
    ----------------------------------------------------------------------------------------------
    {
        "akinsho/toggleterm.nvim",
        config = configs.toggleterm,
    }, -- easily manage multiple terminal windows
    {
        "sakhnik/nvim-gdb",
        build = "bash ./install.sh",
        cmd = { "GdbStart", "GdbStartLLDB", "GdbStartPDB", "GdbStartBashDB" },
        config = configs.nvim_gdb,
    }, -- Neovim thin wrapper for GDB, LLDB, PDB/PDB++ and BashDB
    {
        "aserowy/tmux.nvim",
        config = configs.tmux,

        cond = function()
            return vim.fn.getenv("TMUX") ~= vim.NIL
        end,
    }, -- tmux integration for nvim features pane movement and resizing from within nvim.

    ----------------------------------------------------------------------------------------------
    -- Tools
    ----------------------------------------------------------------------------------------------
    { "nvim-lua/popup.nvim",   priority = priorities.first }, -- An implementation of the Popup API from vim in Neovim
    { "nvim-lua/plenary.nvim", priority = priorities.first }, -- Useful lua functions used ny lots of plugins
    {
        "windwp/nvim-autopairs",
        config = configs.autopairs,
        event = "InsertEnter",
    },                                                           -- Autopairs, integrates with both cmp and treesitter
    { "nathom/filetype.nvim" },
    { "numToStr/Comment.nvim",    config = configs.comment },    -- Easily comment stuff
    { "famiu/bufdelete.nvim",     lazy = true },                 -- delete buffers (close files) without closing your windows or messing up your layout
    { "lewis6991/impatient.nvim", priority = priorities.first }, -- Improve startup time for Neovim
    { "folke/which-key.nvim",     config = configs.whichkey },   -- Create key bindings that stick.
    {
        "anuvyklack/hydra.nvim",
        dependencies = "anuvyklack/keymap-layer.nvim",            -- needed only for pink hydras
        config = configs.hydra,
    },                                                            -- Bind a bunch of key bindings together.
    { "tpope/vim-repeat" },                                       -- enable repeating supported plugin maps with "."
    { "kylechui/nvim-surround", config = configs.nvim_surround }, -- Add/change/delete surrounding delimiter pairs with ease
    { "RaafatTurki/hex.nvim",   config = configs.hex },
    {
        "bennypowers/splitjoin.nvim",
        lazy = true,
        keys = {
            {
                "gJ",
                function()
                    require("splitjoin").join()
                end,
                desc = "Join the object under cursor",
                noremap = true,
                silent = true,
            },
            {
                "gS",
                function()
                    require("splitjoin").split()
                end,
                desc = "Split the object under cursor",
                noremap = true,
                silent = true,
            },
        },
        opts = {
            default_indent = "  ", -- default
            languages = {},        -- see Options
        },
    },
    { "iamcco/markdown-preview.nvim", build = "cd app && yarn install ", ft = "markdown" }, -- markdown preview plugin
    { "lambdalisue/suda.vim",         cmd = { "SudaRead", "SudaWrite" } },                  -- An alternative sudo.vim for Vim and Neovim
    {
        "phaazon/hop.nvim",
        branch = "v2",
        config = configs.hop,
    }, -- Neovim motions on speed
    {
        "windwp/nvim-spectre",
        lazy = true,
    }, -- Find the enemy and replace them with dark power.
    { "ibhagwan/smartyank.nvim",                    config = configs.smartyank },
    {
        "AckslD/nvim-neoclip.lua",
        dependencies = {
            { "kkharji/sqlite.lua" },
            -- you'll need at least one of these
            -- {'nvim-telescope/telescope.nvim'},
            -- {'ibhagwan/fzf-lua'},
        },
        config = configs.neoclip,
    },
    {
        "rainbowhxch/accelerated-jk.nvim",
        config = configs.accelerated_jk,
        keys = {
            { "j", "<Plug>(accelerated_jk_gj)" },
            { "k", "<Plug>(accelerated_jk_gk)" },
        },
    },
    {
        "cbochs/portal.nvim",
        -- Optional dependencies
        dependencies = {
            "cbochs/grapple.nvim",
            "ThePrimeagen/harpoon",
        },
        config = configs.portal,
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
    },
    {
        "chrishrb/gx.nvim",
        event = { "BufEnter" },
        config = true, -- default settings
    },

    ----------------------------------------------------------------------------------------------
    -- Treesitter
    ----------------------------------------------------------------------------------------------
    { "nvim-treesitter/nvim-treesitter",            build = ":TSUpdate",                config = configs.treesitter }, -- Nvim Treesitter configurations and abstraction layer
    { "JoosepAlviste/nvim-ts-context-commentstring" },                                                                 -- setting the commentstring based on the cursor location in a file.
    { "romgrk/nvim-treesitter-context",             config = configs.treesitter_context },                             -- show code context

    -- UI
    { "karb94/neoscroll.nvim",                      config = configs.neoscroll },
    { "nvim-tree/nvim-web-devicons",                priority = priorities.second }, -- a lua fork from vim-devicons
    { "nvim-tree/nvim-tree.lua",                    config = configs.nvim_tree },   -- file explorer
    { "akinsho/bufferline.nvim",                    config = configs.bufferline },  -- buffer line plugin
    { "nvim-lualine/lualine.nvim",                  config = configs.lualine },     -- statusline plugin
    { "goolord/alpha-nvim",                         config = configs.alpha },       -- a lua powered greeter
    { "lukas-reineke/indent-blankline.nvim",        config = configs.indentline },  -- Indent guides for Neovim
    {
        "SmiteshP/nvim-navic",
        dependencies = { "neovim/nvim-lspconfig" },
        config = configs.nvim_navic,
    }, -- shows your current code context
    {
        "folke/trouble.nvim",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        config = configs.trouble,
    },                                                       -- A pretty diagnostics, references, telescope results, quickfix and location list to help you solve all the trouble your code is causing
    { "stevearc/dressing.nvim", config = configs.dressing }, -- Neovim plugin to improve the default vim.ui interfaces
    { "rcarriga/nvim-notify",   config = configs.notify },   -- A fancy, configurable, notification manager for NeoVim
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
    },                                                                                             -- Keep buffer dimensions in proportion when terminal window is resized
    { "anuvyklack/pretty-fold.nvim", config = configs.pretty_fold, priority = priorities.second }, -- Foldtext customization and folded region preview in Neovim
    {
        "folke/noice.nvim",
        config = configs.noice,
        enabled = true,
        dependencies = {
            -- if you lazy-load any plugin below, make sure to add proper `module="..."` entries
            "MunifTanjim/nui.nvim",
            "rcarriga/nvim-notify",
        },
    },

    ----------------------------------------------------------------------------------------------
    -- Others
    ----------------------------------------------------------------------------------------------
    {
        "ZSaberLv0/ZFVimIM", -- Vim input method
        config = configs.zfvimim,
        dependencies = {
            "ZSaberLv0/ZFVimJob",
            "ZSaberLv0/ZFVimIM_openapi",
        },
    },
}, lazy_opts)
