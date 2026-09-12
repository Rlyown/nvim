return {
    { "saghen/blink.cmp", event = "InsertEnter", dependencies = { "rafamadriz/friendly-snippets", { "xzbdmw/colorful-menu.nvim", opts = {} } }, opts = {
        keymap = { preset = "default", ["<Tab>"] = { "snippet_forward", "fallback" }, ["<S-Tab>"] = { "snippet_backward", "fallback" } },
        sources = { default = { "lsp", "path", "snippets", "buffer" } },
        snippets = { preset = "default" },
        fuzzy = { implementation = "lua" },
        completion = { documentation = { auto_show = true }, menu = { draw = {
            columns = { { "kind_icon" }, { "label", gap = 1 } },
            components = { label = { text = function(ctx) return require("colorful-menu").blink_components_text(ctx) end, highlight = function(ctx) return require("colorful-menu").blink_components_highlight(ctx) end } },
        } } },
    } },
}
