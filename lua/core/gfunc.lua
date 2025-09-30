local M = {}

M.fn = {
    ["async_ui_input_wrap"] = function()
        local async = require("plenary.async")

        return async.wrap(function(opts, callback)
            vim.ui.input(opts, callback)
        end, 2)
    end,
    ["async_ui_select_wrap"] = function()
        local async = require("plenary.async")

        return async.wrap(function(items, opts, callback)
            vim.ui.select(items, opts, callback)
        end, 3)
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
        vim.notify(msg, vim.log.levels.INFO, { title = "function args_parse" })
        return nSplitArray
    end,
    ["get_random_int"] = function(min, max)
        math.randomseed(tonumber(tostring(os.time()):reverse():sub(1, 6)))
        return math.random(min, max)
    end,
    ["system"] = function(command)
        local command_info
        local command_info_fd = io.popen(command, "r")
        if command_info_fd then
            while true do
                command_info = command_info_fd:read("*l")
                if command_info then
                    break
                end
                if not command_info then
                    command_info = ""
                    break
                end
            end
            command_info_fd:close()
        end
        return command_info
    end,
    ["disable_check_buf"] = function(buf, size, lines)
        local bufnr = 0
        if buf ~= nil then
            bufnr = buf
        end


        local max_filesize = 1 * 1024 * 1024 -- 1MB
        if size ~= nil then
            max_filesize = size
        end


        local max_lines = 10000
        if lines ~= nil then
            max_lines = lines
        end


        local ok, stats = pcall(vim.uv.fs_stat, vim.api.nvim_buf_get_name(bufnr))
        if ok and stats then
            if stats.size > max_filesize then
                return true
            end

            if stats.size == 0 then
                return false
            end

            local filetype = vim.filetype.match({ buf = bufnr })
            local file_contents = vim.fn.readfile(vim.api.nvim_buf_get_name(bufnr))
            local file_length = #file_contents

            if file_length > max_lines then
                return true
            end
        end

        return false
    end,
    ['filetype_check'] = function(buf, ft_list)
        local ft = vim.bo[buf].ft
        if type(ft_list) == "string" then
            if ft == ft_list then
                return true
            end
        elseif type(ft_list) == "table" then
            for _, v in ipairs(ft_list) do
                if ft == v then
                    return true
                end
            end
        end

        return false
    end,
}
return M
