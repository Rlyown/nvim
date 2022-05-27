-- Attach to certain Filetypes, add special configuration for `html`
-- Use `background` for everything else.
return function()
	local status_ok, colorizer = pcall(require, "colorizer")
	if not status_ok then
		return
	end
	colorizer.setup({
		"css",
		"javascript",
		html = {
			mode = "foreground",
		},
	})
end
