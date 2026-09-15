vim.opt.rtp:prepend(assert(vim.env.NVIM_CONFIG_ROOT))
local directory = vim.fn.tempname()
vim.fn.mkdir(directory, "p")
local path = directory .. "/preserved-file"
vim.fn.writefile({ "must be preserved" }, path)
local original_executable, original_system = vim.fn.executable, vim.system
vim.fn.executable = function() return 0 end
local ok = require("modules.explorer").trash(path)
assert(not ok and vim.uv.fs_stat(path))
vim.fn.executable = function(name) return name == "trash" and 1 or 0 end
vim.system = function() return { wait = function() return { code = 1, stderr = "injected failure" } end } end
ok = require("modules.explorer").trash(path)
assert(not ok and vim.uv.fs_stat(path))
vim.fn.executable, vim.system = original_executable, original_system
local config = require("config")
config.current = config.resolve({ profile = "developer" }, {}, {})
local lsp = require("modules.lsp")
local buf = vim.api.nvim_create_buf(true, false)
vim.bo[buf].filetype = "python"
local original_clients = vim.lsp.get_clients
local function client(id, method)
    return { id = id, name = "pyright", config = { filetypes = { "python" } }, supports_method = function(_, m) return m == method end }
end
vim.lsp.get_clients = function() return { client(1, "textDocument/hover"), client(2, "textDocument/definition") } end
lsp.refresh(buf)
local function has(lhs)
    return vim.api.nvim_buf_call(buf, function() return vim.fn.maparg(lhs, "n") ~= "" end)
end
assert(has("<leader>lh") and has("<leader>ld"))
lsp.refresh(buf, 1)
assert(not has("<leader>lh") and has("<leader>ld"))
vim.bo[buf].filetype = "text"
lsp.refresh(buf)
assert(not has("<leader>ld"))
vim.lsp.get_clients = original_clients
vim.fn.delete(directory, "rf")
print("Trash failure protection, multi-client LSP detach, and filetype cleanup checks passed")
vim.cmd.qa()
