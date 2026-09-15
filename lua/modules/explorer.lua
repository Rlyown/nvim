local M = {}
local pickers = {}
local directory_start = false

function M.check_windows()
    if directory_start or vim.v.exiting ~= vim.NIL then return end
    local owned, found = {}, false
    for picker in pairs(pickers) do
        if not picker.closed and picker.layout and picker.layout:valid() then
            found = true
            for _, windows in ipairs({ picker.layout.wins, picker.layout.box_wins }) do
                for _, window in pairs(windows) do
                    if window.win then owned[window.win] = true end
                end
            end
        end
    end
    if not found then return end
    -- Check every tab and preserve unsaved hidden buffers as well as visible ones.
    for _, win in ipairs(vim.api.nvim_list_wins()) do
        if not owned[win] then return end
    end
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        if vim.bo[buf].modified then return end
    end
    pcall(vim.cmd, "qa")
end

function M.on_show(picker)
    pickers[picker] = true
    if directory_start then
        picker.config_directory_start = true
        picker.opts.jump.close = true
    end
end

function M.on_close(picker)
    pickers[picker] = nil
end

function M.setup()
    local args = vim.fn.argv()
    directory_start = #args > 0
    for _, arg in ipairs(args) do
        if vim.fn.isdirectory(arg) ~= 1 then directory_start = false end
    end
    local group = vim.api.nvim_create_augroup("ConfigExplorerLifecycle", { clear = true })
    vim.api.nvim_create_autocmd("VimResized", {
        group = group,
        callback = function()
            vim.schedule(function()
                for picker in pairs(pickers) do
                    if not picker.closed and picker.layout and picker.layout:valid() then
                        vim.api.nvim_win_set_width(picker.layout.root.win, math.max(1, math.floor(vim.o.columns * 0.2)))
                        picker.layout:update()
                    end
                end
            end)
        end,
    })
    vim.api.nvim_create_autocmd({ "WinClosed", "TabClosed" }, {
        group = group,
        callback = function() vim.schedule(M.check_windows) end,
    })
    vim.api.nvim_create_autocmd("BufEnter", {
        group = group,
        callback = function(a)
            local name = vim.api.nvim_buf_get_name(a.buf)
            if directory_start and vim.bo[a.buf].buftype == "" and name ~= "" and vim.fn.isdirectory(name) == 0 then
                directory_start = false
                vim.schedule(function()
                    for picker in pairs(pickers) do
                        if picker.config_directory_start and not picker.closed then picker:close() end
                    end
                end)
            end
        end,
    })
end

-- Never fall back to permanent deletion when trashing fails.
function M.trash(path)
    local command
    if vim.fn.executable("trash") == 1 then command = { "trash", path }
    elseif vim.fn.executable("gio") == 1 then command = { "gio", "trash", path }
    else return false, "Neither trash nor gio is available" end
    local result = vim.system(command, { text = true }):wait()
    return result.code == 0, result.stderr
end
function M.delete(picker, permanent)
    local paths = vim.tbl_map(Snacks.picker.util.path, picker:selected({ fallback = true }))
    if #paths == 0 then return end
    vim.ui.select({ "Cancel", "Confirm" }, { prompt = (permanent and "Permanently delete " or "Move to trash ") .. #paths .. " item(s)?" }, function(choice)
        if choice ~= "Confirm" then return end
        for _, path in ipairs(paths) do
            local ok, err
            if permanent then ok = vim.fn.delete(path, "rf") == 0; err = "Delete failed"
            else ok, err = M.trash(path) end
            if not ok then vim.notify(tostring(err), vim.log.levels.ERROR) end
        end
        require("snacks.explorer.actions").actions.explorer_update(picker)
    end)
end
function M.cut(picker)
    M.clipboard = vim.tbl_map(Snacks.picker.util.path, picker:selected({ fallback = true }))
    vim.notify("Cut " .. #M.clipboard .. " item(s); press p to paste")
end
function M.paste(picker)
    if not M.clipboard then
        require("snacks.explorer.actions").actions.explorer_paste(picker)
        return
    end
    local pending = {}
    for _, source in ipairs(M.clipboard) do
        local destination = vim.fs.joinpath(picker:dir(), vim.fs.basename(source))
        local ok, err
        if vim.uv.fs_stat(destination) then ok, err = false, "Destination already exists: " .. destination
        else ok, err = vim.uv.fs_rename(source, destination) end
        if ok then Snacks.rename.on_rename_file(source, destination)
        else table.insert(pending, source); vim.notify(tostring(err), vim.log.levels.ERROR) end
    end
    M.clipboard = #pending > 0 and pending or nil
    require("snacks.explorer.actions").actions.explorer_update(picker)
end
return M
