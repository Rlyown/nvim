return function()
	local neorg_dir = require("core.gvariable").neorg_dir

	require("neorg").setup({
		load = {
			["core.defaults"] = {},
			["core.keybinds"] = {
				config = {
					default_keybinds = false,
				},
				neorg_leader = "<Leader>N",
				hook = function(keybinds)
					local leader = keybinds.leader

					-- Map all the below keybinds only when the "norg" mode is active
					keybinds.map_event_to_mode("norg", {
						n = {
							-- Marks the task under the cursor as "undone"
							-- ^mark Task as Undone
							{ leader .. "gu", "core.norg.qol.todo_items.todo.task_undone" },

							-- Marks the task under the cursor as "pending"
							-- ^mark Task as Pending
							{ leader .. "gp", "core.norg.qol.todo_items.todo.task_pending" },

							-- Marks the task under the cursor as "done"
							-- ^mark Task as Done
							{ leader .. "gd", "core.norg.qol.todo_items.todo.task_done" },

							-- Marks the task under the cursor as "on_hold"
							-- ^mark Task as on Hold
							{ leader .. "gh", "core.norg.qol.todo_items.todo.task_on_hold" },

							-- Marks the task under the cursor as "cancelled"
							-- ^mark Task as Cancelled
							{ leader .. "gc", "core.norg.qol.todo_items.todo.task_cancelled" },

							-- Marks the task under the cursor as "recurring"
							-- ^mark Task as Recurring
							{ leader .. "gr", "core.norg.qol.todo_items.todo.task_recurring" },

							-- Marks the task under the cursor as "important"
							-- ^mark Task as Important
							{ leader .. "gi", "core.norg.qol.todo_items.todo.task_important" },

							-- Switches the task under the cursor between a select few states
							{ leader .. "gn", "core.norg.qol.todo_items.todo.task_cycle" },

							-- Creates a new .norg file to take notes in
							-- ^New Note
							{ leader .. "n", "core.norg.dirman.new.note" },

							-- Hop to the destination of the link under the cursor
							--[[ { "<CR>", "core.norg.esupports.hop.follow_link" }, ]]
							{ "<CR>", "core.norg.esupports.hop.hop-link", "vsplit" },
							{ leader .. "h", "core.norg.esupports.hop.follow_link" },
							--[[ { leader .. "hd", "core.norg.esupports.hop.hop-link" }, ]]
							--[[ { leader .. "hf", "core.norg.esupports.hop.hop-link" }, ]]
							--[[ { leader .. "hF", "core.norg.esupports.hop.hop-link" }, ]]

							-- Same as `<CR>`, except opens the destination in a vertical split
							--[[ { "<M-CR>", "core.norg.esupports.hop.hop-link", "vsplit" }, ]]

							{ ">.", "core.promo.promote" },
							{ "<,", "core.promo.demote" },

							{ ">>", "core.promo.promote", "nested" },
							{ "<<", "core.promo.demote", "nested" },
						},

						--[[ i = { ]]
						--[[     { "<C-t>", "core.promo.promote" }, ]]
						--[[     { "<C-d>", "core.promo.demote" }, ]]
						--[[     { "<M-CR>", "core.itero.next-iteration" }, ]]
						--[[ }, ]]

						-- TODO: Readd these
						-- v = {
						--     { ">>", ":<cr><cmd>Neorg keybind all core.promo.promote_range<cr>" },
						--     { "<<", ":<cr><cmd>Neorg keybind all core.promo.demote_range<cr>" },
						-- },
					}, {
						silent = true,
						noremap = true,
					})

					-- Map the below keys only when traverse-heading mode is active
					keybinds.map_event_to_mode("traverse-heading", {
						n = {
							-- Move to the next heading in the document
							{ "j", "core.integrations.treesitter.next.heading" },

							-- Move to the previous heading in the document
							{ "k", "core.integrations.treesitter.previous.heading" },
						},
					}, {
						silent = true,
						noremap = true,
					})

					keybinds.map_event_to_mode("toc-split", {
						n = {
							-- Hop to the target of the TOC link
							{ "<CR>", "core.norg.qol.toc.hop-toc-link" },

							-- Closes the TOC split
							-- ^Quit
							{ "q", "core.norg.qol.toc.close" },

							-- Closes the TOC split
							-- ^escape
							{ "<Esc>", "core.norg.qol.toc.close" },
						},
					}, {
						silent = true,
						noremap = true,
						nowait = true,
					})

					-- Map the below keys on presenter mode
					keybinds.map_event_to_mode("presenter", {
						n = {
							{ "<CR>", "core.presenter.next_page" },
							{ "l", "core.presenter.next_page" },
							{ "h", "core.presenter.previous_page" },

							-- Keys for closing the current display
							{ "q", "core.presenter.close" },
							{ "<Esc>", "core.presenter.close" },
						},
					}, {
						silent = true,
						noremap = true,
						nowait = true,
					})
					-- Apply the below keys to all modes
					keybinds.map_to_mode("all", {
						n = {
							{ leader .. "mn", ":Neorg mode norg<CR>" },
							{ leader .. "mh", ":Neorg mode traverse-heading<CR>" },
							{ leader .. "o", ":Neorg toc split<CR>" },
						},
					}, {
						silent = true,
						noremap = true,
					})
				end,
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
		},
	})
end
