local M = {}
function M.spec(groups)
    local spec = {}
    for lhs, label in pairs(groups) do table.insert(spec, { lhs, group = label }) end
    return { "folke/which-key.nvim", optional = true, opts = { spec = spec } }
end
return M
