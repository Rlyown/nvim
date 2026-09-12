local ok, err = xpcall(function()
    local dir = vim.fn.tempname()
    vim.fn.mkdir(dir .. "/target", "p")
    vim.fn.writefile({ "中文文件" }, dir .. "/source.txt")
    local cwd = vim.fn.getcwd()
    local p = Snacks.picker.explorer({ cwd = dir })
    vim.wait(200)
    assert(vim.fn.getcwd() == cwd)
    local actions = require("snacks.explorer.actions").actions
    local original_input = Snacks.input
    Snacks.input = function(_, callback) callback("created.txt") end
    actions.explorer_add(p)
    assert(vim.uv.fs_stat(dir .. "/created.txt"))
    Snacks.input = function(_, callback) callback("copied.txt") end
    p.selected = function() return {} end
    actions.explorer_copy(p, { file = dir .. "/source.txt" })
    assert(vim.uv.fs_stat(dir .. "/copied.txt"))
    Snacks.input = original_input
    Snacks.rename.rename_file({ from = dir .. "/copied.txt", to = dir .. "/renamed.txt" })
    vim.wait(100)
    assert(vim.uv.fs_stat(dir .. "/renamed.txt"))
    p.selected = function() return { { file = dir .. "/renamed.txt" } } end
    local explorer = require("modules.explorer")
    explorer.cut(p)
    p.dir = function() return dir .. "/target" end
    explorer.paste(p)
    assert(vim.uv.fs_stat(dir .. "/target/renamed.txt"))
    assert(not vim.uv.fs_stat(dir .. "/renamed.txt"))
    p.selected = function() return { { file = dir .. "/source.txt" } } end
    local original_select, original_executable = vim.ui.select, vim.fn.executable
    vim.ui.select = function(_, _, callback) callback("确认") end
    vim.fn.executable = function() return 0 end
    explorer.delete(p, false)
    assert(vim.uv.fs_stat(dir .. "/source.txt"))
    vim.fn.executable = original_executable
    explorer.delete(p, true)
    assert(not vim.uv.fs_stat(dir .. "/source.txt"))
    vim.ui.select = original_select
    p:close()
    assert(vim.fn.getcwd() == cwd)
    vim.fn.delete(dir, "rf")
end, debug.traceback)
if not ok then io.stderr:write(err); vim.cmd("cquit 1") else print("文件树工作流与删除隔离通过"); vim.cmd("qa!") end
