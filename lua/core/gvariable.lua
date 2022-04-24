local M = {}

if vim.fn.has("mac") then
	M.os = "mac"
	M.llvm_bin_path = "/opt/homebrew/opt/llvm/bin"
elseif vim.fn.has("unix") then
	M.os = "unix"
	M.llvm_bin_path = "/usr/bin"
else
	M.os = "unsupport"
end

M.modules_dir = vim.fn.stdpath("config") .. "/lua/modules"
M.dapinstall_dir = vim.fn.stdpath("data") .. "/dapinstall"
-- the python path which installed debugpy
if M.os == "mac" then
	M.debugpy_python_path = "/opt/homebrew/Caskroom/miniforge/base/envs/debugpy/bin/python3"
elseif M.os == "unix" then
	M.debugpy_python_path = "/usr/bin/python3"
end

-- this function will be called at the end of init.lua
function M.setup()
	vim.g.python3_host_prog = M.debugpy_python_path -- set the python3 path which installed pynvim

	-- set default colorscheme
	local catppuccin_status_ok, _ = pcall(require, "catppuccin")
	if catppuccin_status_ok then
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
							else
								nSplitArray[#nSplitArray + 1] = szFullString:sub(nFindStartIndex, i - 1)
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
					else
						nSplitArray[#nSplitArray + 1] = szFullString:sub(nFindStartIndex, i - 1)
					end
				end
				break
			end
		end
		return nSplitArray
	end,
}

return M
