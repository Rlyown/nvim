local cmp_status_ok, cmp = pcall(require, "cmp")
if not cmp_status_ok then
	return
end

local snip_status_ok, luasnip = pcall(require, "luasnip")
if not snip_status_ok then
	return
end

local pairs_status_ok, autopairs = pcall(require, "nvim-autopairs.completion.cmp")
if not pairs_status_ok then
	return
end

-- Load default
require("luasnip/loaders/from_vscode").lazy_load()
-- Load customized
require("luasnip/loaders/from_vscode").lazy_load({ paths = { vim.fn.stdpath("config") .. "/my-snippets" } })

local check_backspace = function()
	local col = vim.fn.col(".") - 1
	return col == 0 or vim.fn.getline("."):sub(col, col):match("%s")
end

local symbals = require("core.gvariable").symbol_map

cmp.setup({
	snippet = {
		expand = function(args)
			luasnip.lsp_expand(args.body) -- For `luasnip` users.
		end,
	},
	mapping = {
		["<C-k>"] = cmp.mapping.select_prev_item(),
		["<C-j>"] = cmp.mapping.select_next_item(),
		["<C-b>"] = cmp.mapping(cmp.mapping.scroll_docs(-1), { "i", "c" }),
		["<C-f>"] = cmp.mapping(cmp.mapping.scroll_docs(1), { "i", "c" }),
		["<C-Space>"] = cmp.mapping(cmp.mapping.complete(), { "i", "c" }),
		["<C-y>"] = cmp.config.disable, -- Specify `cmp.config.disable` if you want to remove the default `<C-y>` mapping.
		["<C-e>"] = cmp.mapping({
			i = cmp.mapping.abort(),
			c = cmp.mapping.close(),
		}),
		-- Accept currently selected item. If none selected, `select` first item.
		-- Set `select` to `false` to only confirm explicitly selected items.
		["<CR>"] = cmp.mapping.confirm({ select = true }),
		["<Tab>"] = cmp.mapping(function(fallback)
			if cmp.visible() then
				cmp.select_next_item()
			elseif luasnip.expandable() then
				luasnip.expand()
			elseif luasnip.expand_or_jumpable() then
				luasnip.expand_or_jump()
			elseif check_backspace() then
				fallback()
			else
				fallback()
			end
		end, {
			"i",
			"s",
		}),
		["<S-Tab>"] = cmp.mapping(function(fallback)
			if cmp.visible() then
				cmp.select_prev_item()
			elseif luasnip.jumpable(-1) then
				luasnip.jump(-1)
			else
				fallback()
			end
		end, {
			"i",
			"s",
		}),
	},
	formatting = {
		fields = { "kind", "abbr", "menu" },
		format = function(entry, vim_item)
			-- Kind icons
			vim_item.kind = string.format("%s", symbals[vim_item.kind])
			-- vim_item.kind = string.format('%s %s', kind_icons[vim_item.kind], vim_item.kind) -- This concatonates the icons with the name of the item kind
			vim_item.menu = ({
				luasnip = "[Snippet]",
				nvim_lsp = "[LSP]",
				buffer = "[Buffer]",
				path = "[Path]",
				nvim_lua = "[Nvim]",
			})[entry.source.name]
			return vim_item
		end,
	},
	sources = {
		{ name = "nvim_lsp" },
		{ name = "luasnip" },
		{ name = "buffer" },
		{ name = "path" },
		{ name = "nvim_lua" },
		-- { name = "spell" },
		-- { name = 'copilot' },
	},
	confirm_opts = {
		behavior = cmp.ConfirmBehavior.Replace,
		select = false,
	},
	window = {
		documentation = {
			border = { "╭", "─", "╮", "│", "╯", "─", "╰", "│" },
		},
	},
	experimental = {
		ghost_text = false,
		native_menu = false,
	},
})

-- If you want insert `(` after select function or method item
local handlers = require("nvim-autopairs.completion.handlers")

cmp.event:on(
	"confirm_done",
	autopairs.on_confirm_done({
		filetypes = {
			-- "*" is a alias to all filetypes
			["*"] = {
				["("] = {
					kind = {
						cmp.lsp.CompletionItemKind.Function,
						cmp.lsp.CompletionItemKind.Method,
					},
					handler = handlers["*"],
				},
			},
			-- lua = {
			-- 	["("] = {
			-- 		kind = {
			-- 			cmp.lsp.CompletionItemKind.Function,
			-- 			cmp.lsp.CompletionItemKind.Method,
			-- 		},
			-- 		---@param char string
			-- 		---@param item item completion
			-- 		---@param bufnr buffer number
			-- 		handler = function(char, item, bufnr)
			-- 			-- Your handler function. Inpect with print(vim.inspect{char, item, bufnr})
			-- 		end,
			-- 	},
			-- },
			-- Disable for tex
			tex = false,
		},
	})
)

-- enable cmp spell check
-- vim.opt.spell = true
-- vim.opt.spelllang = { "en_us" }
