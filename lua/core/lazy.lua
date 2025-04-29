local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable", -- latest stable release
        lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)

-- TODO: remove useless plugin
require("lazy").setup({
    -- auto load plugin
    { import = "plugins" },

    ----------------------------------------------------------------------------------------------
    -- Tools
    ----------------------------------------------------------------------------------------------
    {
        "folke/which-key.nvim",
        event = "VeryLazy",
        config = require('modules.whichkey'),
        keys = {
            {
                "<leader>Ch",
                function()
                    require("which-key").show({ keys = "<leader>C", loop = true })
                end,
                desc = "enter Hydra",
            },
            {
                "<leader>Ca", "<cmd>lua print(123)<cr>", desc = "test"
            },
            {
                "<leader>Cb", "<cmd>lua print(456)<cr>", desc = "test"
            }
        }
    }, -- Create key bindings that stick.
    {
        "anuvyklack/hydra.nvim",
        dependencies = "anuvyklack/keymap-layer.nvim", -- needed only for pink hydras
        config = require('modules.hydra'),
        lazy = true
    }, -- Bind a bunch of key bindings together.
}
)
