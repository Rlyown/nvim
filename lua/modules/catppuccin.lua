local catppuccin_status_ok, catppuccin = pcall(require, "catppuccin")
if not catppuccin_status_ok then
	return
end

-- configure it
catppuccin.setup({
	transparent_background = false,
	term_colors = true,
	integrations = {
		lsp_trouble = true,
		nvimtree = {
			enabled = true,
			show_root = true,
			transparent_panel = false,
		},
		which_key = true,
		-- This option will override ts_rainbow colors in treesitter.lua
		ts_rainbow = true,
	},
})
