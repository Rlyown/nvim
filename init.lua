-- impatient needs to be setup before any other lua plugin is loaded
pcall(require, "impatient")

require("core.keymaps")
require("plugin.plugins")
require("core.options")
require("core.autocommands")

require("core.gvariable").setup()
