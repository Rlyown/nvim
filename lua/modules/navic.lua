return function()
	local navic = require("nvim-navic")
	local symbols = require("core.gvariable").symbol_map

	local format_symbols = {}
	for key, value in pairs(symbols) do
		format_symbols[key] = value .. " "
	end

	navic.setup({
		icons = format_symbols,
		highlight = true,
		separator = " > ",
		depth_limit = 3,
		depth_limit_indicator = "..",
	})
end
