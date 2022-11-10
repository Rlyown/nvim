-- impatient needs to be setup before any other lua plugin is loaded
pcall(require, "impatient")

-- set plugins first to enable auto-installation
require("plugin.plugins")
require("core.options")
require("core.keymaps")
require("core.autocommands")

require("core.gvariable").setup()
