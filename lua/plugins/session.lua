return {
    { "Shatur/neovim-session-manager", dependencies = { "nvim-lua/plenary.nvim" }, cmd = "SessionManager", opts = function()
        return { autoload_mode = require("session_manager.config").AutoloadMode.Disabled }
    end, keys = {
        { "<leader>pl", "<cmd>SessionManager load_session<cr>", desc = "Load Session" },
        { "<leader>ps", "<cmd>SessionManager save_current_session<cr>", desc = "Save Session" },
        { "<leader>pd", "<cmd>SessionManager delete_session<cr>", desc = "Delete Session" },
        { "<leader>pc", "<cmd>SessionManager load_current_dir_session<cr>", desc = "Load Directory Session" },
    } },
}
