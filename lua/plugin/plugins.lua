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
        event = { "InsertEnter", "CmdlineEnter" },
        -- dependencies = {
        --     "cmp-buffer",
        --     "cmp-fuzzy-path",
        --     "cmp-cmdline",
        --     "cmp-nvim-lsp",
        --     "cmp_luasnip",
        --     "cmp-nvim-lua",
        --     "cmp-copilot",
        -- },
    },                                                             -- The completion plugin
    { "hrsh7th/cmp-buffer", },                                     -- buffer completions
    { "hrsh7th/cmp-path", },                                       -- path completions
    -- { "tzachar/cmp-fuzzy-path",   dependencies = { { "tzachar/fuzzy.nvim" } }, },
    { "hrsh7th/cmp-cmdline", },                                    -- cmdline completions
    { "hrsh7th/cmp-nvim-lsp", },                                   -- lsp completions
    { "saadparwaiz1/cmp_luasnip", dependencies = { "LuaSnip" }, }, -- snippet completions
    { "hrsh7th/cmp-nvim-lua", },                                   -- neovim's lua api completions
    { "micangl/cmp-vimtex" },
    -- { "hrsh7th/cmp-omni" },
    -- { "f3fora/cmp-spell",         dependencies = { "nvim-cmp" } },                -- spell source for nvim-cmp
    -- { "hrsh7th/cmp-copilot",      dependencies = { "copilot.vim" } }, -- this is a experimental product
    -- {
    --     "github/copilot.vim",
    --     event = "InsertEnter",
    --     init = configs.copilot, -- it must be run before copilot.vim
    --     lazy = true
    -- },                          -- gitHub Copilot

    {
        "zbirenbaum/copilot-cmp",
        config = function()
            require("copilot_cmp").setup()
        end,
        dependencies = { "copilot.lua" },
    },
    {
        "zbirenbaum/copilot.lua",
        event = "InsertEnter",
        init = configs.copilot.init,
        config = configs.copilot.config,
        lazy = true
    },
    {
        "saecki/crates.nvim",
        event = { "BufRead Cargo.toml" },
        config = configs.crates,
        lazy = true
    }, -- helps managing crates.io dependencies


    ----------------------------------------------------------------------------------------------
    -- DAP
    ----------------------------------------------------------------------------------------------
    {
        'mfussenegger/nvim-dap',
        config = configs.dap.dap
    },
    {
        'theHamsta/nvim-dap-virtual-text',
        dependencies = { 'mfussenegger/nvim-dap' },
        config = configs.dap.vtext
    },
    {
        "rcarriga/nvim-dap-ui",
        dependencies = { "mfussenegger/nvim-dap", "nvim-neotest/nvim-nio" },
        config = configs.dap.dapui
    },
    {
        'rcarriga/cmp-dap',
        dependencies = { "mfussenegger/nvim-dap", "hrsh7th/nvim-cmp" },
    },
    {
        'nvim-telescope/telescope-dap.nvim',
        dependencies = { "mfussenegger/nvim-dap", "telescope" },
    },
    { "LiadOz/nvim-dap-repl-highlights" },
    {
        "mfussenegger/nvim-dap-python",
        config = function()
            require("dap-python").setup(vim.fn.stdpath('data') .. '/mason/packages/debugpy/venv/bin/python')
        end,
    },

    ----------------------------------------------------------------------------------------------
    -- Git
    ----------------------------------------------------------------------------------------------
    {
        "lewis6991/gitsigns.nvim",
        config = configs.gitsigns,
        lazy = true,
        event = "BufRead",
    }, -- show git info in buffer
    {
        "sindrets/diffview.nvim",
        cmd = { "DiffviewOpen", "DiffviewFileHistory", "DiffviewToggleFiles", "DiffviewFocusFiles" },
        config = configs.diffview,
        lazy = true
    }, -- Single tabpage interface for easily cycling through diffs for all modified files for any git rev.
    -- {
    --     "TimUntersberger/neogit",
    --     config = configs.neogit,
    --     dependencies = {
    --         "nvim-lua/plenary.nvim",  -- required
    --         "telescope",              -- optional
    --         "sindrets/diffview.nvim", -- optional
    --     },
    --     cmd = { "Neogit", "NeogitResetState" },
    --     lazy = true
    -- }, -- magit for neovim

    ----------------------------------------------------------------------------------------------
    -- LSP
    ----------------------------------------------------------------------------------------------
    {
        "williamboman/mason.nvim", -- Portable package manager for Neovim that runs everywhere Neovim runs.
        config = configs.lsp.mason,
        cmd = { "Mason", "MasonInstall", "MasonUninstall", "MasonUninstallAll", "MasonLog" },
        event = "User FileOpened",
        lazy = true,
    },
    {
        "williamboman/mason-lspconfig.nvim", -- Extension to mason.nvim that makes it easier to use lspconfig with mason.nvim
        config = configs.lsp.mason_lspconfig,
        dependencies = {
            "mason.nvim",
            -- All of the following must setup before lspconfig
            -- "neodev.nvim",
            "lsp_signature.nvim",
        },
        cmd = { "LspInstall", "LspUninstall" },
        event = "User FileOpened",
        lazy = true,
    },
    {
        "neovim/nvim-lspconfig", -- enable LSP
        config = function()
            local lsp_handler = require("modules.lsp.handlers")
            lsp_handler.setup()
            vim.g.rustaceanvim = {
                server = {
                    on_attach = lsp_handler.on_attach,
                }
            }
        end,
        dependencies = {
            "mason-lspconfig.nvim",
        },
        lazy = true,
    },
    {
        "WhoIsSethDaniel/mason-tool-installer.nvim",
        config = configs.lsp.mason_tool_installer,
        dependencies = { "mason.nvim" },
        cmd = { "MasonToolInstall", "MasonToolUpdate", "MasonToolClean" },
        lazy = true,
    }, -- Install and upgrade third party tools automatically
    {
        "nvimtools/none-ls.nvim",
        config = configs.lsp.null_ls,
        event = "BufRead",
        cmd = { "NullLsInfo", "NullLsLog" }
    },                                                                                           -- for formatters and linters
    { "ray-x/lsp_signature.nvim",       config = configs.lsp.signature, event = "InsertEnter" }, -- LSP signature hint as you type
    -- { "folke/neodev.nvim",               config = configs.lsp.neodev },
    -- { "kosayoda/nvim-lightbulb",         config = configs.lsp.lightbulb },                                -- show lightbulb when code action is available
    {
        "lervag/vimtex",
        config = configs.lsp.vimtex,
        priority = priorities.second,
        cond = function()
            return vim.fn.executable("latexmk")
        end,
        ft = { "tex", "bib" },
        lazy = true
    },
    {
        "ray-x/go.nvim",
        dependencies = { -- optional packages
            "ray-x/guihua.lua",
            "neovim/nvim-lspconfig",
            "nvim-treesitter/nvim-treesitter",
        },
        config = configs.lsp.go,
        event = { "CmdlineEnter", "BufRead" },
        ft = { "go", "gomod" },
        build = ':lua require("go.install").update_all_sync()', -- if you need to install/update all binaries
    },

    {
        "simrat39/symbols-outline.nvim",
        config = configs.symbols_outline,
        cmd = "SymbolsOutline",
        lazy = true
    }, -- A tree like view for symbols

    {
        "nvim-neorg/neorg",
        lazy = true, -- Disable lazy loading as some `lazy.nvim` distributions set `lazy = true` by default
        ft = "norg",
        cmd = "Neorg",
        version = "*", -- Pin Neorg to the latest stable release
        config = configs.neorg,
    },

    { "nvim-neorg/neorg-telescope", dependencies = { "neorg", "telescope" }, lazy = true },
    { "andymass/vim-matchup",       lazy = true,                             keys = { "%" } },
    {
        'mrcjkb/rustaceanvim',
        version = '^5', -- Recommended
        lazy = false,   -- This plugin is already lazy
    },

    ----------------------------------------------------------------------------------------------
    -- Project
    ----------------------------------------------------------------------------------------------
    {
        "Shatur/neovim-session-manager",
        config = configs.session_manager,
        event = "BufRead",
        cmd = "SessionManager",
        lazy = true
    }, -- A simple wrapper around :mksession
    {
        "ethanholz/nvim-lastplace",
        config = configs.nvim_lastplace,
        event = "BufRead",
        lazy = true
    }, -- Intelligently reopen files at your last edit position

    ----------------------------------------------------------------------------------------------
    -- Snippets
    ----------------------------------------------------------------------------------------------
    {
        "L3MON4D3/LuaSnip",
        dependencies = { "rafamadriz/friendly-snippets" },
        event = "InsertEnter",
    }, --snippet engine
    { "evesdropper/luasnip-latex-snippets.nvim", dependencies = { "LuaSnip" }, ft = { "tex", "bib" } },
    { "cvigilv/esqueleto.nvim",                  config = configs.esqueleto, },

    ----------------------------------------------------------------------------------------------
    -- Telescope
    ----------------------------------------------------------------------------------------------
    {
        "nvim-telescope/telescope.nvim",
        name = "telescope",
        config = configs.telescope,
        lazy = true,
        cmd = "Telescope",
        dependencies = { "trouble.nvim", "telescope-fzf-native.nvim", "telescope-frecency.nvim", "telescope-luasnip.nvim" },
    }, -- Find, Filter, Preview, Pick.
    {
        "nvim-telescope/telescope-fzf-native.nvim",
        build = "make",
        lazy = true
    }, -- FZF sorter for telescope
    {
        "nvim-telescope/telescope-frecency.nvim",
        dependencies = { "kkharji/sqlite.lua" },
        lazy = true
    }, -- offers intelligent prioritization
    {
        "benfowler/telescope-luasnip.nvim",
        dependencies = { "LuaSnip" },
        lazy = true
    },
    {
        "debugloop/telescope-undo.nvim",
        config = function()
            require("telescope").load_extension("undo")
            -- optional: vim.keymap.set("n", "<leader>u", "<cmd>Telescope undo<cr>")
        end,
        lazy = true,
    },
    {
        "AckslD/nvim-neoclip.lua",
        dependencies = {
            { 'kkharji/sqlite.lua', module = 'sqlite' },
            -- you'll need at least one of these
            { 'telescope' },
            -- {'ibhagwan/fzf-lua'},
        },
        config = function()
            require('neoclip').setup()
        end,
        lazy = true,
    },

    ----------------------------------------------------------------------------------------------
    -- Terminal
    ----------------------------------------------------------------------------------------------
    {
        "akinsho/toggleterm.nvim",
        config = configs.toggleterm,
        cmd = {
            "ToggleTerm",
            "TermExec",
            "ToggleTermToggleAll",
            "ToggleTermSendCurrentLine",
            "ToggleTermSendVisualLines",
            "ToggleTermSendVisualSelection",
        },
        lazy = true,
        keys = { [[<c-\>]] }
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
        lazy = true
    }, -- Autopairs, integrates with both cmp and treesitter
    {
        "numToStr/Comment.nvim",
        config = configs.comment,
    },                                                           -- Easily comment stuff
    { "famiu/bufdelete.nvim",     lazy = true },                 -- delete buffers (close files) without closing your windows or messing up your layout
    { "lewis6991/impatient.nvim", priority = priorities.first }, -- Improve startup time for Neovim
    {
        "folke/which-key.nvim",
        event = "VeryLazy",
        config = configs.whichkey,
    }, -- Create key bindings that stick.
    {
        "anuvyklack/hydra.nvim",
        dependencies = "anuvyklack/keymap-layer.nvim", -- needed only for pink hydras
        config = configs.hydra,
        lazy = true
    },                                                                                        -- Bind a bunch of key bindings together.
    { "tpope/vim-repeat",             event = "BufRead" },                                    -- enable repeating supported plugin maps with "."
    { "kylechui/nvim-surround",       config = configs.nvim_surround,    event = "BufRead" }, -- Add/change/delete surrounding delimiter pairs with ease
    { "RaafatTurki/hex.nvim",         config = configs.hex,              cmd = { "HexDump", "HexAssemble", "HexToggle" } },
    { "iamcco/markdown-preview.nvim", build = "cd app && yarn install ", ft = "markdown" },   -- markdown preview plugin
    { "lambdalisue/suda.vim",         cmd = { "SudaRead", "SudaWrite" } },                    -- An alternative sudo.vim for Vim and Neovim
    {
        "phaazon/hop.nvim",
        branch = "v2",
        config = configs.hop,
        cmd = { "HopWord", "HopLine", "HopChar1", "HopChar2", "HopPattern" },
    }, -- Neovim motions on speed
    {
        "windwp/nvim-spectre",
        event = "BufRead",
    }, -- Find the enemy and replace them with dark power.
    {
        "ibhagwan/smartyank.nvim",
        config = configs.smartyank,
        enabled = false
    },
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
        config = configs.accelerated_jk,
        keys = {
            { "j", "<Plug>(accelerated_jk_gj)" },
            { "k", "<Plug>(accelerated_jk_gk)" },
        },
        lazy = true
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
        lazy = true,
    },
    {
        "chrishrb/gx.nvim",
        event = { "BufEnter" },
        config = true, -- default settings
    },

    ----------------------------------------------------------------------------------------------
    -- Treesitter
    ----------------------------------------------------------------------------------------------
    { "nvim-treesitter/nvim-treesitter", build = ":TSUpdate",                config = configs.treesitter }, -- Nvim Treesitter configurations and abstraction layer
    { "romgrk/nvim-treesitter-context",  config = configs.treesitter_context },                             -- show code context

    ----------------------------------------------------------------------------------------------
    -- UI
    ----------------------------------------------------------------------------------------------
    { "RRethy/vim-illuminate",           config = configs.vim_illuminate }, -- Highlight other uses of the word under the cursor
    { "karb94/neoscroll.nvim",           config = configs.neoscroll },
    { "nvim-tree/nvim-web-devicons",     lazy = true },                     -- a lua fork from vim-devicons
    {
        "nvim-tree/nvim-tree.lua",
        config = configs.nvim_tree,
        cmd = { "NvimTreeToggle", "NvimTreeOpen", "NvimTreeFocus", "NvimTreeFindFileToggle" },
        event = "User DirOpened",
    },                                                                                                  -- file explorer
    { "akinsho/bufferline.nvim",             config = configs.bufferline },                             -- buffer line plugin
    { "nvim-lualine/lualine.nvim",           config = configs.lualine },                                -- statusline plugin
    { "goolord/alpha-nvim",                  config = configs.alpha },                                  -- a lua powered greeter
    { "lukas-reineke/indent-blankline.nvim", main = "ibl",               config = configs.indentline }, -- Indent guides for Neovim
    {
        "SmiteshP/nvim-navic",
        dependencies = { "neovim/nvim-lspconfig" },
        config = configs.nvim_navic,
        lazy = true
    }, -- shows your current code context
    {
        "folke/trouble.nvim",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        config = configs.trouble,
        cmd = { "Trouble", "TroubleToggle" }

    },                                                                   -- A pretty diagnostics, references, telescope results, quickfix and location list to help you solve all the trouble your code is causing
    { "stevearc/dressing.nvim", config = configs.dressing },             -- Neovim plugin to improve the default vim.ui interfaces
    { "rcarriga/nvim-notify",   config = configs.notify,  lazy = true }, -- A fancy, configurable, notification manager for NeoVim
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
    },                                                                            -- Keep buffer dimensions in proportion when terminal window is resized
    { "anuvyklack/pretty-fold.nvim", config = configs.pretty_fold, lazy = true }, -- Foldtext customization and folded region preview in Neovim
    {
        "folke/noice.nvim",
        config = configs.noice,
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
        event = "BufRead"
    },
}, lazy_opts)
