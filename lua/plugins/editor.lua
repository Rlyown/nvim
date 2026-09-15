return {
    { "ojroques/nvim-osc52", event = "TextYankPost", opts = { silent = true }, config = function(_, opts)
        require("osc52").setup(opts)
        vim.api.nvim_create_autocmd("TextYankPost", { group = vim.api.nvim_create_augroup("ConfigOsc52", { clear = true }), callback = function()
            if vim.v.event.operator == "y" then require("osc52").copy_register(vim.v.event.regname) end
        end })
    end },
    { "tpope/vim-repeat", event = { "BufReadPost", "BufNewFile" } },
    { "kylechui/nvim-surround", event = { "BufReadPost", "BufNewFile" }, opts = {} },
    { "ethanholz/nvim-lastplace", event = "BufReadPost", opts = {} },
    { "windwp/nvim-autopairs", event = "InsertEnter", opts = {} },
    { "RaafatTurki/hex.nvim", cmd = { "HexDump", "HexAssemble", "HexToggle" }, opts = {} },
    { "lambdalisue/suda.vim", cmd = { "SudaRead", "SudaWrite" } },
    { "smoka7/hop.nvim", opts = {}, keys = {
        { "<leader>j", "<cmd>HopChar1<cr>", mode = { "n", "x", "o" }, desc = "Jump to Characters" },
    } },
    { "rainbowhxch/accelerated-jk.nvim", config = true, keys = {
        { "j", "<Plug>(accelerated_jk_gj)" }, { "k", "<Plug>(accelerated_jk_gk)" },
    } },
    { "chrishrb/gx.nvim", opts = {}, keys = { { "gx", "<cmd>Browse<cr>", desc = "Open Link" } } },
    { "andymass/vim-matchup", keys = { "%" }, init = function() vim.g.matchup_treesitter_enabled = false end },
    { "cvigilv/esqueleto.nvim", event = "BufNewFile", opts = {
        directories = { vim.fn.stdpath("config") .. "/templates/" }, patterns = { ".clang-format", ".clang-tidy", "c", "cpp" },
    } },
}
