local templates = vim.fn.stdpath("config") .. "/templates"

-- enable auto init file
vim.g.tmpl_auto_initialize = 1

-- add global search path
vim.g.tmpl_search_paths = { templates }
