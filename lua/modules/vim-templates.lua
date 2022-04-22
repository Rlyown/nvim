-- placeholder: https://github.com/tibabit/vim-templates
local templates = vim.fn.stdpath("config") .. "/templates"

-- enable auto init file
vim.g.tmpl_auto_initialize = 1
-- add global search path
vim.g.tmpl_search_paths = { templates }

-- default author name
-- vim.g.tmpl_author_name = ""
-- default host name
-- vim.g.tmpl_author_hostname = ""
-- default email
-- vim.g.tmpl_author_email = ""
