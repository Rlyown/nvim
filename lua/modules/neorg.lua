return function()
	local neorg_dir = require("core.gvariable").neorg_dir

	require("neorg").setup({
		load = {
			["core.defaults"] = {},
			["core.keybinds"] = {
				config = {
					default_keybinds = true,
					neorg_leader = "<Leader>N",
					hook = function(keybinds)
						local leader = keybinds.leader
						-- Marks the task under the cursor as "undone"
						keybinds.remap_key("norg", "n", "gtu", leader .. "gu")

						-- Marks the task under the cursor as "pending"
						keybinds.remap_key("norg", "n", "gtp", leader .. "gp")

						-- Marks the task under the cursor as "done"
						keybinds.remap_key("norg", "n", "gtd", leader .. "gd")

						-- Marks the task under the cursor as "on_hold"
						keybinds.remap_key("norg", "n", "gth", leader .. "gh")

						-- Marks the task under the cursor as "cancelled"
						keybinds.remap_key("norg", "n", "gtc", leader .. "gc")

						-- Marks the task under the cursor as "recurring"
						keybinds.remap_key("norg", "n", "gtr", leader .. "gr")

						-- Marks the task under the cursor as "important"
						keybinds.remap_key("norg", "n", "gti", leader .. "gi")

						-- Switches the task under the cursor between a select few states
						keybinds.remap_key("norg", "n", "<C-Space>", leader .. "gn")
					end,
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
