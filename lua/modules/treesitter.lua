return function()
	local configs = require("nvim-treesitter.configs")

	configs.setup({
		ensure_installed = "all", -- one of "all", or a list of languages
		sync_install = false, -- install languages synchronously (only applied to `ensure_installed`)
		ignore_install = { "swift", "phpdoc" }, -- List of parsers to ignore installing
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
		playground = {
			enable = true,
			disable = {},
			updatetime = 25, -- Debounced time for highlighting nodes in the playground from source code
			persist_queries = false, -- Whether the query persists across vim sessions
			keybindings = {
				toggle_query_editor = "o",
				toggle_hl_groups = "i",
				toggle_injected_languages = "t",
				toggle_anonymous_nodes = "a",
				toggle_language_display = "I",
				focus_language = "f",
				unfocus_language = "F",
				update = "R",
				goto_node = "<cr>",
				show_help = "?",
			},
		},
		rainbow = {
			-- TODO: disable it for large file
			rainbow = {
				enable = true,
				-- list of languages you want to disable the plugin for
				-- disable = { "jsx", "cpp" },
				-- Which query to use for finding delimiters
				query = "rainbow-parens",
				-- Highlight the entire buffer all at once
				strategy = require("ts-rainbow").strategy.global,
			},
		},
		matchup = {
			enable = true, -- mandatory, false will disable the whole extension
			--[[ disable = { "c", "ruby" }, -- optional, list of language that will be disabled ]]
			-- [options]
		},
		autotag = {
			enable = true,
		},
	})
end
