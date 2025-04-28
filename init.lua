-- impatient needs to be setup before any other lua plugin is loaded
pcall(require, "impatient")

require("core.keymaps")
require("plugin.plugins")
require("core.options")
require("core.autocommands")

require("core.gvariable").setup()

-- TODO: make a appImage version

-- TODO: use lazy.nvim keys to replace which-key.nvim setup. (which-key can reaad keys info)
