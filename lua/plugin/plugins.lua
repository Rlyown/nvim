local fn = vim.fn
local configs = require("modules.configs")
local os = require("core.gvariable").os
local dash_path = require("core.gvariable").dash_path
local zeal_path = require("core.gvariable").zeal_path
local keymap_opts = { noremap = true, silent = true }

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

require("lazy").setup({
	-- Colorschemes
	{ "catppuccin/nvim", name = "catppuccin", config = configs.catppuccin, priority = 1000 },

	-- Completions
	{
		"hrsh7th/nvim-cmp",

		config = configs.cmp,
		event = "InsertEnter",
	}, -- The completion plugin
	{ "hrsh7th/cmp-buffer" }, -- buffer completions
	{ "hrsh7th/cmp-path" }, -- path completions
	{ "hrsh7th/cmp-cmdline" }, -- cmdline completions
	{ "hrsh7th/cmp-nvim-lsp" }, -- lsp completions
	{ "saadparwaiz1/cmp_luasnip" }, -- snippet completions
	{ "hrsh7th/cmp-nvim-lua" }, -- neovim's lua api completions
	{ "f3fora/cmp-spell" }, -- spell source for nvim-cmp
	{ "hrsh7th/cmp-copilot" }, -- this is a experimental product

	{ "github/copilot.vim", event = "InsertEnter" }, -- gitHub Copilot
	{ "saecki/crates.nvim", version = "*", event = { "BufRead Cargo.toml" }, config = configs.crates },
	-- helps managing crates.io dependencies
	{ "windwp/nvim-ts-autotag" },

	-- DAP
	{ "rcarriga/nvim-dap-ui", name = "dapui", config = configs.dap.dapui }, -- A UI for nvim-dap
	{ "mfussenegger/nvim-dap", config = configs.dap.dap, dependencies = { "dapui" } }, -- Debug Adapter Protocol client implementation
	{ "theHamsta/nvim-dap-virtual-text", config = configs.dap.vtext }, -- show virtual text
	{ "nvim-telescope/telescope-dap.nvim" }, -- Integration for nvim-dap with telescope.nvim

	-- Git
	{
		"lewis6991/gitsigns.nvim",
		config = configs.gitsigns,
		--[[ version = "release"  ]]
	}, -- show git info in buffer
	-- use("tpope/vim-fugitive") -- a git wrapper
	{ "TimUntersberger/neogit", config = configs.neogit, cmd = "Neogit" }, -- magit for neovim
	{
		"sindrets/diffview.nvim",
		cmd = { "Neogit", "DiffviewOpen", "DiffviewFileHistory", "DiffviewToggleFiles", "DiffviewFocusFiles" },
		config = configs.diffview,
	}, -- Single tabpage interface for easily cycling through diffs for all modified files for any git rev.

	-- LSP
	{
		"williamboman/mason.nvim", -- Portable package manager for Neovim that runs everywhere Neovim runs.
		config = configs.lsp.mason,
	},
	{

		"williamboman/mason-lspconfig.nvim", -- Extension to mason.nvim that makes it easier to use lspconfig with mason.nvim
		config = configs.lsp.mason_lspconfig,
		dependencies = { "mason.nvim" },
	},
	{
		"neovim/nvim-lspconfig", -- enable LSP
		config = configs.lsp.lspconfig,
		dependencies = { "mason-lspconfig.nvim" },
	},
	{
		"folke/neoconf.nvim",
		config = configs.neoconf,
		cmd = "Neoconf",
		dependencies = { "nvim-lspconfig" },
	},
	{
		"WhoIsSethDaniel/mason-tool-installer.nvim",
		config = configs.lsp.mason_tool_installer,
		dependencies = { "mason.nvim" },
	}, -- Install and upgrade third party tools automatically
	{ "jose-elias-alvarez/null-ls.nvim", config = configs.lsp.null_ls }, -- for formatters and linters
	{ "ray-x/lsp_signature.nvim", version = "*", config = configs.lsp.signature, dependencies = { "nvim-lspconfig" } },
	-- LSP signature hint as you type
	{ "kosayoda/nvim-lightbulb", config = configs.lsp.lightbulb }, -- show lightbulb when code action is available
	{ "fatih/vim-go", build = ":GoInstallBinaries", ft = "go", config = configs.lsp.go }, -- Go development plugin
	{
		"simrat39/symbols-outline.nvim",
		config = configs.symbols_outline,
	}, -- A tree like view for symbols
	{ "ThePrimeagen/refactoring.nvim" }, -- The Refactoring library
	{ "lewis6991/spellsitter.nvim" }, -- Treesitter powered spellchecker
	{
		"nvim-neorg/neorg",
		version = "*",
		ft = "norg",
		after = { "nvim-treesitter", "telescope" }, -- You may want to specify Telescope here as well
		config = configs.neorg,
		build = ":Neorg sync-parsers",
		dependencies = {
			{ "nvim-neorg/neorg-telescope" },
			{
				"Pocco81/true-zen.nvim",
				config = function()
					require("true-zen").setup({})
				end,
			},
		},
	},

	{ "andymass/vim-matchup" },
	{
		"gennaro-tedesco/nvim-jqx",
		ft = { "json", "yaml" },
	},

	-- Project
	-- use({ "ahmedkhalf/project.nvim" }) -- superior project management
	{ "Shatur/neovim-session-manager", config = configs.session_manager }, -- A simple wrapper around :mksession
	{ "ethanholz/nvim-lastplace", config = configs.nvim_lastplace },
	-- Intelligently reopen files at your last edit position

	-- Snippets
	{ "L3MON4D3/LuaSnip" }, --snippet engine
	{ "rafamadriz/friendly-snippets" }, -- a bunch of snippets to use
	--[[ use({ "vigoux/templar.nvim", config = configs.templar }) -- A dead simple template manager ]]
	{ "cvigilv/esqueleto.nvim", config = configs.esqueleto },
	--[[ use({ "Rlyown/esqueleto.nvim", config = configs.esqueleto }) ]]
	-- My modified version

	-- Telescope
	{
		"nvim-telescope/telescope.nvim",
		name = "telescope",
		config = configs.telescope,
	}, -- Find, Filter, Preview, Pick.
	{ "nvim-telescope/telescope-fzf-native.nvim", build = "make" }, -- FZF sorter for telescope
	{
		"nvim-telescope/telescope-frecency.nvim",
		dependencies = { "kkharji/sqlite.lua" },
	}, -- offers intelligent prioritization
	{ "nvim-telescope/telescope-file-browser.nvim" }, -- File Browser extension
	{
		"benfowler/telescope-luasnip.nvim",
	},
	{ "zane-/cder.nvim" },
	{
		"debugloop/telescope-undo.nvim",
		config = function()
			require("telescope").load_extension("undo")
			-- optional: vim.keymap.set("n", "<leader>u", "<cmd>Telescope undo<cr>")
		end,
	},

	-- Terminal
	{ "akinsho/toggleterm.nvim", config = configs.toggleterm }, -- easily manage multiple terminal windows
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

	-- Tools
	{ "nvim-lua/popup.nvim" }, -- An implementation of the Popup API from vim in Neovim
	{ "nvim-lua/plenary.nvim", priority = 2000 }, -- Useful lua functions used ny lots of plugins
	{
		"windwp/nvim-autopairs",
		config = configs.autopairs,
		event = "InsertEnter",
	}, -- Autopairs, integrates with both cmp and treesitter
	{ "numToStr/Comment.nvim", config = configs.comment }, -- Easily comment stuff
	{ "famiu/bufdelete.nvim", lazy = true },
	-- delete buffers (close files) without closing your windows or messing up your layout
	-- use({ "moll/vim-bbye", cmd = { "Bdelete", "Bwipeout", "Bdelete!", "Bwipeout!" } }) -- delete buffers (close files) without closing your windows or messing up your layout
	{ "lewis6991/impatient.nvim", priority = 2000 }, -- Improve startup time for Neovim
	{ "folke/which-key.nvim", config = configs.whichkey }, -- Create key bindings that stick.
	{
		"anuvyklack/hydra.nvim",
		dependencies = "anuvyklack/keymap-layer.nvim", -- needed only for pink hydras
		config = configs.hydra,
	}, -- Bind a bunch of key bindings together.
	{ "tpope/vim-repeat" }, -- enable repeating supported plugin maps with "."
	-- use({ "tpope/vim-surround" }) -- all about "surroundings": parentheses, brackets, quotes, XML tags, and more
	{ "kylechui/nvim-surround", config = configs.nvim_surround },
	-- Add/change/delete surrounding delimiter pairs with ease
	{ "nathom/filetype.nvim", config = configs.filetype }, -- A faster version of filetype.vim
	{ "dstein64/vim-startuptime", cmd = { "StartupTime" } }, -- A Vim plugin for profiling Vim's startup time
	-- use({ "Pocco81/AutoSave.nvim" }) -- enable autosave
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
			},
			{
				"gS",
				function()
					require("splitjoin").split()
				end,
				desc = "Split the object under cursor",
			},
		},
		opts = {
			default_indent = "  ", -- default
			languages = {}, -- see Options
		},
	},
	{ "iamcco/markdown-preview.nvim", build = "cd app && yarn install ", ft = "markdown" }, -- markdown preview plugin
	{ "lambdalisue/suda.vim", cmd = { "SudaRead", "SudaWrite" } }, -- An alternative sudo.vim for Vim and Neovim
	{
		"phaazon/hop.nvim",
		branch = "v2",
		config = configs.hop,
	}, -- Neovim motions on speed
	{ "windwp/nvim-spectre" }, -- Find the enemy and replace them with dark power.
	{
		"mrjones2014/dash.nvim",
		build = "make install",
		config = configs.dash,
		cond = function()
			if os == "mac" and vim.fn.isdirectory(dash_path) then
				return true
			end
			return false
		end,
	}, -- Search Dash.app from your Neovim fuzzy finder
	{
		"KabbAmine/zeavim.vim",
		cmd = { "Zeavim", "ZeavimV", "Docset" },
		config = configs.zeavim,
		cond = function()
			if os == "unix" and vim.fn.executable(zeal_path) then
				return true
			end
			return false
		end,
	},
	--[[ end ]]
	{ "gaoDean/autolist.nvim", ft = { "markdown", "norg", "txt" }, config = configs.autolist },
	{ "ibhagwan/smartyank.nvim", config = configs.smartyank },
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
	{ "rainbowhxch/accelerated-jk.nvim", config = configs.accelerated_jk },
	-- Packer

	-- Treesitter
	{ "nvim-treesitter/nvim-treesitter", build = ":TSUpdate", config = configs.treesitter },
	-- Nvim Treesitter configurations and abstraction layer
	{ "JoosepAlviste/nvim-ts-context-commentstring" },
	-- setting the commentstring based on the cursor location in a file.
	{ "romgrk/nvim-treesitter-context", config = configs.treesitter_context }, -- show code context
	{ "nvim-treesitter/playground", cmd = { "TSPlaygroundToggle" } }, -- View treesitter information directly in Neovim
	{ "p00f/nvim-ts-rainbow" }, -- Rainbow parentheses

	-- UI
	{ "karb94/neoscroll.nvim", config = configs.neoscroll },
	{ "nvim-tree/nvim-web-devicons" }, -- a lua fork from vim-devicons
	{ "nvim-tree/nvim-tree.lua", config = configs.nvim_tree }, -- file explorer
	{ "akinsho/bufferline.nvim", config = configs.bufferline }, -- buffer line plugin
	{ "nvim-lualine/lualine.nvim", config = configs.lualine }, -- statusline plugin
	{ "goolord/alpha-nvim", config = configs.alpha }, -- a lua powered greeter
	{ "lukas-reineke/indent-blankline.nvim", config = configs.indentline }, -- Indent guides for Neovim
	{
		"SmiteshP/nvim-navic",
		dependencies = { "neovim/nvim-lspconfig" },
		config = configs.nvim_navic,
	}, -- shows your current code context
	--[[ use({ "mbbill/undotree", cmd = "UndotreeToggle", config = configs.undotree }) -- undo history visualizer ]]
	{ "norcalli/nvim-colorizer.lua", ft = { "css", "javascript", "html" }, config = configs.colorizer },
	-- The fastest Neovim colorizer.
	{
		"folke/trouble.nvim",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		config = configs.trouble,
	},
	-- A pretty diagnostics, references, telescope results, quickfix and location list to help you solve all the trouble your code is causing
	{ "stevearc/dressing.nvim", config = configs.dressing }, -- Neovim plugin to improve the default vim.ui interfaces
	{ "rcarriga/nvim-notify", config = configs.notify }, -- A fancy, configurable, notification manager for NeoVim
	{ "kwkarlwang/bufresize.nvim", lazy = true }, -- Keep buffer dimensions in proportion when terminal window is resized
	{
		"gelguy/wilder.nvim",
		dependencies = {
			{ "romgrk/fzy-lua-native", build = "make" },
			-- NOTE: cpsm require compile manually, run `cd ~/.local/share/nvim/site/pack/packer/start/cpsm && ./install.sh`
			{ "nixprime/cpsm", build = "PY3=ON ./install.sh" },
		},
		config = configs.wilder,
	}, -- A more adventurous wildmenu
	{ "anuvyklack/pretty-fold.nvim", config = configs.pretty_fold },
	-- Foldtext customization and folded region preview in Neovim
	-- Packer
	{
		"folke/noice.nvim",
		config = configs.noice,
		dependencies = {
			-- if you lazy-load any plugin below, make sure to add proper `module="..."` entries
			"MunifTanjim/nui.nvim",
			"rcarriga/nvim-notify",
		},
	},
	{ "jbyuki/nabla.nvim" },
}, lazy_opts)
