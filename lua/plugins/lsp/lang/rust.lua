return {
    {
        'mrcjkb/rustaceanvim',
        version = '^6', -- Recommended
        lazy = false,   -- This plugin is already lazy
        keys = {
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
        }
    },
    {
        "saecki/crates.nvim",
        event = { "BufRead Cargo.toml" },
        config = true,
        lazy = true,
        keys = {
            { "<leader>lrcd", function() require('crates').open_documentation() end,  desc = "Documentation" },
            { "<leader>lrcf", function() require('crates').show_features_popup() end, desc = "Features" },
            { "<leader>lrcg", function() require('crates').open_repository() end,     desc = "Repository" },
            { "<leader>lrch", function() require('crates').open_homepage() end,       desc = "Homepage" },
            { "<leader>lrci", function() require('crates').upgrade_crate() end,       desc = "Upgrade" },
            { "<leader>lrcI", function() require('crates').upgrade_all_crates() end,  desc = "Upgrade All" },
            { "<leader>lrco", function() require('crates').toggle() end,              desc = "Toggle" },
            { "<leader>lrcp", function() require('crates').open_crates_io() end,      desc = "Creates.io" },
            { "<leader>lrcr", function() require('crates').reload() end,              desc = "Reload" },
            { "<leader>lrcu", function() require('crates').update_crate() end,        desc = "Update" },
            { "<leader>lrcU", function() require('crates').update_all_crates() end,   desc = "Update All" },
            { "<leader>lrcv", function() require('crates').show_versions_popup() end, desc = "Versions" },

            { "<leader>lru",  function() require('crates').update_crates() end,       desc = "Update" },
            { "<leader>lrU",  function() require('crates').upgrade_crates() end,      desc = "Upgrade" },
        }
    }, -- helps managing crates.io dependencies
}
