M = {}

M.path = {}

M.path.template = vim.fn.stdpath("config") .. "/template"
M.path.clangd_template = M.path.template .. "/clangd"

function M.setup()
	vim.g.python3_host_prog = "/opt/homebrew/bin/python3" -- specify the python3 path if there are multiple versions

	-- If you want to toggle git-editor with current nvim instead of a nested one after ":terminal", you can uncomment the following settings
	-- if vim.fn.has("nvim") and vim.fn.executable("nvr") then
	-- 	vim.cmd([[let $GIT_EDITOR = "nvr -cc split --remote-wait +'set bufhidden=delete'" ]])
	-- end
end

return M
