local ok, err = xpcall(function()
    assert(vim.version().major == 0 and vim.version().minor == 12 and vim.version().patch == 4)
    local config = require("config")
    assert(config.get().offline)
    assert(not config.enabled("ai") and not config.enabled("copilot"))
    assert(not package.loaded.dap and not package.loaded.sidekick)
    local plugins = require("lazy.core.config").plugins
    assert(not plugins["nvim-tree.lua"] and not plugins["toggleterm.nvim"])
    if not config.enabled("dap") then assert(not plugins["nvim-dap"]) end
    for _, tool in ipairs(config.plan().tools) do
        assert(vim.fn.filereadable(vim.fn.stdpath("data") .. "/mason/packages/" .. tool .. "/mason-receipt.json") == 1, "缺少工具 " .. tool)
    end
    if config.enabled("python") then
        vim.fn.writefile({ "print('offline')" }, "/tmp/config-test.py")
        vim.cmd.edit("/tmp/config-test.py")
        vim.wait(1000)
        assert(not package.loaded.dap, "打开文件提前加载 DAP")
    end
    if config.enabled("dap") then
        require("lazy").load({ plugins = { "nvim-dap" } })
        assert(require("dap").listeners.after.event_initialized.config)
        local python = require("dap").adapters.python
        if python then
            local result = vim.system({ python.command, "-c", "import debugpy; print(debugpy.__version__)" }, { text = true }):wait()
            assert(result.code == 0, result.stderr)
        end
    end
    assert(vim.v.errmsg == "", vim.v.errmsg)
end, debug.traceback)
if not ok then io.stderr:write(err .. "\n"); vim.cmd("cquit 1") else vim.cmd("qa!") end
