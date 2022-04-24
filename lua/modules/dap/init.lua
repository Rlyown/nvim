local dap = require("dap")
local dapui = require("dapui")

dap.listeners.after.event_initialized["dapui_config"] = function()
	dapui.open()
end
dap.listeners.before.event_terminated["dapui_config"] = function()
	dapui.close()
	dap.repl.close()
end
dap.listeners.before.event_exited["dapui_config"] = function()
	dapui.close()
	dap.repl.close()
end

vim.fn.sign_define("DapBreakpoint", { text = "", texthl = "DiagnosticSignHint", linehl = "", numhl = "" })
vim.fn.sign_define("DapBreakpointCondition", { text = "", texthl = "DiagnosticSignHint", linehl = "", numhl = "" })
vim.fn.sign_define("DapLogPoint", { text = "ﱴ", texthl = "DiagnosticSignHint", linehl = "", numhl = "" })
vim.fn.sign_define("DapStopped", {
	text = "",
	texthl = "DiagnosticSignInfo",
	linehl = "Todo",
	numhl = "CursorLineNr",
})
vim.fn.sign_define("DapBreakpointRejected", { text = "", texthl = "DiagnosticSignError", linehl = "", numhl = "" })

require("modules.dap.ui")
require("modules.dap.vtext")

-- setup adapter and language
-- codelldb will display disassembly
-- require("modules.dap.settings.codelldb") -- for C/Cpp/Rust
require("modules.dap.settings.lldb-vscode") -- for C/Cpp/Rust
require("modules.dap.settings.delve") -- for Golang
require("modules.dap.settings.debugpy") -- for Python, default interpreter is /usr/bin/python3
