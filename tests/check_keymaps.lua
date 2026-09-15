vim.opt.rtp:prepend(assert(vim.env.NVIM_CONFIG_ROOT))
local seen = {}
local which_key_specs = 0
local groups = {}
local mappings = {}
vim.g.mapleader = ","
vim.g.maplocalleader = " "
require("core.keymaps")
local function record(lhs, mode, ft, owner)
    lhs = lhs:gsub("<leader>", ","):gsub("<localleader>", " ")
    for _, previous in ipairs(mappings) do
        if previous.mode == mode and (previous.ft == ft or previous.ft == "*" or ft == "*") then
            assert(previous.lhs ~= lhs, "Duplicate mapping: " .. lhs .. " / " .. owner .. " / " .. previous.owner)
            assert(lhs:sub(1, #previous.lhs) ~= previous.lhs and previous.lhs:sub(1, #lhs) ~= lhs,
                "Action shadows a prefix: " .. lhs .. " / " .. previous.lhs)
        end
    end
    table.insert(mappings, { lhs = lhs, mode = mode, ft = ft, owner = owner })
end
for _, mapping in ipairs(vim.api.nvim_get_keymap("n")) do
    if mapping.lhs:sub(1, 1) == "," then record(mapping.lhs, "n", "*", "core") end
end
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
                    assert(not seen[id], "Duplicate keymap " .. id .. " : " .. tostring(seen[id]) .. " / " .. spec[1])
                    seen[id] = spec[1]
                    record(key[1], mode, ft, spec[1])
                end
            end
        end
    end
end
local lsp = require("modules.lsp")
local original_clients = vim.lsp.get_clients
for _, ft in ipairs({ "python", "go", "rust", "cpp", "lua", "tex", "sql", "csv" }) do
    local buf = vim.api.nvim_create_buf(true, false)
    vim.bo[buf].filetype = ft
    local pack = lsp.pack(buf)
    vim.lsp.get_clients = function()
        return { { id = 1, name = pack and pack.format or "test", config = {}, supports_method = function() return true end } }
    end
    lsp.refresh(buf)
    for _, mapping in ipairs(vim.api.nvim_buf_get_keymap(buf, "n")) do
        record(mapping.lhs, "n", ft, "LSP")
    end
    vim.api.nvim_buf_delete(buf, { force = true })
end
vim.lsp.get_clients = original_clients
assert(which_key_specs == 1, "which-key must have exactly one group specification")
assert(groups["<leader>p"] == "Sessions", "missing Sessions group")
assert(groups["<leader>s"] == "Search", "missing Search group")
assert(groups["<leader>l"] == "Language" and not groups["<leader>c"], "Language group shadows Close Buffer")
assert(vim.fn.maparg("H", "n"):lower() == "<cmd>bprevious<cr>")
assert(vim.fn.maparg("L", "n"):lower() == "<cmd>bnext<cr>")
for _, lhs in ipairs({ "gj", "gk", "gJ", "<C-w>", "za" }) do
    assert(vim.fn.maparg(lhs, "n") == "", "Native command overridden: " .. lhs)
end
vim.cmd.enew()
local first = vim.api.nvim_get_current_buf()
vim.bo.filetype = "markdown"
vim.api.nvim_buf_set_lines(0, 0, -1, false, { "# Heading", "Fold content", "Last line" })
vim.bo.modified = false
vim.wo.foldmethod = "manual"
vim.cmd("1,2fold")
vim.api.nvim_win_set_cursor(0, { 1, 0 })
local function press(keys)
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(keys, true, false, true), "xt", false)
end
assert(vim.fn.foldclosed(1) == 1)
press("<CR>")
assert(vim.fn.foldclosed(1) == -1, "Enter must expand a closed fold")
press("<CR>")
assert(vim.fn.line(".") == 2, "Enter outside a closed fold must retain native movement")
vim.cmd.enew()
local second = vim.api.nvim_get_current_buf()
press("H")
assert(vim.api.nvim_get_current_buf() == first, "H must select the previous buffer")
press("L")
assert(vim.api.nvim_get_current_buf() == second, "L must select the next buffer")
print("Keymap conflict and group checks passed")
vim.cmd.qa()
