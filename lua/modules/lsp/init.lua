local M = {
    mason = require("modules.lsp.mason"),
    mason_lspconfig = require("modules.lsp.mason-lspconfig"),
    mason_tool_installer = require("modules.lsp.mason-tool-installer"),
    null_ls = require("modules.lsp.null-ls"),
    signature = require("modules.lsp.signature"),
    lightbulb = require("modules.lsp.lightbulb"),
    refactoring = require("modules.lsp.refactoring"),
    go = require("modules.lsp.go"),
    neodev = require("modules.lsp.neodev"),
    vimtex = require("modules.lsp.vimtex"),
    -- rust = require("modules.lsp.rust"),
}

return M
