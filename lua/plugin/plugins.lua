local fn = vim.fn
local configs = require("modules.configs")
local os = require("core.gvariable").os
local dash_path = require("core.gvariable").dash_path
local zeal_path = require("core.gvariable").zeal_path

-- Automatically install packer
local install_path = fn.stdpath("data") .. "/site/pack/packer/start/packer.nvim"
if fn.empty(fn.glob(install_path)) > 0 then
	PACKER_BOOTSTRAP = fn.system({
		"git",
		"clone",
		"--depth",
		"1",
		"https://github.com/wbthomason/packer.nvim",
		install_path,
	})
	print("Installing packer close and reopen Neovim...")
	vim.cmd([[packadd packer.nvim]])
end

-- Autocommand that reloads neovim whenever you save the plugins.lua file
vim.cmd([[
    augroup packer_user_config
        autocmd!
        autocmd BufWritePost plugins.lua source <afile> | PackerSync
    augroup end
]])

-- Use a protected call so we don't error out on first use
local status_ok, packer = pcall(require, "packer")
if not status_ok then
	return
end

-- Have packer use a popup window
packer.init({
	display = {
		open_fn = function()
			return require("packer.util").float({ border = "rounded" })
		end,
	},
	auto_reload_compiled = true,
})

-- Install your plugins here
return packer.startup(function(use)
	-- Colorschemes
	use({ "catppuccin/nvim", as = "catppuccin", config = configs.catppuccin })

	-- Completions
	use({
		"hrsh7th/nvim-cmp",

		config = configs.cmp,
		requires = {
			{ "hrsh7th/cmp-buffer", after = "nvim-cmp" }, -- buffer completions
			{ "hrsh7th/cmp-path", after = "cmp-buffer" }, -- path completions
			{ "hrsh7th/cmp-cmdline", after = "cmp-path" }, -- cmdline completions
			{ "hrsh7th/cmp-nvim-lsp", after = "cmp-cmdline" }, -- lsp completions
			{ "saadparwaiz1/cmp_luasnip", after = "cmp-nvim-lsp" }, -- snippet completions
			{ "hrsh7th/cmp-nvim-lua", after = "cmp_luasnip" }, -- neovim's lua api completions
			{ "f3fora/cmp-spell", after = "cmp-nvim-lua" }, -- spell source for nvim-cmp
			{ "hrsh7th/cmp-copilot", after = { "copilot.vim", "cmp-spell" } }, -- this is a experimental product
		},
		module = "cmp",
		event = "InsertEnter",
	}) -- The completion plugin
	use({ "github/copilot.vim", event = "InsertEnter" }) -- gitHub Copilot
	use({ "saecki/crates.nvim", tag = "*", event = { "BufRead Cargo.toml" }, config = configs.crates }) -- helps managing crates.io dependencies
	use({ "windwp/nvim-ts-autotag", after = "nvim-treesitter" })

	-- DAP
	use({ "rcarriga/nvim-dap-ui", as = "dapui", module = "dapui", config = configs.dap.dapui }) -- A UI for nvim-dap
	use({ "mfussenegger/nvim-dap", config = configs.dap.dap, module = "dap", after = "dapui" }) -- Debug Adapter Protocol client implementation
	use({ "theHamsta/nvim-dap-virtual-text", config = configs.dap.vtext, after = "nvim-dap" }) -- show virtual text
	use({ "nvim-telescope/telescope-dap.nvim", after = { "telescope", "nvim-dap-virtual-text" } }) -- Integration for nvim-dap with telescope.nvim

	-- Git
	use({
		"lewis6991/gitsigns.nvim",
		config = configs.gitsigns,
		--[[ tag = "release"  ]]
	}) -- show git info in buffer
	-- use("tpope/vim-fugitive") -- a git wrapper
	use({ "TimUntersberger/neogit", requires = "nvim-lua/plenary.nvim", config = configs.neogit }) -- magit for neovim
	use({
		"sindrets/diffview.nvim",
		requires = "nvim-lua/plenary.nvim",
		cmd = { "Neogit", "DiffviewOpen", "DiffviewFileHistory", "DiffviewToggleFiles", "DiffviewFocusFiles" },
		config = configs.diffview,
	}) -- Single tabpage interface for easily cycling through diffs for all modified files for any git rev.

	-- LSP
	use({
		"williamboman/mason.nvim", -- Portable package manager for Neovim that runs everywhere Neovim runs.
		config = configs.lsp.mason,
	})
	use({

		"williamboman/mason-lspconfig.nvim", -- Extension to mason.nvim that makes it easier to use lspconfig with mason.nvim
		config = configs.lsp.mason_lspconfig,
		after = "mason.nvim",
	})

	use({
		"neovim/nvim-lspconfig", -- enable LSP
		config = configs.lsp.lspconfig,
		after = "mason-lspconfig.nvim",
	})
	use({ "WhoIsSethDaniel/mason-tool-installer.nvim", config = configs.lsp.mason_tool_installer, after = "mason.nvim" }) -- Install and upgrade third party tools automatically
	use({ "jose-elias-alvarez/null-ls.nvim", config = configs.lsp.null_ls, after = "nvim-lspconfig" }) -- for formatters and linters
	use({ "ray-x/lsp_signature.nvim", tag = "*", config = configs.lsp.signature, after = "nvim-lspconfig" }) -- LSP signature hint as you type
	use({ "kosayoda/nvim-lightbulb", config = configs.lsp.lightbulb, after = { "nvim-lspconfig", "null-ls.nvim" } }) -- show lightbulb when code action is available
	use({ "fatih/vim-go", run = ":GoInstallBinaries", ft = "go", config = configs.lsp.go, after = "nvim-lspconfig" }) -- Go development plugin
	use({
		"simrat39/symbols-outline.nvim",
		config = configs.symbols_outline,
		after = { "nvim-lspconfig", "null-ls.nvim" },
	}) -- A tree like view for symbols
	use({ "ThePrimeagen/refactoring.nvim", after = "nvim-treesitter" }) -- The Refactoring library
	use({ "lewis6991/spellsitter.nvim", after = "nvim-treesitter" }) -- Treesitter powered spellchecker
	use({
		"nvim-neorg/neorg",
		-- tag = "*",
		ft = "norg",
		after = { "nvim-treesitter", "telescope" }, -- You may want to specify Telescope here as well
		config = configs.neorg,
		requires = {
			"nvim-neorg/neorg-telescope",
			"esquires/neorg-gtd-project-tags",
			"max397574/neorg-contexts",
			"max397574/neorg-kanban",
			{
				"Pocco81/true-zen.nvim",
				config = function()
					require("true-zen").setup({})
				end,
				module = "true-zen",
			},
		},
	})
	use({ "andymass/vim-matchup" })

	-- Project
	-- use({ "ahmedkhalf/project.nvim" }) -- superior project management
	use({ "Shatur/neovim-session-manager", config = configs.session_manager, after = "nvim-treesitter" }) -- A simple wrapper around :mksession
	use({ "ethanholz/nvim-lastplace", config = configs.nvim_lastplace }) -- Intelligently reopen files at your last edit position

	-- Snippets
	use({ "L3MON4D3/LuaSnip", module = "luasnip" }) --snippet engine
	use({ "rafamadriz/friendly-snippets" }) -- a bunch of snippets to use
	use({ "vigoux/templar.nvim", config = configs.templar }) -- A dead simple template manager
	-- use({ "glepnir/template.nvim" }) -- Quickly insert templates into file

	-- Telescope
	use({
		"nvim-telescope/telescope.nvim",
		as = "telescope",
		config = configs.telescope,
		module = "telescope",
	}) -- Find, Filter, Preview, Pick.
	use({ "nvim-telescope/telescope-fzf-native.nvim", run = "make", after = "telescope" }) -- FZF sorter for telescope
	use({
		"nvim-telescope/telescope-frecency.nvim",
		requires = { "kkharji/sqlite.lua", module = "sqlite" },
		after = "telescope-fzf-native.nvim",
	}) -- offers intelligent prioritization
	use({ "nvim-telescope/telescope-file-browser.nvim", after = "telescope-frecency.nvim" }) -- File Browser extension
	use({
		"benfowler/telescope-luasnip.nvim",
		after = "telescope-file-browser.nvim",
	})
	use({ "zane-/cder.nvim", after = "telescope-luasnip.nvim" })
	use({
		"debugloop/telescope-undo.nvim",
		config = function()
			require("telescope").load_extension("undo")
			-- optional: vim.keymap.set("n", "<leader>u", "<cmd>Telescope undo<cr>")
		end,
		after = "cder.nvim",
	})

	-- Terminal
	use({ "akinsho/toggleterm.nvim", config = configs.toggleterm }) -- easily manage multiple terminal windows
	use({
		"sakhnik/nvim-gdb",
		run = "bash ./install.sh",
		cmd = { "GdbStart", "GdbStartLLDB", "GdbStartPDB", "GdbStartBashDB" },
		config = configs.nvim_gdb,
	}) -- Neovim thin wrapper for GDB, LLDB, PDB/PDB++ and BashDB
	use({
		"aserowy/tmux.nvim",
		config = configs.tmux,

		cond = function()
			return vim.fn.getenv("TMUX") ~= vim.NIL
		end,
	}) -- tmux integration for nvim features pane movement and resizing from within nvim.

	-- Tools
	use({ "wbthomason/packer.nvim" }) -- Have packer manage itself
	use({ "nvim-lua/popup.nvim" }) -- An implementation of the Popup API from vim in Neovim
	use({ "nvim-lua/plenary.nvim", module = "plenary" }) -- Useful lua functions used ny lots of plugins
	use({
		"windwp/nvim-autopairs",
		config = configs.autopairs,
		module = "nvim-autopairs",
		event = "InsertEnter",
	}) -- Autopairs, integrates with both cmp and treesitter
	use({ "numToStr/Comment.nvim", config = configs.comment }) -- Easily comment stuff
	use({ "famiu/bufdelete.nvim", module = "bufdelete", opt = true }) -- delete buffers (close files) without closing your windows or messing up your layout
	-- use({ "moll/vim-bbye", cmd = { "Bdelete", "Bwipeout", "Bdelete!", "Bwipeout!" } }) -- delete buffers (close files) without closing your windows or messing up your layout
	use({ "lewis6991/impatient.nvim" }) -- Improve startup time for Neovim
	use({ "folke/which-key.nvim", config = configs.whichkey }) -- Create key bindings that stick.
	use({
		"anuvyklack/hydra.nvim",
		requires = "anuvyklack/keymap-layer.nvim", -- needed only for pink hydras
		config = configs.hydra,

		module = "hydra",
	}) -- Bind a bunch of key bindings together.
	use({ "tpope/vim-repeat" }) -- enable repeating supported plugin maps with "."
	-- use({ "tpope/vim-surround" }) -- all about "surroundings": parentheses, brackets, quotes, XML tags, and more
	use({ "kylechui/nvim-surround", config = configs.nvim_surround }) -- Add/change/delete surrounding delimiter pairs with ease
	use({ "nathom/filetype.nvim", config = configs.filetype }) -- A faster version of filetype.vim
	use({ "dstein64/vim-startuptime", cmd = { "StartupTime" } }) -- A Vim plugin for profiling Vim's startup time
	-- use({ "Pocco81/AutoSave.nvim" }) -- enable autosave
	use({ "AndrewRadev/splitjoin.vim" }) -- Switch between single-line and multiline forms of code
	use({ "iamcco/markdown-preview.nvim", run = "cd app && yarn install ", ft = "markdown" }) -- markdown preview plugin
	use({ "lambdalisue/suda.vim", cmd = { "SudaRead", "SudaWrite" } }) -- An alternative sudo.vim for Vim and Neovim
	use({ "phaazon/hop.nvim", branch = "v2", config = configs.hop }) -- Neovim motions on speed
	use({ "windwp/nvim-spectre" }) -- Find the enemy and replace them with dark power.
	if os == "mac" and vim.fn.isdirectory(dash_path) then
		use({ "mrjones2014/dash.nvim", run = "make install", after = "telescope", config = configs.dash }) -- Search Dash.app from your Neovim fuzzy finder
	end
	if os == "unix" and vim.fn.executable(zeal_path) then
		use({ "KabbAmine/zeavim.vim", cmd = { "Zeavim", "ZeavimV", "Docset" }, config = configs.zeavim })
	end
	use({ "gaoDean/autolist.nvim", ft = { "markdown", "norg", "txt" }, config = configs.autolist })
	use({ "ibhagwan/smartyank.nvim", config = configs.smartyank })
	use({
		"AckslD/nvim-neoclip.lua",
		requires = {
			{ "kkharji/sqlite.lua", module = "sqlite" },
			-- you'll need at least one of these
			-- {'nvim-telescope/telescope.nvim'},
			-- {'ibhagwan/fzf-lua'},
		},
		config = configs.neoclip,
		after = "telescope",
	})
	use({ "rainbowhxch/accelerated-jk.nvim", config = configs.accelerated_jk })

	-- Treesitter
	use({ "nvim-treesitter/nvim-treesitter", run = ":TSUpdate", config = configs.treesitter }) -- Nvim Treesitter configurations and abstraction layer
	use({ "JoosepAlviste/nvim-ts-context-commentstring", after = "nvim-treesitter" }) -- setting the commentstring based on the cursor location in a file.
	use({ "romgrk/nvim-treesitter-context", after = "nvim-treesitter", config = configs.treesitter_context }) -- show code context
	use({ "nvim-treesitter/playground", after = "nvim-treesitter", cmd = { "TSPlaygroundToggle" } }) -- View treesitter information directly in Neovim
	use({ "p00f/nvim-ts-rainbow", after = "nvim-treesitter" }) -- Rainbow parentheses

	-- UI
	use({ "karb94/neoscroll.nvim", config = configs.neoscroll })
	use({ "nvim-tree/nvim-web-devicons", module = "nvim-web-devicons" }) -- a lua fork from vim-devicons
	use({ "nvim-tree/nvim-tree.lua", config = configs.nvim_tree }) -- file explorer
	use({ "akinsho/bufferline.nvim", after = "catppuccin", config = configs.bufferline }) -- buffer line plugin
	use({ "nvim-lualine/lualine.nvim", config = configs.lualine }) -- statusline plugin
	use({ "goolord/alpha-nvim", config = configs.alpha }) -- a lua powered greeter
	use({ "lukas-reineke/indent-blankline.nvim", config = configs.indentline }) -- Indent guides for Neovim
	use({
		"SmiteshP/nvim-navic",
		requires = "neovim/nvim-lspconfig",
		module = "nvim-navic",
		after = "nvim-lspconfig",
		config = configs.nvim_navic,
	}) -- shows your current code context
	--[[ use({ "mbbill/undotree", cmd = "UndotreeToggle", config = configs.undotree }) -- undo history visualizer ]]
	use({ "norcalli/nvim-colorizer.lua", ft = { "css", "javascript", "html" }, config = configs.colorizer }) -- The fastest Neovim colorizer.
	use({
		"folke/trouble.nvim",
		requires = "nvim-tree/nvim-web-devicons",
		config = configs.trouble,
		module = "trouble",
		cmd = { "TroubleToggle", "Trouble" },
	}) -- A pretty diagnostics, references, telescope results, quickfix and location list to help you solve all the trouble your code is causing
	use({ "stevearc/dressing.nvim", config = configs.dressing }) -- Neovim plugin to improve the default vim.ui interfaces
	use({ "rcarriga/nvim-notify", config = configs.notify }) -- A fancy, configurable, notification manager for NeoVim
	use({ "kwkarlwang/bufresize.nvim", module = "bufresize", opt = true }) -- Keep buffer dimensions in proportion when terminal window is resized
	use({
		"gelguy/wilder.nvim",
		requires = {
			{ "romgrk/fzy-lua-native", run = "make" },
			-- NOTE: cpsm require compile manually, run `cd ~/.local/share/nvim/site/pack/packer/start/cpsm && ./install.sh`
			{ "nixprime/cpsm" },
		},
		config = configs.wilder,
	}) -- A more adventurous wildmenu
	use({ "anuvyklack/pretty-fold.nvim", config = configs.pretty_fold }) -- Foldtext customization and folded region preview in Neovim
	-- Packer
	use({
		"folke/noice.nvim",
		config = configs.noice,
		requires = {
			-- if you lazy-load any plugin below, make sure to add proper `module="..."` entries
			"MunifTanjim/nui.nvim",
			"rcarriga/nvim-notify",
		},
	})
	use({ "jbyuki/nabla.nvim", after = "nvim-treesitter", module = "nabla" })

	-- Automatically set up your configuration after cloning packer.nvim
	-- Put this at the end after all plugins
	if PACKER_BOOTSTRAP then
		require("packer").sync()
	end
end)
