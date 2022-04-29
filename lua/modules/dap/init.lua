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

require("modules.dap.ui")
require("modules.dap.vtext")

require("modules.dap.util").dap_signs_scheme(3)

-- setup adapter and language
require("modules.dap.settings.lldb_vscode") -- for C/Cpp/Rust
require("modules.dap.settings.delve") -- for Golang
require("modules.dap.settings.debugpy") -- for Python, default interpreter is /usr/bin/python3
