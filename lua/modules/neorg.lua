return function()
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
					index = "index.norg", -- The name of the main (root) .norg file
				},
			},
			["core.norg.completion"] = {
				config = { -- Note that this table is optional and doesn't need to be provided
					-- Configuration here
					engine = "nvim-cmp",
				},
			},
			["core.norg.concealer"] = {},
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
		},
	})
end
