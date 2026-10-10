local M = {}
function M.check()
    vim.health.start("Configuration and dependencies")
    local c = require("config")
    vim.health.ok("Profile: " .. c.get().profile .. (c.get().offline and " (offline)" or ""))
    local executables = { cc = "cc", curl = "curl", git = "git", unzip = "unzip", ripgrep = "rg", fd = "fd", node = "node", python = "python3", go = "go", rust = "cargo", cmake = "cmake", images = "magick", kitty = "kitty", ["tree-sitter"] = "tree-sitter" }
    for _, capability in ipairs(c.plan().system) do
        local executable = executables[capability]
        if executable and vim.fn.executable(executable) == 0 then vim.health.warn("Missing system dependency: " .. executable) end
    end
    for _, tool in ipairs(c.plan().tools) do
        local path = vim.fn.stdpath("data") .. "/mason/packages/" .. tool
        if vim.uv.fs_stat(path) then vim.health.ok(tool) else vim.health.warn("Missing tool: " .. tool, { "Run :ConfigInstall" }) end
    end
    local ok, lazy = pcall(require, "lazy.core.config")
    if ok then for name, plugin in pairs(lazy.plugins) do
        if not vim.uv.fs_stat(plugin.dir) then vim.health.warn("Missing plugin: " .. name) end
    end end
    for _, parser in ipairs(c.plan().parsers) do
        if #vim.api.nvim_get_runtime_file("parser/" .. parser .. ".*", false) == 0 then vim.health.warn("Missing parser: " .. parser) end
    end
    if c.enabled("images") then
        if vim.fn.executable("gs") == 1 then
            vim.health.ok("Ghostscript: " .. vim.fn.exepath("gs"))
        else
            vim.health.warn("Ghostscript (gs) is required to render PDFs with Snacks.image")
        end
    end
    if c.enabled("tex") then
        if vim.fn.executable("latexmk") == 1 then
            vim.health.ok("LaTeX compiler: " .. vim.fn.exepath("latexmk"))
        else
            vim.health.warn("VimTeX is enabled but latexmk is not on PATH; install/configure a TeX distribution separately")
        end
        if vim.fn.executable("synctex") == 1 then
            vim.health.ok("SyncTeX: " .. vim.fn.exepath("synctex"))
        else
            vim.health.warn("SyncTeX is not on PATH; built-in PDF forward/reverse search will not work")
        end
        if not c.enabled("images") then
            vim.health.info("Snacks.image PDF preview requires the images capability")
        end
    end
    if c.enabled("explorer") and vim.fn.executable("trash") == 0 and vim.fn.executable("gio") == 0 then vim.health.warn("No trash utility found; trash operations will be refused") end
end
return M
