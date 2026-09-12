return {
    require("modules.groups").spec({ ["<leader>p"] = "会话" }),
    { "Shatur/neovim-session-manager", dependencies = { "nvim-lua/plenary.nvim" }, cmd = "SessionManager", opts = function()
        return { autoload_mode = require("session_manager.config").AutoloadMode.Disabled }
    end, keys = {
        { "<leader>pl", "<cmd>SessionManager load_session<cr>", desc = "选择会话" },
        { "<leader>ps", "<cmd>SessionManager save_current_session<cr>", desc = "保存会话" },
        { "<leader>pd", "<cmd>SessionManager delete_session<cr>", desc = "删除会话" },
        { "<leader>pc", "<cmd>SessionManager load_current_dir_session<cr>", desc = "当前目录会话" },
    } },
}
