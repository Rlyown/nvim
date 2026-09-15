vim.opt.rtp:prepend(assert(vim.env.NVIM_CONFIG_ROOT))
vim.opt.rtp:append(assert(vim.env.TEST_RUNTIME) .. "/data/nvim/lazy/nvim-dap")
local input, session, launch, breakpoint
local dap = {
    session = function() return session end,
    continue = function(opts) launch = opts end,
    set_breakpoint = function(_, _, message)
        breakpoint = { message = message, buf = vim.api.nvim_get_current_buf(), line = vim.fn.line(".") }
    end,
}
package.loaded.dap = dap
package.loaded["modules.debug_mode"] = { exit = function() end }
vim.ui.input = function(_, callback) input = callback end
local actions = require("modules.debug_actions")
actions.launch_with_args()
input(nil)
assert(not launch, "Cancelling arguments must not launch")
actions.launch_with_args()
input([[--name "two words" --count 3]])
local original = { name = "Test", type = "python", args = { "old" } }
local config = launch.before(original)
assert(vim.deep_equal(config.args, { "--name", "two words", "--count", "3" }))
assert(original.args[1] == "old", "Saved configurations must not be changed")
actions.launch_with_args()
input("")
assert(#launch.before(original).args == 0, "Empty input must clear arguments")
session, input = {}, nil
actions.launch_with_args()
assert(not input, "An active session must not prompt for a new launch")
session = nil
vim.api.nvim_buf_set_lines(0, 0, -1, false, { "one", "two", "three" })
vim.api.nvim_win_set_cursor(0, { 2, 0 })
local target = vim.api.nvim_get_current_buf()
actions.logpoint()
vim.api.nvim_win_set_cursor(0, { 3, 0 })
input("value = {value}")
assert(breakpoint.buf == target and breakpoint.line == 2 and breakpoint.message == "value = {value}")
assert(vim.fn.line(".") == 3, "Logpoint creation must restore the cursor")
breakpoint = nil
actions.logpoint()
input(nil)
assert(not breakpoint, "Cancelling a logpoint must do nothing")
print("Debug argument parsing, cancellation, and logpoint checks passed")
vim.cmd("qa!")
