return {
    { "mfussenegger/nvim-dap", dependencies = { "rcarriga/nvim-dap-ui", "nvim-neotest/nvim-nio", "nvimtools/hydra.nvim" },
        config = function()
            local dap, ui = require("dap"), require("dapui")
            ui.setup({})
            require("modules.debug_mode").setup(dap, ui)
            local config = require("config")
            local bin = vim.fn.stdpath("data") .. "/mason/bin/"
            if config.enabled("cpp") or config.enabled("rust") then
                dap.adapters.codelldb = { type = "server", port = "${port}", executable = { command = bin .. "codelldb", args = { "--port", "${port}" } } }
                for _, ft in ipairs({ "c", "cpp", "rust" }) do
                    if (ft == "rust" and config.enabled("rust")) or (ft ~= "rust" and config.enabled("cpp")) then
                        dap.configurations[ft] = { { name = "Launch program", type = "codelldb", request = "launch", cwd = "${workspaceFolder}", program = function() return vim.fn.input("Executable: ", vim.fn.getcwd() .. "/", "file") end } }
                    end
                end
            end
            if config.enabled("python") then
                dap.adapters.python = { type = "executable", command = vim.fn.stdpath("data") .. "/mason/packages/debugpy/venv/bin/python", args = { "-m", "debugpy.adapter" } }
                dap.configurations.python = { { type = "python", request = "launch", name = "Current file", program = "${file}", pythonPath = "python3" } }
            end
            if config.enabled("go") then
                dap.adapters.delve = { type = "server", port = "${port}", executable = { command = bin .. "dlv", args = { "dap", "-l", "127.0.0.1:${port}" } } }
                dap.configurations.go = { { type = "delve", request = "launch", name = "Current package", program = "${fileDirname}" } }
            end
        end,
        keys = {
            { "<leader>dc", function() require("modules.debug_mode").continue() end, desc = "Start or Continue in Debug Mode" },
            { "<leader>db", function() require("dap").toggle_breakpoint() end, desc = "Toggle Breakpoint" },
            { "<leader>da", function() require("modules.debug_actions").launch_with_args() end, desc = "Debug with Arguments" },
            { "<leader>dl", function() require("modules.debug_actions").logpoint() end, desc = "Set Logpoint" },
            { "<leader>ds", function() require("dap").step_into() end, desc = "Step Into" },
            { "<leader>dn", function() require("dap").step_over() end, desc = "Step Over" },
            { "<leader>do", function() require("dap").step_out() end, desc = "Step Out" },
            { "<leader>dm", function() require("modules.debug_mode").enter() end, desc = "Enter Debug Mode Without Running" },
            { "<leader>dq", function() require("modules.debug_mode").exit(); require("dap").terminate() end, desc = "Terminate" },
            { "<leader>dB", function() vim.ui.input({ prompt = "Breakpoint condition: " }, function(value) if value and value ~= "" then require("dap").set_breakpoint(value) end end) end, desc = "Conditional Breakpoint" },
            { "<leader>dr", function() require("dap").run_last() end, desc = "Run Last Debug Session" },
            { "<leader>dR", function() require("dap").repl.toggle() end, desc = "Debug REPL" },
            { "<leader>du", function() require("dapui").toggle() end, desc = "Debug UI" },
            { "<leader>de", function() require("dapui").eval() end, mode = { "n", "x" }, desc = "Evaluate" },
        },
    },
}
