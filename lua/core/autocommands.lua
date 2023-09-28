-- Related issue: https://github.com/L3MON4D3/LuaSnip/issues/258
function _G.leave_snippet()
    if
        ((vim.v.event.old_mode == "s" and vim.v.event.new_mode == "n") or vim.v.event.old_mode == "i")
        and require("luasnip").session.current_nodes[vim.api.nvim_get_current_buf()]
        and not require("luasnip").session.jump_active
    then
        require("luasnip").unlink_current()
    end
end

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

augroup("_CUSTOM_general_settings", { clear = true })
autocmd("FileType", {
    group = "_CUSTOM_general_settings",
    pattern = { "qf", "help", "man", "lspinfo", "startuptime", "null-ls-info", "notify", "spectre_panel" },
    command = "nnoremap <silent> <buffer> q :close<CR>",
})
autocmd("TextYankPost", {
    group = "_CUSTOM_general_settings",
    pattern = "*",
    command = "silent!lua require('vim.highlight').on_yank({higroup = 'Visual', timeout = 200})",
})
autocmd("BufWinEnter", {
    group = "_CUSTOM_general_settings",
    pattern = "*",
    command = ":set formatoptions-=cro",
})
autocmd("FileType", {
    group = "_CUSTOM_general_settings",
    pattern = "qf",
    command = "set nobuflisted",
})

augroup("_CUSTOM_git", { clear = true })
autocmd("FileType", {
    group = "_CUSTOM_git",
    pattern = "gitcommit",
    command = "setlocal wrap",
})
autocmd("FileType", {
    group = "_CUSTOM_git",
    pattern = "gitcommit",
    command = "setlocal spell",
})

augroup("_CUSTOM_text", { clear = true })
autocmd("FileType", {
    group = "_CUSTOM_text",
    pattern = "norg",
    callback = function()
        vim.api.nvim_buf_set_option(0, "shiftwidth", 2)
        vim.api.nvim_buf_set_option(0, "tabstop", 2)
    end,
})
autocmd("FileType", {
    group = "_CUSTOM_text",
    pattern = { "norg", "markdown" },
    callback = function()
        vim.opt_local.conceallevel = 3
    end,
})
autocmd("FileType", {
    group = "_CUSTOM_text",
    pattern = { "norg", "markdown", "tex" },
    command = "setlocal wrap",
})
autocmd("FileType", {
    group = "_CUSTOM_text",
    pattern = { "norg", "markdown", "tex" },
    command = "setlocal spell",
})

augroup("_CUSTOM_auto_resize", { clear = true })
autocmd("VimResized", {
    group = "_CUSTOM_auto_resize",
    pattern = "*",
    callback = function()
        require("bufresize").resize()
    end,
})

augroup("_CUSTOM_alpha", { clear = true })
autocmd("User", {
    group = "_CUSTOM_alpha",
    pattern = "AlphaReady",
    command = "set showtabline=0 | autocmd BufUnload <buffer> set showtabline=2",
})

augroup("_CUSTOM_lsp", { clear = true })
autocmd("BufWritePre", {
    group = "_CUSTOM_lsp",
    pattern = "*",
    callback = function()
        local filter = {
            norg = true,
        }

        if filter[vim.bo.filetype] then
            return
        end

        if vim.g.custom_enable_auto_format then
            if vim.bo.filetype == "go" then
                require("go.format").goimport()
            else
                vim.lsp.buf.format({ async = false })
            end
        end
    end,
    desc = "auto format",
})
-- Issue: https://github.com/nvim-telescope/telescope.nvim/issues/559
autocmd("BufRead", {
    group = "_CUSTOM_lsp",
    pattern = "*",
    callback = function()
        vim.api.nvim_create_autocmd("BufWinEnter", {
            once = true,
            command = "normal! zx",
        })
    end,
})
-- Question: https://superuser.com/questions/567352/how-can-i-set-foldlevelstart-in-vim-to-just-fold-nothing-initially-still-allowi
-- autocmd("BufWinEnter", {
-- 	group = "_CUSTOM_lsp",
-- 	pattern = "*",
-- 	command = [[ let &foldlevel = max(map(range(1, line('$')), 'foldlevel(v:val)')) ]],
-- })

augroup("_CUSTOM_auto_close", { clear = true })
autocmd("WinClosed", {
    group = "_CUSTOM_auto_close",
    callback = function()
        local winnr = tonumber(vim.fn.expand("<amatch>"))
        vim.schedule_wrap(tab_win_closed(winnr))
    end,
    nested = true,
})

-- stop snippets when you leave to normal mode
augroup("_CUSTOM_luasnip", { clear = true })
autocmd("ModeChanged", {
    group = "_CUSTOM_luasnip",
    pattern = "*",
    callback = leave_snippet,
})

augroup("_CUSTOM_cmp", { clear = true })
autocmd("FileType", {
    group = "_CUSTOM_cmp",
    pattern = "toml",
    callback = function()
        require("cmp").setup.buffer({ sources = { { name = "crates" } } })
    end,
})

augroup("_CUSTOM_terminal", { clear = true })
autocmd("TermOpen", {
    group = "_CUSTOM_terminal",
    pattern = { "term://*" },
    callback = function()
        set_terminal_keymaps()
        vim.wo.spell = false
    end,
})
autocmd("FileType", {
    group = "_CUSTOM_terminal",
    pattern = { "dapui_console" },
    callback = function()
        set_terminal_keymaps()
        vim.wo.spell = false
    end,
})

augroup("_CUSTOM_compile", { clear = true })
-- Create an autocmd User PackerCompileDone to update it every time packer is compiled
autocmd("User", {
    group = "_CUSTOM_compile",
    pattern = "LazyDone",
    callback = function()
        require("catppuccin").compile() -- Catppuccin also provide a function to work with the catppuccin compiler.

        vim.defer_fn(function()
            vim.cmd("colorscheme catppuccin")
        end, 50) -- Debounced for live reloading
    end,
})
vim.api.nvim_create_autocmd("BufWritePost", {
    pattern = { "catppuccin.lua" },
    callback = function()
        require("catppuccin").compile() -- Catppuccin also provide a function to work with the catppuccin compiler.
    end,
})

augroup("_CUSTOM_VimIM", { clear = true })
autocmd("User", {
    group = "_CUSTOM_VimIM",
    pattern = "ZFVimIM_event_OnEnable",
    callback = function()
        require("noice").cmd("disable")
    end,
})
autocmd("User", {
    group = "_CUSTOM_VimIM",
    pattern = "ZFVimIM_event_OnDisable",
    callback = function()
        require("noice").cmd("enable")
    end,
})

augroup("_CUSTOM_big_file", { clear = true })
autocmd("BufRead", {
    group = "_CUSTOM_big_file",
    pattern = "*",
    callback = function()
        local disable_func = require("core.gfunc").fn.diable_check_buf
        if disable_func("vim-illuminate", "illuminate") then
            vim.cmd("IlluminatePauseBuf")
        end
    end
})
