local ok, err = xpcall(function()
    local scenario = assert(vim.env.EXPLORER_SCENARIO)
    local directory = assert(vim.env.EXPLORER_FIXTURE)
    local function explorer()
        return Snacks.picker.get({ source = "explorer" })[1]
    end
    local picker = explorer() or Snacks.picker.explorer({ cwd = directory })
    picker:show()
    vim.wait(300)
    assert(picker.layout:valid())
    vim.o.columns = 160
    vim.api.nvim_exec_autocmds("VimResized", {})
    vim.wait(200)
    local narrow = vim.api.nvim_win_get_width(picker.layout.root.win)
    assert(math.abs(narrow - 32) <= 2, "Expected 20% width, got " .. narrow)
    vim.o.columns = 240
    vim.api.nvim_exec_autocmds("VimResized", {})
    vim.wait(200)
    local wide = vim.api.nvim_win_get_width(picker.layout.root.win)
    assert(math.abs(wide - 48) <= 2 and wide > narrow, "Explorer must resize proportionally")
    local main = picker.main
    if scenario == "directory" then
        assert(picker.opts.jump.close, "Directory startup must close explorer on file selection")
        vim.api.nvim_win_close(main, false)
        vim.wait(300)
        assert(not picker.closed, "Directory startup must allow an explorer-only session")
        local item = { file = directory .. "/sample.txt" }
        picker.selected = function() return { item } end
        require("snacks.explorer.actions").actions.confirm(picker, item, {})
        vim.wait(300)
        assert(picker.closed, "Selecting a file must close the startup explorer")
        assert(vim.api.nvim_buf_get_name(0) == item.file, "Selected file must remain open")
        local later = Snacks.picker.explorer({ cwd = directory })
        later:show()
        vim.wait(100)
        assert(not later.opts.jump.close, "Later explorers must behave as normal sidebars")
        later:close()
    elseif scenario == "modified" then
        local hidden = vim.api.nvim_create_buf(true, false)
        vim.api.nvim_buf_set_lines(hidden, 0, -1, false, { "unsaved" })
        vim.api.nvim_win_close(main, false)
        vim.wait(300)
        assert(vim.bo[hidden].modified, "Hidden changes must be preserved")
        picker:close()
    elseif scenario == "other-tab" then
        local tab = vim.api.nvim_get_current_tabpage()
        vim.cmd.tabnew()
        vim.api.nvim_set_current_tabpage(tab)
        vim.api.nvim_win_close(main, false)
        vim.wait(300)
        assert(#vim.api.nvim_list_tabpages() == 2, "Another tab must prevent auto-exit")
        picker:close()
    else
        assert(not picker.opts.jump.close, "File startup must retain sidebar behavior")
        print("READY_FOR_AUTO_EXIT")
        vim.api.nvim_win_close(main, false)
        vim.wait(1000)
        error("Neovim did not exit when only the explorer remained")
    end
    print("EXPLORER_LIFECYCLE_PASS " .. scenario)
end, debug.traceback)
if not ok then io.stderr:write(err); vim.cmd("cquit 1") else vim.cmd("qa!") end
