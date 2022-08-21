require("mason").setup({
	ui = {
		-- Whether to automatically check for new versions when opening the :Mason window.
		check_outdated_packages_on_open = true,

		-- The border to use for the UI window. Accepts same border values as |nvim_open_win()|.
		border = "none",

		icons = {
			-- The list icon to use for installed packages.
			package_installed = "✓",
			-- The list icon to use for packages that are installing, or queued for installation.
			package_pending = "➜",
			-- The list icon to use for packages that are not installed.
			package_uninstalled = "✗",
		},

		keymaps = {
			-- Keymap to expand a package
			toggle_package_expand = "<CR>",
			-- Keymap to install the package under the current cursor position
			install_package = "i",
			-- Keymap to reinstall/update the package under the current cursor position
			update_package = "u",
			-- Keymap to check for new version for the package under the current cursor position
			check_package_version = "c",
			-- Keymap to update all installed packages
			update_all_packages = "U",
			-- Keymap to check which installed packages are outdated
			check_outdated_packages = "C",
			-- Keymap to uninstall a package
			uninstall_package = "X",
			-- Keymap to cancel a package installation
			cancel_installation = "<C-c>",
			-- Keymap to apply language filter
			apply_language_filter = "<C-f>",
		},
	},

	-- The directory in which to install packages.
	--[[ install_root_dir = path.concat({ vim.fn.stdpath("data"), "mason" }), ]]

	pip = {
		-- These args will be added to `pip install` calls. Note that setting extra args might impact intended behavior
		-- and is not recommended.
		--
		-- Example: { "--proxy", "https://proxyserver" }
		install_args = {
			"-i",
			"https://pypi.tuna.tsinghua.edu.cn/simple",
		},
	},

	-- Controls to which degree logs are written to the log file. It's useful to set this to vim.log.levels.DEBUG when
	-- debugging issues with package installations.
	log_level = vim.log.levels.INFO,

	-- Limit for the maximum amount of packages to be installed at the same time. Once this limit is reached, any further
	-- packages that are requested to be installed will be put in a queue.
	max_concurrent_installers = 4,

	github = {
		-- The template URL to use when downloading assets from GitHub.
		-- The placeholders are the following (in order):
		-- 1. The repository (e.g. "rust-lang/rust-analyzer")
		-- 2. The release version (e.g. "v0.3.0")
		-- 3. The asset name (e.g. "rust-analyzer-v0.3.0-x86_64-unknown-linux-gnu.tar.gz")
		download_url_template = "https://github.com/%s/releases/download/%s/%s",
	},
})

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
