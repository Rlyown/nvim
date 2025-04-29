vim.loader.enable(true)

require("core.keymaps")
require("core.lazy")
require("core.options")
require("core.autocommands")

require("core.gvariable").setup()

-- TODO: make a appImage version

-- TODO: use lazy.nvim keys to replace which-key.nvim setup. (which-key can reaad keys info)
