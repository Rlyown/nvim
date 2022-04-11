local hop_status_ok, hop = pcall(require, "hop")
if not hop_status_ok then
	return
end

hop.setup({
	teasing = false, -- Hop should tease you when you do something you are not supposed to
	jump_on_sole_occurrence = true,
	direction = nil,
	inclusive_jump = false,
	uppercase_labels = false,
	char2_fallback_key = nil,
	multi_windows = false, -- Enable cross-windows support and hint all the currently visible windows.
})
