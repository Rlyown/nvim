local config = require("config")
local plugins = require("lazy.core.config").plugins
assert(not plugins["toggleterm.nvim"] and not plugins["nvim-tree.lua"])
if not config.enabled("dap") then assert(not plugins["nvim-dap"]) end
if not config.enabled("ai") then assert(not plugins["sidekick.nvim"] and not package.loaded.sidekick) end
if not config.enabled("sql") then assert(not plugins["nvim-dbee"]) end
local term = require("modules.terminal")
local first = term.get(1)
local buf = first.term.buf
local job = vim.b[buf].terminal_job_id
vim.cmd("cd /private/tmp")
term.hide(1)
assert(term.get(1).term.buf == buf)
term.show(1, "vertical")
assert(vim.b[buf].terminal_job_id == job)
term.show(1, "float")
assert(vim.b[buf].terminal_job_id == job)
term.show(1, "tab")
assert(vim.api.nvim_get_current_buf() == buf)
term.hide(1)
term.show(1, "horizontal")
assert(term.send(1, "printf 'UTF-8 test: café\\n'"))
term.get(2)
assert(term.entries[2].term.buf ~= buf)
term.toggle_all()
term.toggle_all()
vim.fn.jobstop(job)
vim.wait(1000, function() return vim.fn.jobwait({ job }, 0)[1] ~= -1 end)
assert(not term.send(1, "should_not_execute"))
for id, e in pairs(term.entries) do
    term.hide(id)
    local channel = vim.b[e.term.buf].terminal_job_id
    if channel then pcall(vim.fn.jobstop, channel) end
end
print("Isolated runtime and terminal identity checks passed")
vim.cmd("qa!")
