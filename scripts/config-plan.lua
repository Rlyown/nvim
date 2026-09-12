local root = assert(vim.env.NVIM_CONFIG_ROOT)
vim.opt.rtp:prepend(root)
local config = require("config")
local plan = config.plan()
plan.config = config.get()
local repos = {}
local specs = require("config.specs").get()
local roots = {}
for _, spec in ipairs(specs) do if not spec.optional and spec.enabled ~= false then roots[spec[1]] = true end end
local function visit(spec)
    if type(spec) == "string" then repos[spec] = true; return end
    if spec.enabled == false or (spec.optional and not roots[spec[1]]) then return end
    if spec[1] then repos[spec[1]] = true end
    for _, dep in ipairs(spec.dependencies or {}) do visit(dep) end
end
for _, spec in ipairs(specs) do visit(spec) end
plan.plugins = vim.tbl_keys(repos)
table.sort(plan.plugins)
if vim.env.NVIM_PLAN_OUTPUT then vim.fn.writefile({ vim.json.encode(plan) }, vim.env.NVIM_PLAN_OUTPUT)
else print(vim.json.encode(plan)) end
vim.cmd.qa()
