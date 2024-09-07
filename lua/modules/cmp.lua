return function()
    local cmp = require("cmp")
    local compare = require("cmp.config.compare")

    -- Load default

    local luasnip = require("luasnip")
    require("luasnip.loaders.from_vscode").lazy_load()
    -- Load customized
    require("luasnip.loaders.from_vscode").lazy_load({ paths = { require("core.gvariable").snippet_dir } })

    -- local has_words_before = function()
    --     unpack = unpack or table.unpack
    --     local line, col = unpack(vim.api.nvim_win_get_cursor(0))
    --     return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
    -- end

    local has_words_before = function()
        if vim.api.nvim_buf_get_option(0, "buftype") == "prompt" then return false end
        local line, col = unpack(vim.api.nvim_win_get_cursor(0))
        return col ~= 0 and vim.api.nvim_buf_get_text(0, line - 1, 0, line - 1, col, {})[1]:match("^%s*$") == nil
    end

    local symbals = require("core.gvariable").symbol_map

    cmp.setup({
        enabled = function()
            return vim.api.nvim_buf_get_option(0, "buftype") ~= "prompt"
                or require("cmp_dap").is_dap_buffer()
        end,
        snippet = {
            expand = function(args)
                luasnip.lsp_expand(args.body) -- For `luasnip` users.
            end,
        },
        mapping = {
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
                if cmp.visible() and has_words_before() then
                    cmp.select_next_item({ behavior = cmp.SelectBehavior.Select })
                elseif luasnip.expand_or_jumpable() then
                    -- You could replace the expand_or_jumpable() calls with expand_or_locally_jumpable()
                    -- they way you will only jump inside the snippet region
                    luasnip.expand_or_jump()
                else
                    fallback()
                end
            end, { "i", "s" }),
            ["<S-Tab>"] = cmp.mapping(function(fallback)
                if cmp.visible() then
                    cmp.select_prev_item()
                elseif luasnip.jumpable(-1) then
                    luasnip.jump(-1)
                else
                    fallback()
                end
            end, { "i", "s" }),
        },
        formatting = {
            fields = { "kind", "abbr", "menu" },
            format = function(entry, vim_item)
                -- Kind icons
                vim_item.kind = string.format("%s", symbals[vim_item.kind])
                -- vim_item.kind = string.format('%s %s', kind_icons[vim_item.kind], vim_item.kind) -- This concatonates the icons with the name of the item kind
                vim_item.menu = ({
                    luasnip = "[Snippet]",
                    nvim_lsp = "[Lsp]",
                    buffer = "[Buffer]",
                    path = "[Path]",
                    nvim_lua = "[Nvim]",
                    spell = "[Abc]",
                    copilot = "[Cpt]",
                    neorg = "[Norg]",
                    vimtex = vim_item.menu,
                })[entry.source.name]
                return vim_item
            end,
        },
        sources = {
            -- { name = "omni",       trigger_characters = { "{", "\\" } },
            { name = "vimtex",   priority = 11 },
            { name = "copilot",  priority = 10 },
            { name = "nvim_lsp", priority = 9 },
            { name = "luasnip",  priority = 8 },
            { name = "neorg",    priority = 7 },
            { name = "nvim_lua", priority = 6 },
            { name = "buffer",   priority = 5 },
            { name = "path",     priority = 4 },
            -- { name = "fuzzy_path", priority = 4 },
            -- {
            --     name = "spell",
            --     option = {
            --         keep_all_entries = false,
            --     },
            --     priority = 3,
            -- },

        },
        sorting = {
            priority_weight = 2.0,
            comparators = {
                require("copilot_cmp.comparators").prioritize,

                -- compare.score_offset, -- not good at all
                compare.locality,
                compare.recently_used,
                compare.score, -- based on :  score = score + ((#sources - (source_index - 1)) * sorting.priority_weight)
                compare.offset,
                compare.order,
                -- compare.scopes, -- what?
                -- compare.sort_text,
                -- compare.exact,
                -- compare.kind,
                -- compare.length, -- useless
            },
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

    -- `/` cmdline setup.
    cmp.setup.cmdline({ "/", "?" }, {
        mapping = cmp.mapping.preset.cmdline(),
        sources = {
            { name = "buffer" },
        },
    })
    -- `:` cmdline setup.
    cmp.setup.cmdline(":", {
        mapping = cmp.mapping.preset.cmdline(),
        sources = cmp.config.sources({
            { name = "path" },
            -- { name = "fuzzy_path", option = { fd_timeout_msec = 1500 } },
        }, {
            {
                name = "cmdline",
                option = {
                    ignore_cmds = { "Man", "!" },
                },
            },
        }),
    })

    -- dap
    require("cmp").setup.filetype({ "dap-repl", "dapui_watches", "dapui_hover" }, {
        sources = {
            { name = "dap" },
        },
    })

    local autopairs = require("nvim-autopairs.completion.cmp")
    cmp.event:on("confirm_done", autopairs.on_confirm_done())
end
