vim.opt.rtp:prepend(assert(vim.env.NVIM_CONFIG_ROOT))
local seen = {}
local which_key_specs = 0
local groups = {}
for _, spec in ipairs(require("config.specs").get()) do
    if spec[1] == "folke/which-key.nvim" then
        which_key_specs = which_key_specs + 1
        for _, group in ipairs(spec.opts.spec or {}) do groups[group[1]] = group.group end
    end
    for _, key in ipairs(spec.keys or {}) do
        if type(key) == "table" and key[1] then
            for _, mode in ipairs(type(key.mode) == "table" and key.mode or { key.mode or "n" }) do
                for _, ft in ipairs(type(key.ft) == "table" and key.ft or { key.ft or "*" }) do
                    local id = mode .. ":" .. ft .. ":" .. key[1]
                    assert(not seen[id], "重复快捷键 " .. id .. " : " .. tostring(seen[id]) .. " / " .. spec[1])
                    seen[id] = spec[1]
                end
            end
        end
    end
end
assert(which_key_specs == 1, "which-key must have exactly one group specification")
assert(groups["<leader>p"] == "Sessions", "missing Sessions group")
assert(groups["<leader>s"] == "Search", "missing Search group")
print("Keymap conflict and group checks passed")
vim.cmd.qa()
