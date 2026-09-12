-- 旧模块接口兼容一版，新代码使用 config。
local M = {}
M.enabled = require("config").enabled
function M.snapshot()
    local c = require("config").get()
    return vim.tbl_extend("force", c.languages, c.features)
end
return M
