return {
    require("modules.groups").spec({ ["<leader>d"] = "调试" }),
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
                        dap.configurations[ft] = { { name = "启动程序", type = "codelldb", request = "launch", cwd = "${workspaceFolder}", program = function() return vim.fn.input("可执行文件: ", vim.fn.getcwd() .. "/", "file") end } }
                    end
                end
            end
            if config.enabled("python") then
                dap.adapters.python = { type = "executable", command = vim.fn.stdpath("data") .. "/mason/packages/debugpy/venv/bin/python", args = { "-m", "debugpy.adapter" } }
                dap.configurations.python = { { type = "python", request = "launch", name = "当前文件", program = "${file}", pythonPath = "python3" } }
            end
            if config.enabled("go") then
                dap.adapters.delve = { type = "server", port = "${port}", executable = { command = bin .. "dlv", args = { "dap", "-l", "127.0.0.1:${port}" } } }
                dap.configurations.go = { { type = "delve", request = "launch", name = "当前包", program = "${fileDirname}" } }
            end
        end,
        keys = {
            { "<leader>dc", function() require("dap").continue() end, desc = "启动或继续调试" },
            { "<leader>db", function() require("dap").toggle_breakpoint() end, desc = "断点" },
            { "<leader>di", function() require("dap").step_into() end, desc = "步入" },
            { "<leader>do", function() require("dap").step_over() end, desc = "步过" },
            { "<leader>dO", function() require("dap").step_out() end, desc = "步出" },
            { "<leader>dq", function() require("dap").terminate() end, desc = "终止调试" },
            { "<leader>du", function() require("dapui").toggle() end, desc = "调试面板" },
            { "<leader>de", function() require("dapui").eval() end, mode = { "n", "x" }, desc = "求值" },
        },
    },
}
