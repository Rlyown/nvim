return {
    {
        "lewis6991/gitsigns.nvim",
        config = true,
        lazy = true,
        event = "BufRead",
        keys = {
            { "<leader>g",  group = "Git" },
            {
                "<leader>gJ",
                function()
                    if vim.wo.diff then
                        return "]c"
                    end
                    vim.schedule(function()
                        require("gitsigns").next_hunk()
                    end)
                    return "<Ignore>"
                end,
                mode = { "n", "x", "v" },
                desc = "Next Hunk"
            },
            {
                "<leader>gK",
                function()
                    if vim.wo.diff then
                        return "[c"
                    end
                    vim.schedule(function()
                        require("gitsigns").prev_hunk()
                    end)
                    return "<Ignore>"
                end,
                mode = { "n", "x", "v" },
                desc = "Prev Hunk"
            },
            { "<leader>gs", "<cmd>Gitsigns stage_hunk<CR>",      mode = { "n", "x", "v" }, desc = "Stage Hunk" },
            { "<leader>gu", "<cmd>Gitsigns undo_stage_hunk<CR>", mode = { "n", "x", "v" }, desc = "Unod Stage Hunk" },
            { "<leader>gS", "<cmd>Gitsigns stage_buffer<cr>",    mode = { "n", "x", "v" }, desc = "Stage Buffer" },
            { "<leader>gp", "<cmd>Gitsigns preview_hunk<cr>",    mode = { "n", "x", "v" }, desc = "Preview Hunk" },
            { "<leader>gd", "<cmd>Gitsigns toggle_deleted<cr>",  mode = { "n", "x", "v" }, desc = "Show Deleted" },
            { "<leader>gb", "<cmd>Gitsigns blame_line<cr>",      mode = { "n", "x", "v" }, desc = "Blame Line" },
            {
                "<leader>gB",
                "<cmd>lua require('gitsigns').blame_line({ full = true })<cr>",
                mode = { "n", "x", "v" },
                desc =
                "Blame Show"
            },
            { "<leader>gv", "<cmd>Gitsigns show", mode = { "n", "x", "v" }, desc = "Show Base File" }, -- show the base of the file
        }
    },                                                                                                 -- show git info in buffer
}
