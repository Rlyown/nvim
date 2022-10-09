local neorg_dir = require("core.gvariable").neorg_dir
require("neorg").setup({
	load = {
		["core.defaults"] = {},
		["core.keybinds"] = {
			config = {
				default_keybinds = false,
			},
		},
		["core.norg.dirman"] = {
			config = {
				workspaces = {
					work = neorg_dir .. "/work",
				},
			},
		},
		["core.gtd.base"] = {
			config = { -- Note that this table is optional and doesn't need to be provided
				-- Configuration here
				workspace = "work",
			},
		},
		["core.norg.completion"] = {
			config = { -- Note that this table is optional and doesn't need to be provided
				-- Configuration here
				engine = "nvim-cmp",
			},
		},
		["core.norg.journal"] = {
			config = { -- Note that this table is optional and doesn't need to be provided
				-- Configuration here
			},
		},
		["core.norg.qol.toc"] = {
			config = { -- Note that this table is optional and doesn't need to be provided
				-- Configuration here
			},
		},
		["core.norg.concealer"] = {
			config = { -- Note that this table is optional and doesn't need to be provided
				-- Configuration here
			},
		},
		["core.presenter"] = {
			config = { -- Note that this table is optional and doesn't need to be provided
				-- Configuration here
				zen_mode = "truezen",
			},
		},
		["core.export"] = {
			config = { -- Note that this table is optional and doesn't need to be provided
				-- Configuration here
			},
		},
		["core.integrations.telescope"] = {},
		["external.gtd-project-tags"] = {},
		["external.context"] = {},
		["external.kanban"] = {},
	},
})
