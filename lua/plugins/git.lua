local function hunk(action)
    return function()
        local range
        if vim.fn.mode():match("[vV\22]") then
            local first, last = vim.fn.line("v"), vim.fn.line(".")
            range = { math.min(first, last), math.max(first, last) }
        end
        require("gitsigns")[action](range)
    end
end

local keys = {
    { "<leader>gn", function() require("gitsigns").nav_hunk("next") end, desc = "Next Hunk" },
    { "<leader>gN", function() require("gitsigns").nav_hunk("prev") end, desc = "Previous Hunk" },
    { "<leader>gs", hunk("stage_hunk"), mode = { "n", "x" }, desc = "Stage Hunk" },
    { "<leader>gu", "<cmd>Gitsigns undo_stage_hunk<cr>", desc = "Undo Stage Hunk" },
    { "<leader>gS", "<cmd>Gitsigns stage_buffer<cr>", desc = "Stage Buffer" },
    { "<leader>gp", "<cmd>Gitsigns preview_hunk<cr>", desc = "Preview Hunk" },
    { "<leader>gb", "<cmd>Gitsigns blame_line<cr>", desc = "Blame Line" },
    { "<leader>gd", "<cmd>Gitsigns diffthis<cr>", desc = "Diff File" },
}
if require("config").enabled("ui") then
    table.insert(keys, { "<leader>gm", function()
        require("which-key").show({ keys = "<leader>g", loop = true })
    end, desc = "Review Hunks Repeatedly (Esc to Exit)" })
end

return {
    { "lewis6991/gitsigns.nvim", event = "BufReadPre", opts = {}, keys = keys },
}
