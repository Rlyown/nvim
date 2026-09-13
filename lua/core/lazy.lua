local path = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
local offline = require("config").get().offline
local maintenance = vim.env.NVIM_MAINTENANCE == "1" and not offline
if not vim.uv.fs_stat(path) then
    if offline then vim.notify("lazy.nvim is missing in offline mode", vim.log.levels.ERROR); return end
    if not maintenance and (#vim.api.nvim_list_uis() == 0 or vim.fn.confirm("Install plugins for the selected configuration?", "&Yes\n&No", 2) ~= 1) then
        vim.notify("Plugins are not installed; run install.sh or :ConfigInstall")
        return
    end
    local result = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", "https://github.com/folke/lazy.nvim.git", path })
    assert(vim.v.shell_error == 0, result)
    local lockpath = vim.env.NVIM_LOCKFILE or (vim.env.NVIM_CONFIG_ROOT or vim.fn.stdpath("config")) .. "/lazy-lock.json"
    local lock = vim.json.decode(table.concat(vim.fn.readfile(lockpath), "\n"))
    if lock["lazy.nvim"] then
        result = vim.fn.system({ "git", "-C", path, "checkout", lock["lazy.nvim"].commit })
        assert(vim.v.shell_error == 0, result)
    end
end
vim.opt.rtp:prepend(path)
require("lazy").setup(require("config.specs").get(), {
    defaults = { lazy = true },
    lockfile = vim.env.NVIM_LOCKFILE or vim.fn.stdpath("config") .. "/lazy-lock.json",
    install = { missing = maintenance },
    checker = { enabled = false },
    change_detection = { notify = false },
    rocks = { enabled = false },
})
require("config.context").setup()
