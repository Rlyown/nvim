local M = {}
function M.setup()
    local keys = {}
    for _, spec in ipairs(require("config.specs").get()) do
        for _, key in ipairs(spec.keys or {}) do
            if type(key) == "table" and key.ft then
                table.insert(keys, key)
            end
        end
    end
    vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("ConfigContextKeys", { clear = true }),
        callback = function(a)
            local applicable = {}
            for _, key in ipairs(keys) do
                local ft = type(key.ft) == "table" and key.ft or { key.ft }
                if vim.tbl_contains(ft, vim.bo[a.buf].filetype) then applicable[key[1]] = true end
            end
            for _, key in ipairs(keys) do
                if not applicable[key[1]] then
                    for _, mode in ipairs(type(key.mode) == "table" and key.mode or { key.mode or "n" }) do
                        local mapping = vim.api.nvim_buf_call(a.buf, function() return vim.fn.maparg(key[1], mode, false, true) end)
                        if mapping.buffer == 1 and mapping.desc == key.desc then pcall(vim.keymap.del, mode, key[1], { buffer = a.buf }) end
                    end
                end
            end
        end,
    })
end
return M
