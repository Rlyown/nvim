require("plugin.plugins")
require("core.options")
require("core.keymaps")
require("core.autocommands")

-- add config file name which should be ignored, and set value to "true"
-- other files will be called by default
require("modules").setup({ ignore = { "autosave" } })

require("core.gvarible").setup()

-- TODO: I want to use a template plugin base on lua, instead of vimscript.
