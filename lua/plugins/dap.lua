return {
    { "mfussenegger/nvim-dap", dependencies = { "rcarriga/nvim-dap-ui", "nvim-neotest/nvim-nio" },
        config = function()
            local dap, ui = require("dap"), require("dapui")
            ui.setup({})
            dap.listeners.after.event_initialized.config = function() ui.open() end
            dap.listeners.before.event_terminated.config = function() ui.close() end
            dap.listeners.before.event_exited.config = function() ui.close() end
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
            { "<leader>dc", function() require("dap").continue() end, desc = "Start or Continue" },
            { "<leader>db", function() require("dap").toggle_breakpoint() end, desc = "Toggle Breakpoint" },
            { "<leader>di", function() require("dap").step_into() end, desc = "Step Into" },
            { "<leader>do", function() require("dap").step_over() end, desc = "Step Over" },
            { "<leader>dO", function() require("dap").step_out() end, desc = "Step Out" },
            { "<leader>dq", function() require("dap").terminate() end, desc = "Terminate" },
            { "<leader>du", function() require("dapui").toggle() end, desc = "Debug UI" },
            { "<leader>de", function() require("dapui").eval() end, mode = { "n", "x" }, desc = "Evaluate" },
        },
    },
}
