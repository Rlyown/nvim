local status_ok, autosave = pcall(require, "autosave")
if not status_ok then
	return
end

-- IMPORTANT: undo will cause file change too! So if want to undo multi-steps, you need type 'u' enough times during debounce_delay time.
autosave.setup({
	enabled = true,
	execution_message = "AutoSave: saved at " .. vim.fn.strftime("%H:%M:%S"),
	events = {
		"InsertLeave",
		"TextChanged",
	},
	conditions = {
		exists = true,
		filename_is_not = { "plugins.lua" },
		filetype_is_not = {},
		modifiable = true, -- sads
	},
	write_all_buffers = false,
	on_off_commands = true,
	clean_command_line_interval = 0,
	debounce_delay = 1500,
})
