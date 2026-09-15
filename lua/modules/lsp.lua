local M = {}
local owned = {}
local actions = {
    { "<leader>ld", "textDocument/definition", vim.lsp.buf.definition, "Definition" },
    { "<leader>lR", "textDocument/references", vim.lsp.buf.references, "References" },
    { "<leader>lh", "textDocument/hover", vim.lsp.buf.hover, "Hover Documentation" },
    { "<leader>ln", "textDocument/rename", vim.lsp.buf.rename, "Rename" },
    { "<leader>lc", "textDocument/codeAction", vim.lsp.buf.code_action, "Code Action" },
    { "gd", "textDocument/definition", vim.lsp.buf.definition, "Go to Definition" },
}
function M.pack(buf)
    for name, enabled in pairs(require("config").get().languages) do
        local pack = require("config.capabilities").languages[name]
        if enabled and vim.tbl_contains(pack.ft, vim.bo[buf].filetype) then return pack end
    end
end
function M.format(buf)
    local pack = M.pack(buf)
    if not pack or not pack.format then return end
    vim.lsp.buf.format({ bufnr = buf, timeout_ms = 3000, filter = function(c) return c.name == pack.format end })
end
function M.refresh(buf, excluded)
    if not vim.api.nvim_buf_is_valid(buf) then return end
    for _, lhs in ipairs(owned[buf] or {}) do pcall(vim.keymap.del, "n", lhs, { buffer = buf }) end
    owned[buf] = {}
    local pack = M.pack(buf)
    if not pack then return end
    local clients = vim.tbl_filter(function(c)
        return c.id ~= excluded and (not c.config.filetypes or vim.tbl_contains(c.config.filetypes, vim.bo[buf].filetype))
    end, vim.lsp.get_clients({ bufnr = buf }))
    local function map(lhs, callback, desc)
        vim.keymap.set("n", lhs, callback, { buffer = buf, desc = desc })
        table.insert(owned[buf], lhs)
    end
    for _, action in ipairs(actions) do
        for _, client in ipairs(clients) do
            if client:supports_method(action[2], buf) then map(action[1], action[3], action[4]); break end
        end
    end
    for _, client in ipairs(clients) do
        if client.name == pack.format and client:supports_method("textDocument/formatting", buf) then
            map("<leader>lf", function() M.format(buf) end, "Format"); break
        end
    end
end
function M.setup()
    local group = vim.api.nvim_create_augroup("ConfigLsp", { clear = true })
    vim.api.nvim_create_autocmd({ "LspAttach", "FileType" }, { group = group, callback = function(a) M.refresh(a.buf) end })
    vim.api.nvim_create_autocmd("LspDetach", { group = group, callback = function(a) M.refresh(a.buf, a.data.client_id) end })
    vim.api.nvim_create_autocmd("BufWipeout", { group = group, callback = function(a) owned[a.buf] = nil end })
    vim.api.nvim_create_autocmd("BufWritePre", { group = group, callback = function(a) if vim.g.config_autoformat ~= false then M.format(a.buf) end end })
end
return M
