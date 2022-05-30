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
