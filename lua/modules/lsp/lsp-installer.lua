local status_ok, lsp_installer = pcall(require, "nvim-lsp-installer")
if not status_ok then
	return
end

local function get_config_path(server_name)
	return string.format("modules.lsp.settings.%s", server_name)
end

-- the lsp-servers list
local servers = {
	"bashls",
	"clangd",
	"cmake",
	"dockerls",
	"gopls",
	"jsonls",
	"ltex",
	"rust_analyzer",
	"sumneko_lua",
	"taplo",
	"pyright",
}

-- auto install servers
for _, name in pairs(servers) do
	local server_is_found, server = lsp_installer.get_server(name)
	if server_is_found then
		if not server:is_installed() then
			print("Installing " .. name)
			server:install()
		end
	end
end

-- Register a handler that will be called for all installed servers.
-- Alternatively, you may also register handlers on specific server instances instead (see example below).
lsp_installer.on_server_ready(function(server)
	local opts = {
		on_attach = require("modules.lsp.handlers").on_attach,
		capabilities = require("modules.lsp.handlers").capabilities,
	}

	if server.name == "rust_analyzer" then
		-- enable auto-import
		opts.capabilities.textDocument.completion.completionItem.resolveSupport = {
			properties = { "documentation", "detail", "additionalTextEdits" },
		}
	end

	-- if detected server config file, automatically load it.
	local has_config, server_opts = pcall(require, get_config_path(server.name))
	if has_config then
		opts = vim.tbl_deep_extend("force", server_opts, opts)
	end

	-- This setup() function is exactly the same as lspconfig's setup function.
	-- Refer to https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md
	server:setup(opts)
end)
