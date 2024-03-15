-- this is used for fixing offsetEncoding conflict with null-ls
-- relative issue: https://github.com/jose-elias-alvarez/null-ls.nvim/issues/428
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities.offsetEncoding = { "utf-16" }
capabilities.textDocument = {
    inactiveRegionsCapabilities = {
        inactiveRegions = true,
    }
}

local os = require("core.gvariable").os
local compiler = require("core.gvariable").compiler

local query_driver = "--query-driver="
for _, cpr_path in ipairs(compiler) do
    if cpr_path ~= "" then
        query_driver = query_driver .. cpr_path .. ","
    end
end

if query_driver ~= "--query-driver=" then
    query_driver = query_driver:sub(1, -2)
else
    query_driver = ""
end

local inactive_ns = vim.api.nvim_create_namespace('inactive_regions')

local inactive_regions_update = function(_, message, _, _)
    local uri = message.textDocument.uri
    local fname = vim.uri_to_fname(uri)
    local ranges = message.regions
    if #ranges == 0 and vim.fn.bufexists(fname) == 0 then
        return
    end

    local bufnr = vim.fn.bufadd(fname)
    if not bufnr then
        return
    end

    vim.api.nvim_buf_clear_namespace(bufnr, inactive_ns, 0, -1)

    for _, range in ipairs(ranges) do
        local lnum = range.start.line
        local end_lnum = range['end'].line

        vim.api.nvim_buf_set_extmark(bufnr, inactive_ns, lnum, 0, {
            -- line_hl_group = 'ColorColumn', -- or whatever hl group you want
            hl_group = 'ColorColumn', -- or whatever hl group you want
            hl_eol = true,
            -- end_row = end_lnum,
            end_row = end_lnum + 1,
            priority = vim.highlight.priorities.treesitter - 1, -- or whatever priority
        })
    end
end

-- .clang-tidy and .clang-format set by local file
return {
    cmd = {
        "clangd",
        -- "--fallback-style=llvm",
        "--background-index",
        "--compile-commands-dir=build",
        "-j=2",
        "--clang-tidy",
        "--all-scopes-completion",
        "--header-insertion=iwyu",
        "--completion-style=detailed",
        query_driver,
        "--inlay-hints",
        "--pch-storage=disk",
        -- "--log=verbose",
    },

    handlers = {
        ['textDocument/inactiveRegions'] = inactive_regions_update
    },

    capabilities = capabilities,
}
