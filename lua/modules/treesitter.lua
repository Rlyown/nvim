local status_ok, configs = pcall(require, "nvim-treesitter.configs")
if not status_ok then
	return
end

configs.setup({
	ensure_installed = "all", -- one of "all", or a list of languages
	sync_install = false, -- install languages synchronously (only applied to `ensure_installed`)
	ignore_install = { "swift" }, -- List of parsers to ignore installing
	autopairs = {
		enable = true,
	},
	highlight = {
		enable = true, -- false will disable the whole extension
		disable = { "" }, -- list of language that will be disabled
		additional_vim_regex_highlighting = true,
	},
	indent = { enable = true, disable = { "python", "yaml" } },
	context_commentstring = {
		enable = true,
		enable_autocmd = false,
	},
	-- playground = {
	-- 	enable = true,
	-- 	disable = {},
	-- 	updatetime = 25, -- Debounced time for highlighting nodes in the playground from source code
	-- 	persist_queries = false, -- Whether the query persists across vim sessions
	-- 	keybindings = {
	-- 		toggle_query_editor = "o",
	-- 		toggle_hl_groups = "i",
	-- 		toggle_injected_languages = "t",
	-- 		toggle_anonymous_nodes = "a",
	-- 		toggle_language_display = "I",
	-- 		focus_language = "f",
	-- 		unfocus_language = "F",
	-- 		update = "R",
	-- 		goto_node = "<cr>",
	-- 		show_help = "?",
	-- 	},
	-- },
	rainbow = {
		enable = true,
		-- disable = { "jsx", "cpp" }, list of languages you want to disable the plugin for
		extended_mode = true, -- Also highlight non-bracket delimiters like html tags, boolean or table: lang -> boolean
		max_file_lines = 3000, -- Do not enable for files with more than n lines, int
		-- Colors will be changed by catppuccin plugin.
		-- Disable option in catppuccin to custom it.
		colors = {
			"#CCFFFF",
			"#0066CC",
			"#CCFFCC",
			"#6666CC",
			"#EE9999",
			"#99EE99",
			"#996633",
			-- "#696900",
			-- "#EFBF8F",
		}, -- table of hex strings
		-- termcolors = {} -- table of colour name strings
	},
})
