local M = {}

local function split_csv(value)
    local out = {}
    if not value or value == "" then
        return out
    end
    for part in string.gmatch(value, "([^,]+)") do
        part = vim.trim(part)
        if part ~= "" then
            out[part] = true
        end
    end
    return out
end

local defaults = {
    cpp = true,
    go = true,
    rust = true,
    python = true,
    tex = true,
    sql = true,
    copilot = false,
}

local env_disable = split_csv(vim.env.NVIM_DISABLE_LANGS)
local env_enable = split_csv(vim.env.NVIM_ENABLE_LANGS)

local enabled = vim.deepcopy(defaults)

for k, _ in pairs(env_disable) do
    if enabled[k] ~= nil then
        enabled[k] = false
    end
end

for k, _ in pairs(env_enable) do
    if enabled[k] ~= nil then
        enabled[k] = true
    end
end

function M.enabled(name)
    return enabled[name] == true
end

function M.snapshot()
    return vim.deepcopy(enabled)
end

return M
