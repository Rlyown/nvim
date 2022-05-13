-- Setup nvim-cmp.
local status_ok, npairs = pcall(require, "nvim-autopairs")
if not status_ok then
	return
end

npairs.setup({
	check_ts = true,
	ts_config = {
		lua = { "string", "source" }, -- it will not add a pair on that treesitter node
		javascript = { "string", "template_string" },
		java = false, -- don't check treesitter on java
	},
	disable_filetype = {
		"Outline",
		"TelescopePrompt",
		"spectre_panel",
		"dap-repl",
	},
	fast_wrap = {
		map = "<M-e>",
		chars = { "{", "[", "(", '"', "'" },
		pattern = string.gsub([[ [%'%"%)%>%]%)%}%,] ]], "%s+", ""),
		offset = 0, -- Offset from pattern match
		end_key = "$",
		keys = "qwertyuiopzxcvbnmasdfghjkl",
		check_comma = true,
		highlight = "PmenuSel",
		highlight_grey = "LineNr",
	},
	disable_in_macro = false,
	enable_check_bracket_line = true,
})
