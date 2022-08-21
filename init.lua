-- set plugins first to enable auto-installation
require("plugin.plugins")
require("core.options")
require("core.keymaps")
require("core.autocommands")

-- impatient needs to be setup before any other lua plugin is loaded
require("impatient")

-- Add config file name which should be ignored, and set value to "true"
-- other files will be called by default.
-- Set the plugins load orders, if needed.
-- Note: Set the name of all plugins to key to avoid performing reverse table
require("modules").setup({
	ignore = { "alpha_banner_info", "autosave", "project" },
})

require("core.gvariable").setup()

-- TODO: https://github.com/williamboman/mason.nvim
-- TODO: https://github.com/kevinhwang91/nvim-ufo
-- TODO: https://github.com/gbprod/yanky.nvim
-- TODO: https://github.com/nvim-neorg/neorg
-- TODO: https://github.com/nvim-orgmode/orgmode
-- TODO: https://github.com/sindrets/diffview.nvim
-- TODO: https://github.com/ray-x/navigator.lua
-- TODO: https://github.com/kwkarlwang/bufjump.nvim
-- TODO: I want to create a plugin working for project template generation. And it also support build config for auto-build and quick-run.
-- TODO: https://rumpelsepp.org/blog/nvim-clipboard-through-ssh/
-- TODO: https://github.com/ojroques/vim-oscyank
-- TODO: all in one package
