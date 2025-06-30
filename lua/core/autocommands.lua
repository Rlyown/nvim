-- Related issue: https://github.com/L3MON4D3/LuaSnip/issues/258
-- function _G.leave_snippet()
--     if
--         ((vim.v.event.old_mode == "s" and vim.v.event.new_mode == "n") or vim.v.event.old_mode == "i")
--         and require("luasnip").session.current_nodes[vim.api.nvim_get_current_buf()]
--         and not require("luasnip").session.jump_active
--     then
--         require("luasnip").unlink_current()
--     end
-- end

function _G.tab_win_closed(winnr)
    local tree_api = require("nvim-tree.api")
    local tabnr = vim.api.nvim_win_get_tabpage(winnr)
    local bufnr = vim.api.nvim_win_get_buf(winnr)
    local buf_info = vim.fn.getbufinfo(bufnr)[1]
    local tab_wins = vim.tbl_filter(function(w)
        return w ~= winnr
    end, vim.api.nvim_tabpage_list_wins(tabnr))
    local tab_bufs = vim.tbl_map(vim.api.nvim_win_get_buf, tab_wins)
    if buf_info.name:match(".*NvimTree_%d*$") then -- close buffer was nvim tree
        -- Close all nvim tree on :q
        if not vim.tbl_isempty(tab_bufs) then      -- and was not the last window (not closed automatically by code below)
            tree_api.tree.close()
        end
    else                                                          -- else closed buffer was normal buffer
        if #tab_bufs == 1 then                                    -- if there is only 1 buffer left in the tab
            local last_buf_info = vim.fn.getbufinfo(tab_bufs[1])[1]
            if last_buf_info.name:match(".*NvimTree_%d*$") then   -- and that buffer is nvim tree
                vim.schedule(function()
                    if #vim.api.nvim_list_wins() == 1 then        -- if its the last buffer in vim
                        vim.cmd("quit")                           -- then close all of vim
                    else                                          -- else there are more tabs open
                        vim.api.nvim_win_close(tab_wins[1], true) -- then close only the tab
                    end
                end)
            end
        end
    end
end

function _G.set_terminal_keymaps()
    local opts = { noremap = true }
    -- vim.api.nvim_buf_set_keymap(0, "t", "<esc>", [[<C-\><C-n>]], opts)
    vim.api.nvim_buf_set_keymap(0, "t", "jk", [[<C-\><C-n>]], opts)
    vim.api.nvim_buf_set_keymap(0, "t", "<C-h>", [[<C-\><C-n><C-W>h]], opts)
    vim.api.nvim_buf_set_keymap(0, "t", "<C-j>", [[<C-\><C-n><C-W>j]], opts)
    vim.api.nvim_buf_set_keymap(0, "t", "<C-k>", [[<C-\><C-n><C-W>k]], opts)
    vim.api.nvim_buf_set_keymap(0, "t", "<C-l>", [[<C-\><C-n><C-W>l]], opts)
end

local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

local _custom_general_settings = augroup("_CUSTOM_general_settings", { clear = true })
autocmd("FileType", {
    group = _custom_general_settings,
    pattern = { "qf", "help", "man", "lspinfo", "startuptime", "null-ls-info", "notify", "spectre_panel", "Avante" },
    command = "nnoremap <silent> <buffer> q :close<CR>",
})
autocmd("TextYankPost", {
    group = _custom_general_settings,
    pattern = "*",
    command = "silent!lua require('vim.highlight').on_yank({higroup = 'Visual', timeout = 200})",
})
autocmd("BufWinEnter", {
    group = _custom_general_settings,
    pattern = "*",
    command = ":set formatoptions-=cro",
})
autocmd("FileType", {
    group = _custom_general_settings,
    pattern = "qf",
    command = "set nobuflisted",
})


local _custom_text = augroup("_CUSTOM_text", { clear = true })
autocmd("FileType", {
    group = _custom_text,
    pattern = "gitcommit",
    command = "setlocal wrap",
})
autocmd("FileType", {
    group = _custom_text,
    pattern = "gitcommit",
    command = "setlocal spell",
})
autocmd("FileType", {
    group = _custom_text,
    pattern = "norg",
    callback = function()
        vim.api.nvim_set_option_value("shiftwidth", 2, { buf = 0 })
        vim.api.nvim_set_option_value("tabstop", 2, { buf = 0 })
    end,
})
autocmd("FileType", {
    group = _custom_text,
    pattern = "markdown",
    callback = function()
        vim.opt_local.conceallevel = 3
    end,
})
autocmd("FileType", {
    group = _custom_text,
    pattern = { "markdown", "tex" },
    command = "setlocal wrap",
})
-- autocmd("FileType", {
--     group = _custom_text,
--     pattern = { "markdown", "tex" },
--     command = "setlocal spell",
-- })

local _custom_auto_resize = augroup("_CUSTOM_auto_resize", { clear = true })
autocmd("VimResized", {
    group = _custom_auto_resize,
    pattern = "*",
    callback = function()
        require("bufresize").resize()
    end,
})

local _custom_lsp = augroup("_CUSTOM_lsp", { clear = true })
autocmd("BufRead", {
    group = _custom_lsp,
    pattern = "*",
    callback = function()
        vim.api.nvim_create_autocmd("BufWinEnter", {
            once = true,
            command = "normal! zx",
        })
    end,
})
autocmd('LspAttach', {
    group = _custom_lsp,
    callback = function(args)
        vim.diagnostic.config({
            signs = {
                text = {
                    [vim.diagnostic.severity.ERROR] = "",
                    [vim.diagnostic.severity.WARN] = "",
                    [vim.diagnostic.severity.INFO] = "󰋼",
                    [vim.diagnostic.severity.HINT] = "󰌵",
                },
            },
            underline = true,
            severity_sort = true,
            float = {
                border = "rounded",
                source = true,
            },
        })

        local client = assert(vim.lsp.get_client_by_id(args.data.client_id))

        -- Enable auto-completion. Note: Use CTRL-Y to select an item. |complete_CTRL-Y|
        -- if client:supports_method('textDocument/completion') then
        --     -- Optional: trigger autocompletion on EVERY keypress. May be slow!
        --     -- local chars = {}; for i = 32, 126 do table.insert(chars, string.char(i)) end
        --     -- client.server_capabilities.completionProvider.triggerCharacters = chars
        --     vim.lsp.completion.enable(true, client.id, args.buf, { autotrigger = true })
        -- end

        -- Auto-format ("lint") on save.
        -- Usually not needed if server supports "textDocument/willSaveWaitUntil".
        if not client:supports_method('textDocument/willSaveWaitUntil')
            and client:supports_method('textDocument/formatting') then
            autocmd('BufWritePre', {
                group = _custom_lsp,
                buffer = args.buf,
                callback = function()
                    if vim.g.custom_enable_auto_format then
                        if vim.bo.filetype == "go" then
                            require("go.format").goimport()
                        else
                            vim.lsp.buf.format({ bufnr = args.buf, id = client.id, timeout_ms = 1000 })
                        end
                    end
                end,
            })
        end

        -- navic
        if client.server_capabilities.documentSymbolProvider then
            require("nvim-navic").attach(client, args.buf)
        end
    end,
})

local _custom_terminal = augroup("_CUSTOM_terminal", { clear = true })
autocmd("TermOpen", {
    group = _custom_terminal,
    pattern = { "term://*" },
    callback = function()
        set_terminal_keymaps()
        vim.wo.spell = false
    end,
})
autocmd("FileType", {
    group = _custom_terminal,
    pattern = { "dapui_console" },
    callback = function()
        set_terminal_keymaps()
        vim.wo.spell = false
    end,
})

local _custom_snacks = augroup("_CUSTOM_snacks", { clear = true })
local prev = { new_name = "", old_name = "" } -- Prevents duplicate events
autocmd("User", {
    group = _custom_snacks,
    pattern = "NvimTreeSetup",
    callback = function()
        local events = require("nvim-tree.api").events
        events.subscribe(events.Event.NodeRenamed, function(data)
            if prev.new_name ~= data.new_name or prev.old_name ~= data.old_name then
                data = data
                Snacks.rename.on_rename_file(data.old_name, data.new_name)
            end
        end)
    end,
})
