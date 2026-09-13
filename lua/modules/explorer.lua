local M = {}
-- 回收失败绝不降级到永久删除。
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
