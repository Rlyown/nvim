local times = {}
local function measure(name, callback)
    local start = vim.uv.hrtime()
    callback()
    times[name] = (vim.uv.hrtime() - start) / 1e6
end
local ok, err = xpcall(function()
    measure("first_python_open_ms", function() vim.cmd.edit(vim.fn.tempname() .. ".py") end)
    if vim.env.NVIM_BENCH_BASELINE == "1" then
        measure("first_terminal_ms", function() vim.cmd("ToggleTerm") end)
    else
        measure("first_terminal_ms", function() require("modules.terminal").toggle(1) end)
    end
end, debug.traceback)
if not ok then io.stderr:write(err); vim.cmd("cquit 1") end
vim.fn.writefile({ vim.json.encode(times) }, assert(vim.env.NVIM_BENCH_OUTPUT))
vim.cmd("qa!")
