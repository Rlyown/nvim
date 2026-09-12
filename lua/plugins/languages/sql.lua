return {
    { "saghen/blink.cmp", optional = true, dependencies = { { "saghen/blink.compat", opts = {} } }, opts = {
        sources = { per_filetype = { sql = { "dbee", "buffer" } }, providers = {
            dbee = { name = "dbee", module = "blink.compat.source" },
        } },
    } },
    { "kndndrj/nvim-dbee", ft = "sql", dependencies = { "MunifTanjim/nui.nvim" },
        build = function() if not require("config").get().offline then require("dbee").install() end end,
        opts = {}, keys = { { "<localleader>a", function() require("dbee").toggle() end, ft = "sql", desc = "数据库" } },
    },
}
