local fn = vim.fn
local configs = require("core.gvariable").lazymod_configs

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
})

-- Install your plugins here
return packer.startup(function(use)
	-- Colorschemes
	-- use "lunarvim/colorschemes" -- A bunch of colorschemes you can try out
	-- use "lunarvim/darkplus.nvim"
	-- use "joshdick/onedark.vim"
	use({ "catppuccin/nvim", as = "catppuccin" })

	-- Completions
	use({ "hrsh7th/nvim-cmp" }) -- The completion plugin
	use({ "hrsh7th/cmp-buffer" }) -- buffer completions
	use({ "hrsh7th/cmp-path" }) -- path completions
	use({ "hrsh7th/cmp-cmdline" }) -- cmdline completions
	use({ "hrsh7th/cmp-nvim-lsp" }) -- lsp completions
	use({ "saadparwaiz1/cmp_luasnip" }) -- snippet completions
	use({ "hrsh7th/cmp-nvim-lua" }) -- neovim's lua api completions
	-- use({ "f3fora/cmp-spell" }) -- spell source for nvim-cmp
	-- use "github/copilot.vim" -- gitHub Copilot
	-- use "hrsh7th/cmp-copilot" -- this is a experimental product
	use({ "saecki/crates.nvim", tag = "v0.2.1", event = { "BufRead Cargo.toml" }, config = configs.crates }) -- helps managing crates.io dependencies

	-- DAP
	use({ "mfussenegger/nvim-dap" }) -- Debug Adapter Protocol client implementation
	use({ "rcarriga/nvim-dap-ui" }) -- A UI for nvim-dap
	use({ "theHamsta/nvim-dap-virtual-text" }) -- show virtual text
	use({ "nvim-telescope/telescope-dap.nvim" }) -- Integration for nvim-dap with telescope.nvim
	-- use("simrat39/rust-tools.nvim") -- Tools for better development in rust using neovim's builtin lsp

	-- Git
	use({ "lewis6991/gitsigns.nvim" }) -- show git info in buffer
	-- use("tpope/vim-fugitive") -- a git wrapper

	-- LSP
	use({ "neovim/nvim-lspconfig" }) -- enable LSP
	use({ "williamboman/nvim-lsp-installer" }) -- simple to use language server installer
	use({ "tamago324/nlsp-settings.nvim" }) -- language server settings defined in json for
	use({ "jose-elias-alvarez/null-ls.nvim" }) -- for formatters and linters
	use({ "antoinemadec/FixCursorHold.nvim" }) -- This is needed to fix lsp doc highlight
	-- use { "RishabhRD/nvim-lsputils", requires = { "RishabhRD/popfix" } } -- Better defaults for nvim-lsp actions
	use({ "ray-x/lsp_signature.nvim" }) -- LSP signature hint as you type
	use({ "kosayoda/nvim-lightbulb" }) -- show lightbulb when code action is available
	use({ "fatih/vim-go", run = ":GoInstallBinaries", ft = "go" }) -- Go development plugin
	use({ "simrat39/symbols-outline.nvim" }) -- A tree like view for symbols
	use({ "ThePrimeagen/refactoring.nvim" }) -- The Refactoring library
	use({ "lewis6991/spellsitter.nvim" }) -- Treesitter powered spellchecker
	-- use({ "simrat39/rust-tools.nvim", ft = { "toml", "rust" } }) -- Tools for better development in rust using neovim's builtin lsp

	-- Project
	-- use({ "ahmedkhalf/project.nvim" }) -- superior project management
	use({ "Shatur/neovim-session-manager" }) -- A simple wrapper around :mksession
	use("ethanholz/nvim-lastplace") -- Intelligently reopen files at your last edit position

	-- Snippets
	use({ "L3MON4D3/LuaSnip" }) --snippet engine
	use({ "rafamadriz/friendly-snippets" }) -- a bunch of snippets to use
	use({ "vigoux/templar.nvim" }) -- A dead simple template manager

	-- Telescope
	use({ "nvim-telescope/telescope.nvim" }) -- Find, Filter, Preview, Pick.
	use({ "nvim-telescope/telescope-fzf-native.nvim", run = "make" }) -- FZF sorter for telescope
	use({ "nvim-telescope/telescope-frecency.nvim", requires = { "tami5/sqlite.lua" } }) -- offers intelligent prioritization
	use({ "nvim-telescope/telescope-file-browser.nvim" }) -- File Browser extension
	use({
		"benfowler/telescope-luasnip.nvim",
	})

	-- Terminal
	use({ "akinsho/toggleterm.nvim" }) -- easily manage multiple terminal windows
	use({
		"sakhnik/nvim-gdb",
		run = "bash ./install.sh",
		cmd = { "GdbStart", "GdbStartLLDB", "GdbStartPDB", "GdbStartBashDB" },
	}) -- Neovim thin wrapper for GDB, LLDB, PDB/PDB++ and BashDB

	-- Tools
	use({ "wbthomason/packer.nvim" }) -- Have packer manage itself
	use({ "nvim-lua/popup.nvim" }) -- An implementation of the Popup API from vim in Neovim
	use({ "nvim-lua/plenary.nvim" }) -- Useful lua functions used ny lots of plugins
	use({ "windwp/nvim-autopairs" }) -- Autopairs, integrates with both cmp and treesitter
	use({ "numToStr/Comment.nvim" }) -- Easily comment stuff
	use({ "famiu/bufdelete.nvim", cmd = { "Bdelete", "Bwipeout", "Bdelete!", "Bwipeout!" } }) -- delete buffers (close files) without closing your windows or messing up your layout
	-- use({ "moll/vim-bbye", cmd = { "Bdelete", "Bwipeout", "Bdelete!", "Bwipeout!" } }) -- delete buffers (close files) without closing your windows or messing up your layout
	use({ "lewis6991/impatient.nvim" }) -- Improve startup time for Neovim
	use({ "folke/which-key.nvim" }) -- Create key bindings that stick.
	use({ "tpope/vim-repeat" }) -- enable repeating supported plugin maps with "."
	use({ "tpope/vim-surround" }) -- all about "surroundings": parentheses, brackets, quotes, XML tags, and more
	use({
		"michaelb/sniprun",
		run = "bash ./install.sh",
		cmd = { "SnipRun", "'<,'>SnipRun", "SnipInfo" },
		config = configs.sniprun,
	}) -- run lines/blocs of code
	use({ "nathom/filetype.nvim" }) -- A faster version of filetype.vim
	use({ "dstein64/vim-startuptime", cmd = { "StartupTime" } }) -- A Vim plugin for profiling Vim's startup time
	-- use({ "Pocco81/AutoSave.nvim" }) -- enable autosave
	use({ "AndrewRadev/splitjoin.vim" }) -- Switch between single-line and multiline forms of code
	use({ "iamcco/markdown-preview.nvim", run = "cd app && yarn install ", ft = "markdown" }) -- markdown preview plugin
	use({ "lambdalisue/suda.vim", cmd = { "SudaRead", "SudaWrite" } }) -- An alternative sudo.vim for Vim and Neovim
	use({ "phaazon/hop.nvim", branch = "v1" }) -- Neovim motions on speed
	use({ "windwp/nvim-spectre" }) -- Find the enemy and replace them with dark power.

	-- Treesitter
	use({ "nvim-treesitter/nvim-treesitter", run = ":TSUpdate" }) -- Nvim Treesitter configurations and abstraction layer
	use({ "JoosepAlviste/nvim-ts-context-commentstring" }) -- setting the commentstring based on the cursor location in a file.
	use({ "romgrk/nvim-treesitter-context" }) -- show code context
	-- use({ "nvim-treesitter/playground" }) -- View treesitter information directly in Neovim
	use({ "p00f/nvim-ts-rainbow" }) -- Rainbow parentheses

	-- UI
	use({ "psliwka/vim-smoothie" }) -- page scroll smoothly
	use({ "kyazdani42/nvim-web-devicons" }) -- a lua fork from vim-devicons
	use({ "kyazdani42/nvim-tree.lua" }) -- file explorer
	use({ "akinsho/bufferline.nvim" }) -- buffer line plugin
	use({ "nvim-lualine/lualine.nvim" }) -- statusline plugin
	use({ "goolord/alpha-nvim" }) -- a lua powered greeter
	use({ "lukas-reineke/indent-blankline.nvim" }) -- Indent guides for Neovim
	use({ "SmiteshP/nvim-gps" }) -- Simple statusline component that show code context
	use({ "mbbill/undotree", cmd = "UndotreeToggle" }) -- undo history visualizer
	-- use { 'sindrets/diffview.nvim', requires = 'nvim-lua/plenary.nvim' }
	use({ "norcalli/nvim-colorizer.lua", ft = { "css", "javascript", "html" }, config = configs.colorizer }) -- The fastest Neovim colorizer.
	use({
		"folke/trouble.nvim",
		requires = "kyazdani42/nvim-web-devicons",
	}) -- A pretty diagnostics, references, telescope results, quickfix and location list to help you solve all the trouble your code is causing
	use({ "stevearc/dressing.nvim" }) -- Neovim plugin to improve the default vim.ui interfaces
	use({ "rcarriga/nvim-notify" }) -- A fancy, configurable, notification manager for NeoVim
	-- use({ "kwkarlwang/bufresize.nvim" }) -- Keep buffer dimensions in proportion when terminal window is resized
	use({
		"gelguy/wilder.nvim",
		requires = {
			{ "romgrk/fzy-lua-native", run = "make" },
			-- NOTE: cpsm require compile manually, run `cd ~/.local/share/nvim/site/pack/packer/start/cpsm && ./install.sh`
			{ "nixprime/cpsm" },
		},
	}) -- A more adventurous wildmenu

	-- Automatically set up your configuration after cloning packer.nvim
	-- Put this at the end after all plugins
	if PACKER_BOOTSTRAP then
		require("packer").sync()
	end
end)
