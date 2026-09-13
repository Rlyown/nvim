local M = { entries = {} }
vim.api.nvim_create_autocmd("VimLeavePre", {
    group = vim.api.nvim_create_augroup("ConfigTerminalExit", { clear = true }),
    callback = function()
        for _, entry in pairs(M.entries) do
            if vim.api.nvim_buf_is_valid(entry.term.buf) then
                local job = vim.b[entry.term.buf].terminal_job_id
                if job then pcall(vim.fn.jobstop, job) end
            end
        end
    end,
})
local layouts = {
    horizontal = { position = "bottom", height = 0.3, width = 0 },
    vertical = { position = "right", width = 0.4, height = 0 },
    float = { position = "float", width = 0.8, height = 0.8 },
}
function M.get(id)
    id = id or vim.v.count1
    assert(type(id) == "number" and id >= 1 and id % 1 == 0, "Terminal ID must be a positive integer")
    local entry = M.entries[id]
    if not entry then
        entry = { cwd = vim.fn.getcwd(), layout = "horizontal" }
        entry.term = Snacks.terminal.open(nil, {
            cwd = entry.cwd, count = id, auto_close = false, auto_insert = false,
            win = vim.deepcopy(layouts.horizontal),
        })
        -- 固定版本的 Snacks 在 ExitPre 删除窗口会中断 Neovim 0.12 的退出。
        -- 由适配层在 VimLeavePre 停止进程，退出期间不再修改窗口布局。
        entry.term.events = vim.tbl_filter(function(event) return event.event ~= "ExitPre" end, entry.term.events)
        vim.api.nvim_clear_autocmds({ group = entry.term.augroup, event = "ExitPre" })
        M.entries[id] = entry
    end
    return entry
end
function M.hide(id)
    local e = M.entries[id]
    if not e then return end
    if e.tabwin and vim.api.nvim_win_is_valid(e.tabwin) then
        vim.api.nvim_win_close(e.tabwin, true)
    end
    e.tabwin = nil
    e.term:hide()
end
function M.show(id, layout)
    local e = M.get(id)
    if not vim.api.nvim_buf_is_valid(e.term.buf) then
        vim.notify("Terminal buffer is no longer valid; use a new ID", vim.log.levels.WARN)
        return
    end
    M.hide(id)
    e.layout = layout or e.layout
    if e.layout == "tab" then
        vim.cmd.tabnew()
        local scratch = vim.api.nvim_get_current_buf()
        vim.api.nvim_win_set_buf(0, e.term.buf)
        vim.api.nvim_buf_delete(scratch, { force = true })
        e.tabwin = vim.api.nvim_get_current_win()
    else
        assert(layouts[e.layout], "Unknown terminal layout")
        e.term.opts = vim.tbl_deep_extend("force", e.term.opts, layouts[e.layout])
        e.term:show()
        e.term:focus()
    end
    return e
end
function M.toggle(id, layout)
    id = id or vim.v.count1
    local e = M.entries[id]
    if e and (e.term:valid() or (e.tabwin and vim.api.nvim_win_is_valid(e.tabwin))) and (not layout or e.layout == layout) then
        M.hide(id)
    else M.show(id, layout) end
end
function M.toggle_all()
    local visible = false
    for _, e in pairs(M.entries) do visible = visible or e.term:valid() or (e.tabwin and vim.api.nvim_win_is_valid(e.tabwin)) end
    for id in pairs(M.entries) do if visible then M.hide(id) else M.show(id) end end
end
function M.send(id, text)
    local e = M.entries[id]
    if not e or not vim.api.nvim_buf_is_valid(e.term.buf) then
        vim.notify("Target terminal does not exist; create ID " .. id .. " first", vim.log.levels.WARN); return false
    end
    local job = vim.b[e.term.buf].terminal_job_id
    if not job or vim.fn.jobwait({ job }, 0)[1] ~= -1 then
        vim.notify("Terminal process has exited; code was not sent", vim.log.levels.WARN); return false
    end
    vim.api.nvim_chan_send(job, text .. "\n")
    return true
end
function M.capture(mode)
    if mode == "line" then return vim.api.nvim_get_current_line() end
    local start, finish = vim.fn.getpos("v"), vim.fn.getpos(".")
    local kind = mode == "lines" and "V" or vim.fn.mode()
    return table.concat(vim.fn.getregion(start, finish, { type = kind, exclusive = vim.o.selection == "exclusive" }), "\n")
end
function M.prompt_send(mode)
    local text = M.capture(mode)
    vim.ui.input({ prompt = "Target terminal ID: ", default = "1" }, function(value)
        if not value then return end
        local id = tonumber(value)
        if not id or id < 1 or id % 1 ~= 0 then vim.notify("Invalid terminal ID", vim.log.levels.ERROR); return end
        M.send(id, text)
    end)
end
return M
