vim.opt.rtp:prepend(assert(vim.env.NVIM_CONFIG_ROOT))
local seen = {}
for _, spec in ipairs(require("config.specs").get()) do
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
print("插件快捷键冲突检查通过")
vim.cmd.qa()
