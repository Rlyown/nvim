local M = {
	-- Dirs
	dap = require("modules.dap"),
	lsp = require("modules.lsp"),

	-- Plugins
	accelerated_jk = require("modules.accelerated-jk"),
	alpha = require("modules.alpha"),
	autolist = require("modules.autolist"),
	autopairs = require("modules.autopairs"),
	bufferline = require("modules.bufferline"),
	catppuccin = require("modules.catppuccin"),
	cmp = require("modules.cmp"),
	colorizer = require("modules.colorizer"),
	comment = require("modules.comment"),
	copilot = require("modules.copilot"),
	crates = require("modules.crates"),
	dash = require("modules.dash"),
	diffview = require("modules.diffview"),
	dressing = require("modules.dressing"),
	filetype = require("modules.filetype"),
	gitsigns = require("modules.gitsigns"),
	hop = require("modules.hop"),
	hydra = require("modules.hydra"),
	indentline = require("modules.indentline"),
	lualine = require("modules.lualine"),
	navic = require("modules.navic"),
	neoclip = require("modules.neoclip"),
	neogit = require("modules.neogit"),
	neorg = require("modules.neorg"),
	neoscroll = require("modules.neoscroll"),
	noice = require("modules.noice"),
	notify = require("modules.notify"),
	nvim_surround = require("modules.nvim-surround"),
	nvim_tree = require("modules.nvim-tree"),
	nvim_gdb = require("modules.nvim_gdb"),
	nvim_lastplace = require("modules.nvim_lastplace"),
	pretty_fold = require("modules.pretty_fold"),
	session_manager = require("modules.session_manager"),
	smartyank = require("modules.smartyank"),
	spectre = require("modules.spectre"),
	spellsitter = require("modules.spellsitter"),
	symbols_outline = require("modules.symbols_outline"),
	telescope = require("modules.telescope"),
	templar = require("modules.templar"),
	tmux = require("modules.tmux"),
	toggleterm = require("modules.toggleterm"),
	treesitter_context = require("modules.treesitter-context"),
	treesitter = require("modules.treesitter"),
	trouble = require("modules.trouble"),
	undotree = require("modules.undotree"),
	whichkey = require("modules.whichkey"),
	wilder = require("modules.wilder"),
	zeavim = require("modules.zeavim"),
}

return M
