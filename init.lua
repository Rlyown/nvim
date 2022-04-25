-- set plugins first to enable auto-installation
require("plugin.plugins")
require("core.options")
require("core.keymaps")
require("core.autocommands")

-- impatient needs to be setup before any other lua plugin is loaded
require("impatient")

-- add config file name which should be ignored, and set value to "true"
-- other files will be called by default
require("modules").setup({ ignore = { "autosave" } })

require("core.gvariable").setup()
