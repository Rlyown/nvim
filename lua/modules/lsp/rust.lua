return function()
    vim.g.rustaceanvim.server.on_attach = require("modules.lsp.handlers").on_attach
    vim.g.rustaceanvim.server.settings = function(project_root)
        local ra = require('rustaceanvim.config.server')
        return ra.load_rust_analyzer_settings(project_root, {
            settings_file_pattern = 'rust-analyzer.json'
        })
    end
end
