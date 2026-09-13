return {
    { "mrcjkb/rustaceanvim", lazy = false, init = function()
        vim.g.rustaceanvim = { dap = { autoload_configurations = false, adapter = false }, tools = { enable_nextest = false } }
    end, keys = {
        { "<localleader>r", "<cmd>RustLsp runnables<cr>", ft = "rust", desc = "Run Rust" },
        { "<localleader>t", "<cmd>RustLsp testables<cr>", ft = "rust", desc = "Test Rust" },
        { "<localleader>aa", "<cmd>RustLsp codeAction<cr>", ft = "rust", desc = "Rust Code Action" },
        { "<localleader>am", "<cmd>RustLsp expandMacro<cr>", ft = "rust", desc = "Expand Macro" },
        { "<localleader>h", "<cmd>RustLsp hover actions<cr>", ft = "rust", desc = "Rust Help" },
    } },
    { "saecki/crates.nvim", enabled = not require("config").get().offline,
        event = { "BufReadPost Cargo.toml", "BufNewFile Cargo.toml" },
        opts = { completion = { crates = { enabled = false } } },
        config = function(_, opts)
            require("crates").setup(opts)
            local group = vim.api.nvim_create_augroup("ConfigCargo", { clear = true })
            local function attach(a)
                if vim.fn.fnamemodify(vim.api.nvim_buf_get_name(a.buf), ":t") ~= "Cargo.toml" or vim.bo[a.buf].filetype ~= "toml" then
                    for _, key in ipairs({ "<localleader>au", "<localleader>ah" }) do pcall(vim.keymap.del, "n", key, { buffer = a.buf }) end
                    return
                end
                vim.keymap.set("n", "<localleader>au", require("crates").upgrade_crate, { buffer = a.buf, desc = "Upgrade Dependency" })
                vim.keymap.set("n", "<localleader>ah", require("crates").open_documentation, { buffer = a.buf, desc = "Dependency Documentation" })
            end
            vim.api.nvim_create_autocmd({ "BufEnter", "FileType" }, { group = group, callback = attach })
            attach({ buf = vim.api.nvim_get_current_buf() })
        end,
    },
}
