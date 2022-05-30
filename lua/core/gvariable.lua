local M = {}

-- path to debuggers
M.debuggers = {}

if vim.fn.has("mac") == 1 then
	M.os = "mac"
	M.debuggers.lldb_vscode = "/opt/homebrew/opt/llvm/bin/lldb-vscode"
	M.debuggers.debugpy = "/opt/homebrew/Caskroom/miniforge/base/envs/debugpy/bin/python3"
elseif vim.fn.has("unix") == 1 then
	M.os = "unix"
	M.debuggers.lldb_vscode = "/usr/bin/lldb-vscode-14"
	M.debuggers.debugpy = "/usr/bin/python3"
else
	M.os = "unsupport"
	M.debuggers.lldb_vscode = "lldb-vscode"
	M.debuggers.debugpy = "python3"
end

M.debuggers.delve = "dlv"

M.modules_dir = vim.fn.stdpath("config") .. "/lua/modules"
M.lazymod_configs = require("lazymods.configs")
-- M.debuggers.dapinstall_dir = vim.fn.stdpath("data") .. "/dapinstall"

-- Set the python3 path which installed pynvim
vim.g.python3_host_prog = M.debuggers.debugpy

M.fn = {
	["async_ui_input_wrap"] = function()
		local async = require("plenary.async")

		return async.wrap(function(opts, callback)
			vim.ui.input(opts, callback)
		end, 2)
	end,
	["rev_table"] = function(t, islist)
		local rev_t = {}

		for k, name in pairs(t) do
			if islist then
				rev_t[name] = true
			else
				rev_t[name] = k
			end
		end
		return rev_t
	end,
	["split"] = function(szFullString, szSeparator)
		local nFindStartIndex = 1
		local nSplitIndex = 1
		local nSplitArray = {}
		while true do
			local nFindLastIndex = string.find(szFullString, szSeparator, nFindStartIndex)
			if not nFindLastIndex then
				nSplitArray[nSplitIndex] = string.sub(szFullString, nFindStartIndex, string.len(szFullString))
				break
			end
			nSplitArray[nSplitIndex] = string.sub(szFullString, nFindStartIndex, nFindLastIndex - 1)
			nFindStartIndex = nFindLastIndex + string.len(szSeparator)
			nSplitIndex = nSplitIndex + 1
		end
		return nSplitArray
	end,
	["args_parse"] = function(szFullString, szSeparator)
		local nFindStartIndex = 1
		local nQuoteType = ""
		local hasSlash = false
		local lastSeparator = false
		local nSplitArray = {}
		local i = 1

		local msg = "Get Args:"
		local format_template = "\n  [%d] %s"

		if not szFullString or not szSeparator or #szSeparator > 1 or #szFullString == 0 then
			return nSplitArray
		end

		while true do
			local ch = szFullString:sub(i, i)
			local byte = string.byte(ch)

			if byte > 128 then
				i = i + 3
			else
				if ch == '"' or ch == "'" then
					lastSeparator = false
					if hasSlash then
						hasSlash = false
					elseif nQuoteType == "" then
						nQuoteType = ch
						nFindStartIndex = i
					elseif nQuoteType == ch then
						nQuoteType = ""
					end
				elseif ch == "\\" then
					lastSeparator = false
					hasSlash = not hasSlash
				elseif ch == szSeparator then
					if i == 1 then
						lastSeparator = true
					elseif not lastSeparator then
						if nQuoteType == "" then
							lastSeparator = true
							local start_ch = szFullString:sub(nFindStartIndex, nFindStartIndex)
							if start_ch == '"' or start_ch == "'" then
								nSplitArray[#nSplitArray + 1] = szFullString:sub(nFindStartIndex + 1, i - 2)
								msg = msg .. string.format(format_template, #nSplitArray, nSplitArray[#nSplitArray])
							else
								nSplitArray[#nSplitArray + 1] = szFullString:sub(nFindStartIndex, i - 1)
								msg = msg .. string.format(format_template, #nSplitArray, nSplitArray[#nSplitArray])
							end
						end
					end
				else
					if lastSeparator then
						nFindStartIndex = i
					end
					lastSeparator = false
					if hasSlash then
						hasSlash = false
					end
				end
				i = i + 1
			end

			if i > #szFullString then
				if not lastSeparator then
					local start_ch = szFullString:sub(nFindStartIndex, nFindStartIndex)
					if start_ch == '"' or start_ch == "'" then
						nSplitArray[#nSplitArray + 1] = szFullString:sub(nFindStartIndex + 1, i - 2)
						msg = msg .. string.format(format_template, #nSplitArray, nSplitArray[#nSplitArray])
					else
						nSplitArray[#nSplitArray + 1] = szFullString:sub(nFindStartIndex, i - 1)
						msg = msg .. string.format(format_template, #nSplitArray, nSplitArray[#nSplitArray])
					end
				end
				break
			end
		end
		vim.notify(msg, "info", { title = "function args_parse" })
		return nSplitArray
	end,
	["get_random_int"] = function(min, max)
		math.randomseed(tostring(os.time()):reverse():sub(1, 6))
		return math.random(min, max)
	end,
}
M.symbol_map = {
	Text = "",
	Method = "",
	Function = "",
	Constructor = "",
	Field = "ﰠ",
	Variable = "",
	Class = "ﴯ",
	Interface = "",
	Module = "",
	Property = "ﰠ",
	Unit = "塞",
	Value = "",
	Enum = "",
	Keyword = "",
	Snippet = "",
	Color = "",
	File = "",
	Reference = "",
	Folder = "",
	EnumMember = "",
	Constant = "",
	Struct = "פּ",
	Event = "",
	Operator = "",
	TypeParameter = "",
	Namespace = "",
	Package = "",
	String = "",
	Number = "",
	Boolean = "⊨",
	Array = "",
	Object = "⦿",
}

-- This function will be called at the end of init.lua
function M.setup()
	-- custom variable to enable or disable auto format by default.
	-- You can toggle it with keybinding <leader>lF
	vim.g.custom_enable_auto_format = true

	-- enable/disable option runInTerminal for dap lldb
	vim.g.custom_lldb_run_in_terminal = false

	-- set default colorscheme
	local catppuccin_status_ok, _ = pcall(require, "catppuccin")
	if catppuccin_status_ok then
		vim.g.catppuccin_flavour = "mocha" -- latte, frappe, macchiato, mocha
		vim.cmd([[colorscheme catppuccin]])
	end

	-- set default notify function
	local notify_status_ok, notify = pcall(require, "notify")
	if notify_status_ok then
		vim.notify = notify
	end

	-- If you want to toggle git-editor with current nvim instead of a nested one after ":terminal",
	-- you can uncomment the following settings(tool "neovim-remote" is required):
	-- if vim.fn.has("nvim") and vim.fn.executable("nvr") then
	-- 	vim.cmd([[let $GIT_EDITOR = "nvr -cc split --remote-wait +'set bufhidden=delete'" ]])
	-- end
end

return M
