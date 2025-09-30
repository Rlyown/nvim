return {
    {
        "ray-x/go.nvim",
        opts = {
            lsp_keymaps = false, -- set to false to disable gopls/lsp keymap
            lsp_cfg = true,
            diagnostic = {
                hdlr = true, -- hook lsp diag handler
                underline = true,
                virtual_text = { space = 0, prefix = "" },
                signs = true,
            },
            gopls_cmd = nil,          -- if you need to specify gopls path and cmd, e.g {"/home/user/lsp/gopls", "-logfile","/var/log/gopls.log" }
            dap_debug_keymap = false, -- true: use keymap for debugger defined in go/dap.lua
            dap_debug_gui = false,    -- bool|table put your dap-ui setup here set to false to disable
            dap_debug_vt = false,     -- bool|table put your dap-virtual-text setup here set to false to disable

            dap_port = 38697,         -- can be set to a number, if set to -1 go.nvim will pickup a random port
            dap_timeout = 15,         --  see dap option initialize_timeout_sec = 15,
            dap_retries = 20,         -- see dap option max_retries
            trouble = true,           -- true: use trouble to open quickfix
            luasnip = false,          -- enable included luasnip snippets. you can also disable while add lua/snips folder to luasnip load
        },
        event = { "CmdlineEnter", "BufRead" },
        ft = { "go", "gomod" },
        build = ':lua require("go.install").update_all_sync()', -- if you need to install/update all binaries
        dependencies = {                                        -- optional packages
            "ray-x/guihua.lua",
            "neovim/nvim-lspconfig",
        },
        keys = {
            -- Golang
            { "<leader>lga",  "<cmd>GoCodeAction<cr>",                    desc = "Code action" },
            { "<leader>lge",  "<cmd>GoIfErr<cr>",                         desc = "Add if err" },
            { "<leader>lgha", "<cmd>GoAddTag<cr>",                        desc = "Add tags to struct" },
            { "<leader>lghr", "<cmd>GoRMTag<cr>",                         desc = "Remove tags to struct" },
            { "<leader>lghc", "<cmd>GoCoverage<cr>",                      desc = "Test coverage" },
            { "<leader>lghg", "<cmd>lua require('go.comment').gen()<cr>", desc = "Generate comment" },
            { "<leader>lghv", "<cmd>GoVet<cr>",                           desc = "Go vet" },
            { "<leader>lght", "<cmd>GoModTidy<cr>",                       desc = "Go mod tidy" },
            { "<leader>lghi", "<cmd>GoModInit<cr>",                       desc = "Go mod init" },
            { "<leader>lgi",  "<cmd>GoToggleInlay<cr>",                   desc = "Toggle inlay" },
            { "<leader>lgl",  "<cmd>GoLint<cr>",                          desc = "Run linter" },
            { "<leader>lgo",  "<cmd>GoPkgOutline<cr>",                    desc = "Outline" },
            { "<leader>lgr",  "<cmd>GoRun<cr>",                           desc = "Run" },
            { "<leader>lgs",  "<cmd>GoFillStruct<cr>",                    desc = "Autofill struct" },
            { "<leader>lgtr", "<cmd>GoTest<cr>",                          desc = "Run tests" },
            { "<leader>lgta", "<cmd>GoAlt!<cr>",                          desc = "Open alt file" },
            { "<leader>lgts", "<cmd>GoAltS!<cr>",                         desc = "Open alt file in split" },
            { "<leader>lgtv", "<cmd>GoAltV!<cr>",                         desc = "Open alt file in vertical split" },
            { "<leader>lgtu", "<cmd>GoTestFunc<cr>",                      desc = "Run test for current func" },
            { "<leader>lgtf", "<cmd>GoTestFile<cr>",                      desc = "Run test for current file" },
            { "<leader>lgxl", "<cmd>GoCodeLenAct<cr>",                    desc = "Toggle Lens" },
            { "<leader>lgxa", "<cmd>GoCodeAction<cr>",                    desc = "Code Action" },
        }
    },
}
