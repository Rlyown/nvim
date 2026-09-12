local ok, err = xpcall(function()
    vim.go.loadplugins = true
    if not package.loaded.lazy then dofile(assert(vim.env.NVIM_CONFIG_ROOT) .. "/init.lua") end
    require("config.commands").install()
end, debug.traceback)
if not ok then
    io.stderr:write(tostring(err) .. "\n")
    vim.cmd("cquit 1")
else vim.cmd.qa() end
