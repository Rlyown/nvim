vim.loader.enable(true)

require("core.keymaps")
require("core.lazy")
require("core.options")
require("core.autocommands")

-- Load the global variable setup
require("core.gvariable").setup()

-- vim.lsp.set_log_level("debug")

-- TODO: make a appImage versio
