return function()
    local Hydra = require("hydra")

    local resize_hydra = Hydra({
        name = "Resize Window",
        mode = { "n" },
        body = "<leader>r",
        hint = [[
 _<_: desc weight   _-_: desc height   ___: max height   _o_: max both
 _>_: incr weight   _+_: incr height   _|_: max weight   _=_: equalize
 ^
 _h_: move left     _j_: move down     _k_: move up      _o_: move right
 ^
 ^ ^                ^ ^                ^ ^               _<esc>_
]],
        config = {
            -- color = "pink",
            hint = {
                border = "rounded",
                position = "bottom",
            },
        },
        heads = {
            -- move window
            { "h",     "<C-w>h" },
            { "j",     "<C-w>j" },
            { "k",     "<C-w>k" },
            { "l",     "<C-w>l" },

            -- resizing window
            { "<",     "30<C-w><" },
            { ">",     "30<C-w>>" },
            { "+",     "10<C-w>+" },
            { "-",     "10<C-w>-" },
            { "_",     "<C-w>_" },
            { "|",     "<C-w>|" },
            { "o",     "<C-w>|<C-w>_" },
            { "=",     "<C-w>=" },

            -- exit this Hydra
            { "<Esc>", nil,           { exit = true, nowait = true } },
        },
    })

    local gitsigns = require("gitsigns")
    local git_hydra = Hydra({
        name = "Git",
        hint = [[
 _J_: next hunk   _s_: stage hunk        _d_: show deleted   _b_: blame line
 _K_: prev hunk   _u_: undo stage hunk   _p_: preview hunk   _B_: blame show full
 ^ ^              _S_: stage buffer      ^ ^                 _/_: show base file
 ^
 ^ ^  _c_: checkout branch    _C_: checkout commit    _o_: open changed file
 ^
 _<Enter>_: lazygit    _n_: neogit       _D_: diffview       _<esc>_
]],
        config = {
            color = "pink",
            invoke_on_body = true,
            hint = {
                position = "bottom",
                border = "rounded",
            },
            -- on_enter = function()
            -- 	vim.bo.modifiable = false
            -- gitsigns.toggle_signs(true)
            -- gitsigns.toggle_linehl(true)
            -- end,
            -- on_exit = function()
            -- gitsigns.toggle_signs(false)
            -- gitsigns.toggle_linehl(false)
            -- gitsigns.toggle_deleted(false)
            -- end,
        },
        mode = { "n", "x" },
        body = "<leader>g",
        heads = {
            {
                "J",
                function()
                    if vim.wo.diff then
                        return "]c"
                    end
                    vim.schedule(function()
                        gitsigns.next_hunk()
                    end)
                    return "<Ignore>"
                end,
                { expr = true },
            },
            {
                "K",
                function()
                    if vim.wo.diff then
                        return "[c"
                    end
                    vim.schedule(function()
                        gitsigns.prev_hunk()
                    end)
                    return "<Ignore>"
                end,
                { expr = true },
            },
            { "s", ":Gitsigns stage_hunk<CR>", { silent = true } },
            { "u", gitsigns.undo_stage_hunk },
            { "S", gitsigns.stage_buffer },
            { "p", gitsigns.preview_hunk },
            { "d", gitsigns.toggle_deleted,    { nowait = true } },
            { "b", gitsigns.blame_line },
            {
                "B",
                function()
                    gitsigns.blame_line({ full = true })
                end,
            },
            { "/",       gitsigns.show,                                              { exit = true } }, -- show the base of the file
            { "c",       "<cmd>lua require('telescope.builtin').git_branches()<cr>", { exit = true } },
            { "C",       "<cmd>lua require('telescope.builtin').git_commits()<cr>",  { exit = true } },
            { "o",       "<cmd>lua require('telescope.builtin').git_status()<cr>",   { exit = true } },
            { "<Enter>", "<cmd>lua _LAZYGIT_TOGGLE()<cr>",                           { exit = true } },
            { "n",       "<cmd>Neogit<cr>",                                          { exit = true } },
            { "D",       "<cmd>DiffviewOpen<cr>",                                    { exit = true } },
            { "<esc>",   nil,                                                        { exit = true, nowait = true } },
        },
    })

    -- TODO: set hydra for [ and ] shortcut
    -- local motion_hydra = Hydra({})

    Hydra.spawn = function(head)
        if head == "git-hydra" then
            git_hydra:activate()
        elseif head == "resize-hydra" then
            resize_hydra:activate()
        end
    end
end
