vim.loader.enable(true)

require("core.keymaps")
require("core.lazy")
require("core.options")
require("core.autocommands")

require("core.gvariable").setup()

-- TODO: make a appImage version
