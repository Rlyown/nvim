local root = vim.fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":p:h")
vim.opt.rtp:prepend(root)
vim.loader.enable(true)
require("config").get()
vim.g.mapleader = ","
vim.g.maplocalleader = " "
require("core.options")
require("core.keymaps")
require("core.autocommands")
require("config.commands").setup()
require("core.lazy")
