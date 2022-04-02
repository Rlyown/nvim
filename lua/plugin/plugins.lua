local fn = vim.fn

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
	use({ "f3fora/cmp-spell" }) -- spell source for nvim-cmp
	-- use "github/copilot.vim" -- gitHub Copilot
	-- use "hrsh7th/cmp-copilot" -- this is a experimental product

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
	use({ "stevearc/aerial.nvim" }) -- code outline window
	use({ "ThePrimeagen/refactoring.nvim" }) -- The Refactoring library

	-- Project
	use({ "ahmedkhalf/project.nvim" }) -- superior project management
	use({ "Shatur/neovim-session-manager" }) -- A simple wrapper around :mksession

	-- Snippets
	use({ "L3MON4D3/LuaSnip" }) --snippet engine
	use({ "rafamadriz/friendly-snippets" }) -- a bunch of snippets to use

	-- Telescope
	use({ "nvim-telescope/telescope.nvim" }) -- Find, Filter, Preview, Pick.
	use({ "nvim-telescope/telescope-fzf-native.nvim", run = "make" }) -- FZF sorter for telescope
	use({ "nvim-telescope/telescope-ui-select.nvim" }) -- It sets vim.ui.select to telescope
	use({ "nvim-telescope/telescope-frecency.nvim", requires = { "tami5/sqlite.lua" } }) -- offers intelligent prioritization
	use({ "nvim-telescope/telescope-file-browser.nvim" }) -- File Browser extension

	-- Terminal
	use({ "akinsho/toggleterm.nvim" }) -- easily manage multiple terminal windows

	-- Tools
	use({ "wbthomason/packer.nvim" }) -- Have packer manage itself
	use({ "nvim-lua/popup.nvim" }) -- An implementation of the Popup API from vim in Neovim
	use({ "nvim-lua/plenary.nvim" }) -- Useful lua functions used ny lots of plugins
	use({ "windwp/nvim-autopairs" }) -- Autopairs, integrates with both cmp and treesitter
	use({ "numToStr/Comment.nvim" }) -- Easily comment stuff
	use({ "famiu/bufdelete.nvim", cmd = { "Bdelete", "Bwipeout", "Bdelete!", "Bwipeout!" } }) -- delete buffers (close files) without closing your windows or messing up your layout
	use({ "lewis6991/impatient.nvim" }) -- Improve startup time for Neovim
	use({ "folke/which-key.nvim" }) -- Create key bindings that stick.
	use({ "tpope/vim-repeat" }) -- enable repeating supported plugin maps with "."
	use({ "tpope/vim-surround" }) -- all about "surroundings": parentheses, brackets, quotes, XML tags, and more
	use({ "michaelb/sniprun", run = "bash ./install.sh", cmd = { "SnipRun", "'<,'>SnipRun", "SnipInfo" } }) -- run lines/blocs of code
	use({ "nathom/filetype.nvim" }) -- A faster version of filetype.vim
	use({ "dstein64/vim-startuptime" }) -- A Vim plugin for profiling Vim's startup time
	-- use({ "Pocco81/AutoSave.nvim" }) -- enable autosave
	use({ "AndrewRadev/splitjoin.vim" }) -- Switch between single-line and multiline forms of code
	use({ "iamcco/markdown-preview.nvim", run = "cd app && yarn install ", ft = "markdown" }) -- markdown preview plugin

	-- Treesitter
	use({ "nvim-treesitter/nvim-treesitter", run = ":TSUpdate" }) -- Nvim Treesitter configurations and abstraction layer
	use({ "JoosepAlviste/nvim-ts-context-commentstring" }) -- setting the commentstring based on the cursor location in a file.
	use({ "romgrk/nvim-treesitter-context" }) -- show code context
	-- use({ "nvim-treesitter/playground" }) -- View treesitter information directly in Neovim

	-- UI
	use({ "psliwka/vim-smoothie" }) -- page scroll smoothly
	use({ "kyazdani42/nvim-web-devicons" }) -- a lua fork from vim-devicons
	use({ "kyazdani42/nvim-tree.lua" }) -- file explorer
	use({ "akinsho/bufferline.nvim" }) -- buffer line plugin
	use({ "arkav/lualine-lsp-progress" })
	use({ "nvim-lualine/lualine.nvim" }) -- statusline plugin
	use({ "goolord/alpha-nvim" }) -- a lua powered greeter
	use({ "lukas-reineke/indent-blankline.nvim" }) -- Indent guides for Neovim
	use({ "SmiteshP/nvim-gps" }) -- Simple statusline component that show code context
	use({ "mbbill/undotree", cmd = "UndotreeToggle" }) -- undo history visualizer
	-- use "gelguy/wilder.nvim" -- A more adventurous wildmenu
	-- use { 'sindrets/diffview.nvim', requires = 'nvim-lua/plenary.nvim' }
	use({ "norcalli/nvim-colorizer.lua", ft = { "css", "javascript", "html" } }) -- The fastest Neovim colorizer.

	-- Automatically set up your configuration after cloning packer.nvim
	-- Put this at the end after all plugins
	if PACKER_BOOTSTRAP then
		require("packer").sync()
	end
end)
