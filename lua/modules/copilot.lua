local M = {}

M.node_path = require("core.gvariable").node_path

M.init = function()
    -- set a proxy
    vim.g.copilot_proxy = "localhost:7890"

    -- set node path, if it has multi-versions
    -- vim.g.copilot_node_command = node_path
    -- vim.g.copilot_no_tab_map = true
    -- vim.g.copilot_assume_mapped = true
    -- vim.g.copilot_tab_fallback = ""
end

M.config = function()
    require("copilot").setup({
        suggestion = { enabled = false },
        panel = { enabled = false },
        copilot_node_command = M.node_path,
        filetypes = {
            ["grug-far"] = false,
            ["grug-far-history"] = false,
            ["grug-far-help"] = false,
        }
    })
end

return M
