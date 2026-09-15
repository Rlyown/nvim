-- Keep the old module interface for one release; new code should use config.
local M = {}
M.enabled = require("config").enabled
function M.snapshot()
    local c = require("config").get()
    return vim.tbl_extend("force", c.languages, c.features)
end
return M
