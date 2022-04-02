local status_ok, _ = pcall(require, "lspconfig")
if not status_ok then
	return
end

require("modules.lsp.lsp-installer")
require("modules.lsp.handlers").setup()
require("modules.lsp.null-ls")
require("modules.lsp.signature")
require("modules.lsp.lightbulb")
require("modules.lsp.refactoring")
require("modules.lsp.go")
