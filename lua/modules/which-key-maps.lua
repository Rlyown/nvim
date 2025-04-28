local M = {}
local helper = require("modules.which-key-helper")

M.alpha = {
    -- { "<leader>a", "<cmd>Alpha<cr>", desc = "Alpha" },
}

M.avante = {
    { "<leader>a",  group = "Avante AI" },
    { "<leader>aa", desc = "ask" },
    { "<leader>ae", desc = "edit" },
    { "<leader>ar", desc = "refresh" },
    { "<leader>af", desc = "focus" },
    { "<leader>at", desc = "default" },
    { "<leader>ad", desc = "debug" },
    { "<leader>ah", desc = "hint" },
    { "<leader>as", desc = "suggestion" },
    { "<leader>aR", desc = "repomap" },
}

M.buffer = {
    -- Buffer Line
    { "<leader>B",  group = "Buffer Line" },
    { "<leader>Bc", "<cmd>BufferLineGroupClose<cr>",      desc = "Close Group Buffers" },
    { "<leader>Bd", "<cmd>BufferLineSortByDirectory<cr>", desc = "Sort By Directory" },
    { "<leader>Be", "<cmd>BufferLineSortByExtension<cr>", desc = "Sort By Extensions" },
    { "<leader>Bp", "<cmd>BufferLineTogglePin<cr>",       desc = "Pin" },
    { "<leader>Bt", "<cmd>BufferLineGroupToggle<cr>",     desc = "Group Toggle" },
    { "<leader>BT", "<cmd>BufferLineSortByTabs<cr>",      desc = "Sort by Tabs" },
    { "gw",         "<cmd>BufferLinePick<cr>",            desc = "Pick Buffer" },


    -- bdelete
    { "<leader>c",  helper.close_buffer,                  desc = "Close Buffer" },
}

M.comment = {
    { "gc",  group = "Line Comment",  remap = false },
    { "gcA", desc = "Line End" },
    { "gcc", desc = "Current Line" },
    { "gcO", desc = "Line Above " },
    { "gco", desc = "Line Below " },
    { "gb",  group = "Block Comment", remap = false },
    { "gbc", desc = "Current Line" },

    { "gc",  mode = "v",              desc = "Line Comment" },
    { "gb",  mode = "v",              desc = "Block Comment" },
}

M.dap = {
    {
        "<leader>d",
        group = "Dugger"
    },

    { "<leader>da", ":RunScriptWithArgs ",                                                                       desc = "Run with Args", },
    {
        '<Leader>dc',
        function()
            -- if buffer type is go
            if vim.bo.ft == "go" then
                vim.cmd("GoDebug")
            elseif vim.bo.ft == "rust" then
                vim.cmd.RustLsp('debuggables')
            else
                require('dap').continue()
            end
        end,
        desc = "Run/Continue"
    },
    { '<Leader>db', function() require('dap').toggle_breakpoint() end,                                           desc = "Toggle Breakpoint" },
    { '<Leader>dm', function() require('dap').set_breakpoint(nil, nil, vim.fn.input('Log point message: ')) end, desc = "Log Point" },
    { '<Leader>dR', function() require('dap').repl.toggle() end,                                                 desc = "Toggle Repl" },
    { '<Leader>dr', function() require('dap').run_last() end,                                                    desc = "Rerun" },
    { '<Leader>dK', function() require('dap.ui.widgets').hover() end,                                            desc = "Hover" },
    { '<Leader>dp', function() require('dap.ui.widgets').preview() end,                                          desc = "preview" },
    {
        '<leader>dq',
        function()
            require('dap').terminate()
        end,
        desc = "Terminate"
    },

    {
        "<leader>ds",
        function()
            require("hydra").spawn("dap-hydra")
        end,
        desc = "Step Mode",
    },
    -- { '<leader>dsn', function() require('dap').step_over() end, desc = "Step Over" },
    -- { '<leader>dsi', function() require('dap').step_into() end, desc = "Step Into" },
    -- { '<leader>dso', function() require('dap').step_out() end,  desc = "Step Out" },

}

M.edit = {
    { "<leader>e", "<cmd>edit<cr>",      desc = "Reopen" },
    { "<leader>w", "<cmd>w<cr>",         desc = "Save" },

    -- Suda
    { "<leader>E", "<cmd>SudaRead<cr>",  desc = "Sudo Reopen" },
    { "<leader>W", "<cmd>SudaWrite<cr>", desc = "Force Save" },
}

M.telescope = {
    {
        "<leader>b",
        "<cmd>lua require('telescope.builtin').buffers(require('telescope.themes').get_dropdown{previewer = false})<cr>",
        desc = "Buffers",
    },
    {
        "<leader>f",
        "<cmd>lua require('telescope.builtin').find_files(require('telescope.themes').get_dropdown{previewer = false})<cr>",
        desc = "Find files",
    },
    { "<leader>F", "<cmd>lua require('telescope.builtin').live_grep()<cr>", desc = "Find Text" },
}

M.git = {
    {
        mode = { "n", "x" },
        { "<leader>g",  group = "Git" },

        -- Gitsigns
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
            desc = "Prev Hunk"
        },
        { "<leader>gs", "<cmd>Gitsigns stage_hunk<CR>",      desc = "Stage Hunk" },
        { "<leader>gu", "<cmd>Gitsigns undo_stage_hunk<CR>", desc = "Unod Stage Hunk" },
        { "<leader>gS", "<cmd>Gitsigns stage_buffer<cr>",    desc = "Stage Buffer" },
        { "<leader>gp", "<cmd>Gitsigns preview_hunk<cr>",    desc = "Preview Hunk" },
        { "<leader>gd", "<cmd>Gitsigns toggle_deleted<cr>",  desc = "Show Deleted" },
        { "<leader>gb", "<cmd>Gitsigns blame_line<cr>",      desc = "Blame Line" },
        {
            "<leader>gB", "<cmd>lua require('gitsigns').blame_line({ full = true })<cr>", desc = "Blame Show"
        },
        { "<leader>gv", "<cmd>Gitsigns show",                                       desc = "Show Base File" }, -- show the base of the file

        -- Telescope
        { "<leader>gc", "<cmd>lua require('telescope.builtin').git_branches()<cr>", },
        { "<leader>gC", "<cmd>lua require('telescope.builtin').git_commits()<cr>", },
        { "<leader>go", "<cmd>lua require('telescope.builtin').git_status()<cr>", },

        -- Neogit
        { "<leader>gn", "<cmd>Neogit<cr>", },

        -- Differview
        { "<leader>gD", "<cmd>DiffviewOpen<cr>", },
    }
}

M.lsp = {
    { "<leader>L",  group = "LSP" },
    { "<leader>Lf", "<cmd>lua vim.lsp.buf.format({ async=false })<cr>", desc = "Format" },
    {
        "<leader>LF",
        function()
            if vim.g.custom_enable_auto_format then
                vim.g.custom_enable_auto_format = false
                vim.notify("File autoformat is disabled", "info", { title = "LSP Autoformat" })
            else
                vim.g.custom_enable_auto_format = true
                vim.notify("File autoformat is enabled", "info", { title = "LSP Autoformat" })
            end
        end,
        desc = "Auto Format Toggle",
    },
    { "<leader>LK", "<cmd>lua vim.lsp.buf.hover()<CR>",    desc = "Hover" },
    { "<leader>LH", "<cmd>LspInfo<cr>",                    desc = "Info" },
    { "<leader>LI", "<cmd>Mason<cr>",                      desc = "Mason Info" },
    { "<leader>LL", "<cmd>lua vim.lsp.codelens.run()<cr>", desc = "CodeLens Action" },
    {
        "<leader>Ln",
        "<cmd>lua vim.lsp.diagnostic.goto_next()<CR>",
        desc = "Next Diagnostic",
    },
    { "<leader>LN", "<cmd>NullLsInfo<cr>",                                              desc = "Null-Ls Info" },
    {
        "<leader>Lp",
        "<cmd>lua vim.lsp.diagnostic.goto_prev()<cr>",
        desc = "Prev Diagnostic",
    },
    { "<leader>Lq", "<cmd>lua require('telescope.builtin').diagnostics()<cr>",          desc = "Diagnostic" },
    { "<leader>LR", "<cmd>lua vim.lsp.buf.rename()<cr>",                                desc = "Rename" },
    { "<leader>Ls", "<cmd>lua require('telescope.builtin').lsp_document_symbols()<cr>", desc = "Document Symbols" },
    {
        "<leader>LS",
        "<cmd>lua require('telescope.builtin').lsp_dynamic_workspace_symbols()<cr>",
        desc = "Workspace Symbols",
    },

    -- lsp handlers
    { "ga", desc = "Code Action" },
    { "gd", desc = "Goto Definition" },
    { "gD", desc = "Goto Declaration" },
    { "gj", desc = "Move Text Down" },
    { "gi", desc = "Goto Implementation" },
    { "gk", desc = "Move Text Up" },
    { "gh", desc = "Signature Help" },
    { "gl", desc = "Show Diagnostic" },
    { "gq", desc = "Diagnostic List" },
    { "gr", desc = "References" },
    { "gR", desc = "Rename" },
    { "[d", desc = "Prev Diagnostic" },
    { "]d", desc = "Next Diagnostic" },


}

M.lang = {
    { "<leader>o",    "<cmd>SymbolsOutline<cr>",                              desc = "Code OutLine" },

    { "<leader>l",    group = "Language" },

    -- C/C++
    { "<leader>lc",   group = "C/C++" },
    { "<leader>lct",  "<cmd>edit .clang-tidy<cr>",                            desc = "Clang Tidy", },
    { "<leader>lcf",  "<cmd>edit .clang-format<cr>",                          desc = "Clang Format" },

    -- Golang
    { "<leader>lg",   group = "Golang" },
    { "<leader>lga",  "<cmd>GoCodeAction<cr>",                                desc = "Code action" },
    { "<leader>lge",  "<cmd>GoIfErr<cr>",                                     desc = "Add if err" },
    { "<leader>lgh",  group = "Helper" },
    { "<leader>lgha", "<cmd>GoAddTag<cr>",                                    desc = "Add tags to struct" },
    { "<leader>lghr", "<cmd>GoRMTag<cr>",                                     desc = "Remove tags to struct" },
    { "<leader>lghc", "<cmd>GoCoverage<cr>",                                  desc = "Test coverage" },
    { "<leader>lghg", "<cmd>lua require('go.comment').gen()<cr>",             desc = "Generate comment" },
    { "<leader>lghv", "<cmd>GoVet<cr>",                                       desc = "Go vet" },
    { "<leader>lght", "<cmd>GoModTidy<cr>",                                   desc = "Go mod tidy" },
    { "<leader>lghi", "<cmd>GoModInit<cr>",                                   desc = "Go mod init" },
    { "<leader>lgi",  "<cmd>GoToggleInlay<cr>",                               desc = "Toggle inlay" },
    { "<leader>lgl",  "<cmd>GoLint<cr>",                                      desc = "Run linter" },
    { "<leader>lgo",  "<cmd>GoPkgOutline<cr>",                                desc = "Outline" },
    { "<leader>lgr",  "<cmd>GoRun<cr>",                                       desc = "Run" },
    { "<leader>lgs",  "<cmd>GoFillStruct<cr>",                                desc = "Autofill struct" },
    { "<leader>lgt",  group = "Tests" },
    { "<leader>lgtr", "<cmd>GoTest<cr>",                                      desc = "Run tests" },
    { "<leader>lgta", "<cmd>GoAlt!<cr>",                                      desc = "Open alt file" },
    { "<leader>lgts", "<cmd>GoAltS!<cr>",                                     desc = "Open alt file in split" },
    { "<leader>lgtv", "<cmd>GoAltV!<cr>",                                     desc = "Open alt file in vertical split" },
    { "<leader>lgtu", "<cmd>GoTestFunc<cr>",                                  desc = "Run test for current func" },
    { "<leader>lgtf", "<cmd>GoTestFile<cr>",                                  desc = "Run test for current file" },
    { "<leader>lgx",  group = "Code Lens" },
    { "<leader>lgxl", "<cmd>GoCodeLenAct<cr>",                                desc = "Toggle Lens" },
    { "<leader>lgxa", "<cmd>GoCodeAction<cr>",                                desc = "Code Action" },

    -- Rust
    { "<leader>lr",   group = "Rust" },
    { "<leader>lrc",  group = "Crates" },
    { "<leader>lrcd", "<cmd>lua require('crates').open_documentation()<cr>",  desc = "Documentation" },
    { "<leader>lrcf", "<cmd>lua require('crates').show_features_popup()<cr>", desc = "Features" },
    { "<leader>lrcg", "<cmd>lua require('crates').open_repository()<cr>",     desc = "Repository" },
    { "<leader>lrch", "<cmd>lua require('crates').open_homepage()<cr>",       desc = "Homepage" },
    { "<leader>lrci", "<cmd>lua require('crates').upgrade_crate()<cr>",       desc = "Upgrade" },
    { "<leader>lrcI", "<cmd>lua require('crates').upgrade_all_crates()<cr>",  desc = "Upgrade All" },
    { "<leader>lrco", "<cmd>lua require('crates').toggle()<cr>",              desc = "Toggle" },
    { "<leader>lrcp", "<cmd>lua require('crates').open_crates_io()<cr>",      desc = "Creates.io" },
    { "<leader>lrcr", "<cmd>lua require('crates').reload()<cr>",              desc = "Reload" },
    { "<leader>lrcu", "<cmd>lua require('crates').update_crate()<cr>",        desc = "Update" },
    { "<leader>lrcU", "<cmd>lua require('crates').update_all_crates()<cr>",   desc = "Update All" },
    { "<leader>lrcv", "<cmd>lua require('crates').show_versions_popup()<cr>", desc = "Versions" },

    {
        "<leader>lrr",
        function()
            vim.cmd.RustLsp('runnables')
        end,
        desc = "Run"
    },
    {
        "<leader>lrm",
        function()
            vim.cmd.RustLsp('expandMacro')
        end,
        desc = " Expand Macro"
    },
    {
        "<leader>lrM",
        function()
            vim.cmd.RustLsp('rebuildProcMacros')
        end,
        desc = "Rebuild Proc Macros"
    },
    {
        "<leader>lra",
        function()
            vim.cmd.RustLsp('codeAction')
        end,
        desc = "Code Action"
    },
    {
        "<leader>lre",
        function()
            vim.cmd.RustLsp('explainError')
        end,
        desc = "Explain Error"
    },
    {
        "<leader>lrD",
        function()
            vim.cmd.RustLsp('renderDiagnostic')
        end,
        desc = "Render Diagnostic"
    },
    {
        "<leader>lrC",
        function()
            vim.cmd.RustLsp('openCargo')
        end,
        desc = "Open Cargo"
    },
    {
        "<leader>lrs",
        function()
            vim.cmd.RustLsp('openDocs')
        end,
        desc = "Doc current symbol"
    },

    -- Latex
    { "<leader>lt",  group = "Latex" },
    { "<leader>lti", "<plug>(vimtex-info)",           desc = "Info" },
    { "<leader>ltI", "<plug>(vimtex-info-full)",      desc = "Info Full" },
    { "<leader>ltt", "<plug>(vimtex-toc-open)",       desc = "Toc Open" },
    { "<leader>ltT", "<plug>(vimtex-toc-toggle)",     desc = "Toc Toggle" },
    { "<leader>ltq", "<plug>(vimtex-log)",            desc = "Log" },
    { "<leader>ltv", "<plug>(vimtex-view)",           desc = "View" },
    { "<leader>ltr", "<plug>(vimtex-reverse-search)", desc = "Reverse Search" },
    { "<leader>ltl", "<plug>(vimtex-compile)",        desc = "Compile" },
    { "<leader>ltk", "<plug>(vimtex-stop)",           desc = "Stop" },
    { "<leader>ltK", "<plug>(vimtex-stop-all)",       desc = "Stop All" },
    { "<leader>lte", "<plug>(vimtex-errors)",         desc = "Errors" },
    { "<leader>lto", "<plug>(vimtex-compile-output)", desc = "Compile Output" },
    { "<leader>ltg", "<plug>(vimtex-status)",         desc = "Status" },
    { "<leader>ltG", "<plug>(vimtex-status-all)",     desc = "Status All" },
    { "<leader>ltc", "<plug>(vimtex-clean)",          desc = "Clean" },
    { "<leader>ltC", "<plug>(vimtex-clean-full)",     desc = "Clean Full" },
    { "<leader>ltm", "<plug>(vimtex-imaps-list)",     desc = "Imaps List" },
    { "<leader>ltx", "<plug>(vimtex-reload)",         desc = "Reload" },
    { "<leader>ltX", "<plug>(vimtex-reload-state)",   desc = "Reload State" },
    { "<leader>lts", "<plug>(vimtex-toggle-main)",    desc = "Toggle Main" },
    { "<leader>lta", "<plug>(vimtex-context-menu)",   desc = "Context Menu" },

    -- Markdown
    { "<leader>lm",  helper.markdown_helper(),        desc = "Markdown Preview" },
}

M.lazy = {
    { "<leader><leader>p",  group = "Lazy" },
    { "<leader><leader>pi", "<cmd>Lazy install<cr>", desc = "Install" },
    { "<leader><leader>ps", "<cmd>Lazy sync<cr>",    desc = "Sync" },
    { "<leader><leader>pS", "<cmd>Lazy health<cr>",  desc = "Status" },
    { "<leader><leader>pu", "<cmd>Lazy update<cr>",  desc = "Update" },
    { "<leader><leader>pp", "<cmd>Lazy profile<cr>", desc = "Profile" },
}

M.motion = {
    { "<leader>m",  group = "Motion" },
    { "<leader>mb", "<cmd>HopChar2<cr>", desc = "2-Char" },
    { "<leader>mc", "<cmd>HopChar1<cr>", desc = "Char" },
    { "<leader>ml", "<cmd>HopLine<cr>",  desc = "Line" },
    { "<leader>mw", "<cmd>HopWord<cr>",  desc = "Word" },
}

-- M.neorg = {
-- { "<leader>N", group = "Neorg" },
-- { "gF",        desc = "Neorg Hop Link" },
-- }

M.notify = {
    { "<leader><leader>n", "<cmd>lua require('notify').dismiss()<cr>", desc = "Dismiss Notifition" },
}

M.explorer = {
    { "<leader>n", "<cmd>NvimTreeToggle<cr>", desc = "Explorer" },
}

M.project = {
    { "<leader>P",  group = "Session" },
    { "<leader>Pc", "<cmd>SessionManager load_current_dir_session<cr>", desc = "Load Current Dirtectory" },
    { "<leader>Pd", "<cmd>SessionManager delete_session<cr>",           desc = "Delete Session" },
    { "<leader>Pl", "<cmd>SessionManager load_last_session<cr>",        desc = "Last Session" },
    { "<leader>Ps", "<cmd>SessionManager load_session<cr>",             desc = "Select Session" },
    { "<leader>Pw", "<cmd>SessionManager save_current_session<cr>",     desc = "Save Current Dirtectory" },
}


M.sniprun = {
    { "<leader>R", group = "Sniprun" },
    { "<leader>Rc", "<cmd>lua require’sniprun.display’.close_all()<cr>", desc = "Clear" },
    { "<leader>Rr", "<cmd>lua require’sniprun’.run()<cr>", desc = "Run" },
    { "<leader>Rs", "<cmd>lua require’sniprun’.reset()<cr>", desc = "Stop" },
}

M.search = {
    -- Telescope
    { "<leader>s",  group = "Search" },
    { "<leader>sc", "<cmd>lua require('telescope.builtin').commands()<cr>",    desc = "Commands" },
    { "<leader>sC", "<cmd>lua require('telescope.builtin').colorscheme()<cr>", desc = "Colorscheme" },
    { "<leader>sh", "<cmd>lua require('telescope.builtin').help_tags()<cr>",   desc = "Find Help" },
    { "<leader>sk", "<cmd>lua require('telescope.builtin').keymaps()<cr>",     desc = "Keymaps" },
    { "<leader>sm", "<cmd>lua require('telescope.builtin').man_pages()<cr>",   desc = "Man Pages" },
    { "<leader>sM", "<cmd>Noice<cr>",                                          desc = "Messages" },
    {
        "<leader>sn",
        "<cmd>lua require('telescope').extensions.notify.notify(require('telescope.themes').get_dropdown({}))<cr>",
        desc = "Notify",
    },
    { "<leader>sr",  "<cmd>lua require('telescope.builtin').oldfiles()<cr>",                desc = "Open Recent File" },
    { "<leader>sR",  "<cmd>lua require('telescope.builtin').registers()<cr>",               desc = "Registers" },
    { "<leader>ss",  "<cmd>lua require('telescope').extensions.luasnip.luasnip()<cr>",      desc = "Luasnip" },
    { "<leader>st",  "<cmd>lua require('telescope.builtin').tags()<cr>",                    desc = "Tags" },
    { "<leader>sy",  "<cmd>lua require('telescope').extensions.neoclip.default()<cr>",      desc = "Yank History" },
    { "<leader>sY",  "<cmd>lua require('telescope').extensions.macroscope.default()<cr>",   desc = "Macroscope" },

    -- Spectre
    -- { "<leader>S",   group = "Search & Replace" },

    { "<leader>S",   "<cmd>GrugFar<cr>",                                                    desc = "Search & Replace" },
    -- { "<leader>St",  group = "Option" },
    -- { "<leader>Sts", desc = "use sed to replace" },
    -- { "<leader>Sto", desc = "use oxi to replace" },
    -- { "<leader>Stu", desc = "update when vim writes to file" },
    -- { "<leader>Sti", desc = "toggle ignore case" },
    -- { "<leader>Sth", desc = "toggle search hidden" },

    -- dap
    { "<leader>sd",  group = "Dap" },
    { "<leader>sdc", "<cmd>lua require 'telescope'.extensions.dap.commands {}<cr>",         desc = "Commands" },
    { "<leader>sdC", "<cmd>lua require 'telescope'.extensions.dap.configurations {}<cr>",   desc = "Configs" },
    { "<leader>sdb", "<cmd>lua require 'telescope'.extensions.dap.list_breakpoints {}<cr>", desc = "Breakpoints" },
    { "<leader>sdv", "<cmd>lua require 'telescope'.extensions.dap.variables {}<cr>",        desc = "Variables" },
    { "<leader>sdf", "<cmd>lua require 'telescope'.extensions.dap.frames {}<cr>",           desc = "Frames" },
}

M.splitJoin = {
    { "gS", desc = "Split Line" },
    { "gJ", desc = "Join Block" },
}

M.startup = {
    { "<leader><leader>s", "<cmd>StartupTime<cr>", desc = "Startup Time" },
}


M.term = {
    -- ToggleTerm
    { "<leader>t",  group = "Terminal" },
    { "<leader>ta", "<cmd>ToggleTermToggleAll<cr>", desc = "All" },
    {
        "<leader>tc",
        helper.term_id_cmds("ToggleTermSendCurrentLine"),
        desc = "Send Line",
    },
    { "<leader>tf", "<cmd>ToggleTerm direction=float<cr>", desc = "Float" },
    {
        "<leader>th",
        helper.term_multi_hv(0.3, "horizontal"),
        desc = "Horizontal",
    },
    { "<leader>tq", "<cmd>q<cr>",                          desc = "Background" },
    { "<leader>tQ", "<cmd>q<cr>",                          desc = "Finish" },
    { "<leader>ts", group = "Specific" },
    {
        "<leader>tsg",
        function()
            if helper.filetype_check({ "c", "cpp", "rust" }) then
                local prog = vim.fn.input("Path to program: ", vim.fn.getcwd(), "file")
                vim.cmd(string.format("GdbStart gdb %s", prog))
            end
        end,
        desc = "GDB",
    },
    { "<leader>tsG", helper.lazygit_toggle,                 desc = "Lazygit" },
    {
        "<leader>tsl",
        function()
            if helper.filetype_check({ "c", "cpp", "rust" }) then
                local prog = vim.fn.input("Path to program: ", vim.fn.getcwd(), "file")
                vim.cmd(string.format("GdbStartLLDB lldb %s", prog))
            end
        end,
        desc = "LLDB",
    },
    {
        "<leader>tsr",
        function()
            if helper.filetype_check("rust") then
                local prog = vim.fn.input("Path to program: ", vim.fn.getcwd(), "file")
                vim.cmd(string.format("GdbStartLLDB rust-lldb %s", prog))
            end
        end,
        desc = "Rust LLDB",
    },
    {
        "<leader>tsR",
        function()
            if helper.filetype_check("rust") then
                local prog = vim.fn.input("Path to program: ", vim.fn.getcwd(), "file")
                vim.cmd(string.format("GdbStart rust-gdb %s", prog))
            end
        end,
        desc = "Rust GDB",
    },
    { "<leader>tt",  "<cmd>ToggleTerm direction=tab<cr>",   desc = "Tab" },
    { "<leader>tv",  helper.term_multi_hv(0.4, "vertical"), desc = "Vertical" },
    { "<leader>tw",  "<cmd>terminal<cr>",                   desc = "Window" },
}

M.undo = {
    { "<leader>u", "<cmd>lua require('telescope').extensions.undo.undo()<cr>", desc = "Undotree" },
}

M.trouble = {
    { "<leader>x",  group = "Trouble" },
    { "<leader>xd", "<cmd>Trouble document_diagnostics<cr>",  desc = "Document Diagnostics" },
    { "<leader>xl", "<cmd>Trouble loclist",                   desc = "LocList" },
    { "<leader>xq", "<cmd>Trouble quickfix<cr>",              desc = "Quickfix" },
    { "<leader>xr", "<cmd>Trouble lsp_references<cr>",        desc = "References" },
    { "<leader>xw", "<cmd>Trouble workspace_diagnostics<cr>", desc = "Workspace Diagnostics" },
    { "<leader>xx", "<cmd>Trouble<cr>",                       desc = "Trouble" },
}

M.wrapping = {
    { "[w", [[ <cmd>lua require('wrapping').soft_wrap_mode()<cr> ]], desc = "soft wrap mode" },
    { "]w", [[ <cmd>lua require('wrapping').hard_wrap_mode()<cr> ]], desc = "hard wrap mode" },
}

M.misc = {
    { "<leader>h",        "<cmd>nohlsearch<CR>",         desc = "No Highlight Search" },
    { "<leader>q",        "<cmd>x<cr>",                  desc = "Close Window" },
    { "<leader>Q",        "<cmd>xa<cr>",                 desc = "Quit Nvim" },

    -- Resizing window
    { "<leader>r",        group = "Resize Window" },
    { "<leader>rh",       "<C-w>h",                      desc = "Left" },
    { "<leader>rj",       "<C-w>j",                      desc = "Down" },
    { "<leader>rk",       "<C-w>k",                      desc = "Up" },
    { "<leader>rl",       "<C-w>l",                      desc = "Right" },
    { "<leader>r<",       "30<C-w><",                    desc = "Desc Weight" },
    { "<leader>r>",       "30<C-w>>",                    desc = "Incr Weight" },
    { "<leader>r+",       "10<C-w>+",                    desc = "Incr Height" },
    { "<leader>r-",       "10<C-w>-",                    desc = "Desc Height" },
    { "<leader>r_",       "<C-w>_",                      desc = "Max Height" },
    { "<leader>r|",       "<C-w>|",                      desc = "Max weight" },
    { "<leader>ro",       "<C-w>|<C-w>_",                desc = "Max H&W" },
    { "<leader>r=",       "<C-w>=",                      desc = "Equalize" },

    -- Tab
    { "<leader>T",        group = "Tab" },
    { "<leader>Tc",       "<cmd>tabclose<cr>",           desc = "Close" },
    { "<leader>Tn",       "<cmd>tabnew %<cr>",           desc = "New" },
    { "gt",               desc = "Next Tab" },
    { "gT",               desc = "Prev Tab" },

    -- Extend Keymaps
    { "<leader><leader>", group = "Ext" },

    -- Fold
    { "zd",               desc = "Delete Fold" },
    { "zD",               desc = "Recursion Delete Fold" },
    { "zE",               desc = "Eliminate All Folds" },
    { "zf",               desc = "Create Fold" },
    { "zF",               desc = "Create Fold Lines" },
    { "zj",               desc = "Next Fold Begin" },
    { "zk",               desc = "Prev Fold End" },
    { "zi",               desc = "Toggle Fold " },
    { "zn",               desc = "Disable Fold " },
    { "zN",               desc = "Enable Fold" },
    { "[z",               desc = "Current Fold Begin" },
    { "]z",               desc = "Current Fold End" },

    -- Diff
    { "[c",               desc = "Diff Backward" },
    { "]c",               desc = "Diff Backward" },
}




return M
