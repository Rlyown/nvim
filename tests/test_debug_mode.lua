vim.opt.rtp:prepend(assert(vim.env.NVIM_CONFIG_ROOT))
vim.opt.rtp:append(assert(vim.env.TEST_RUNTIME) .. "/data/nvim/lazy/hydra.nvim")
local calls, closed, current = {}, 0, nil
local dap = { listeners = { before = {}, after = {} }, session = function() return current end }
for _, phase in pairs(dap.listeners) do
    setmetatable(phase, { __index = function(t, k) t[k] = {}; return t[k] end })
end
for _, name in ipairs({ "step_over", "step_into", "step_out", "continue", "toggle_breakpoint", "terminate" }) do
    dap[name] = function() calls[name] = (calls[name] or 0) + 1 end
end
package.loaded.dap = dap
local mode = require("modules.debug_mode")
mode.setup(dap, { open = function() end, close = function() closed = closed + 1 end })
local function feed(keys)
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(keys, true, false, true), "xt", false)
end
local original = function() calls.original = true end
vim.keymap.set("n", "n", original)
mode.continue()
assert(not mode.active, "Must not capture keys without a session")
current = { on_close = {} }
dap.listeners.after.event_initialized.config(current)
vim.wait(100, function() return mode.active end)
assert(mode.active, "Must enter automatically after initialization")
feed("ns")
assert(calls.step_over == 1 and calls.step_into == 1, "Step actions must match their hints")
assert(vim.fn.maparg("j", "n") == "", "Must not override movement")
feed("<Esc>")
assert(not mode.active and vim.fn.maparg("n", "n", false, true).callback == original, "Exit must restore mappings")
mode.enter()
vim.cmd.enew()
vim.bo.buftype = "nofile"
vim.api.nvim_exec_autocmds("BufEnter", {})
vim.wait(100, function() return not mode.active end)
assert(not mode.active, "Plugin windows must not retain debug mappings")
vim.bo.buftype = ""
mode.enter()
assert(mode.active)
current.closed = true
current.on_close.config_debug_mode()
vim.wait(100, function() return not mode.active end)
assert(not mode.active and closed == 1, "Unexpected disconnect must exit the mode and close the UI")
current = { on_close = {} }
mode.enter()
dap.listeners.before.event_terminated.config(current)
assert(not mode.active, "Session termination must exit the mode")
mode.enter()
feed("i<Esc>")
assert(not mode.active, "Entering insert mode must exit the mode")
print("Debug mode lifecycle, stepping, and mapping restoration checks passed")
vim.cmd("qa!")
