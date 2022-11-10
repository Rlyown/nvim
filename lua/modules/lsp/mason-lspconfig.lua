return function()
	-- the lsp-servers list
	local servers = {
		"asm_lsp",
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
		"yamlls",
		"lemminx",
	}

	require("mason-lspconfig").setup({
		-- A list of servers to automatically install if they're not already installed. Example: { "rust_analyzer@nightly", "sumneko_lua" }
		-- This setting has no relation with the `automatic_installation` setting.
		ensure_installed = servers,

		-- Whether servers that are set up (via lspconfig) should be automatically installed if they're not already installed.
		-- This setting has no relation with the `ensure_installed` setting.
		-- Can either be:
		--   - false: Servers are not automatically installed.
		--   - true: All servers set up via lspconfig are automatically installed.
		--   - { exclude: string[] }: All servers set up via lspconfig, except the ones provided in the list, are automatically installed.
		--       Example: automatic_installation = { exclude = { "rust_analyzer", "solargraph" } }
		automatic_installation = false,
	})

	local function get_config_path(server_name)
		return string.format("modules.lsp.settings.%s", server_name)
	end

	-- Dynamic setup servers
	require("mason-lspconfig").setup_handlers({
		-- The first entry (without a key) will be the default handler
		-- and will be called for each installed server that doesn't have
		-- a dedicated handler.
		function(server_name) -- default handler (optional)
			local opts = {
				on_attach = require("modules.lsp.handlers").on_attach,
				capabilities = require("modules.lsp.handlers").capabilities,
			}

			if server_name == "rust_analyzer" then
				-- enable auto-import
				opts.capabilities.textDocument.completion.completionItem.resolveSupport = {
					properties = { "documentation", "detail", "additionalTextEdits" },
				}
			end

			-- if detected server config file, automatically load it.
			local has_config, server_opts = pcall(require, get_config_path(server_name))
			if has_config then
				opts = vim.tbl_deep_extend("force", server_opts, opts)
			end

			-- This setup() function is exactly the same as lspconfig's setup function.
			-- Refer to https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md
			require("lspconfig")[server_name].setup(opts)
		end,
		-- Next, you can provide targeted overrides for specific servers.
		-- For example, a handler override for the `rust_analyzer`:
		--[[ ["rust_analyzer"] = function() ]]
		--[[ 	require("rust-tools").setup({}) ]]
		--[[ end, ]]
	})
end
