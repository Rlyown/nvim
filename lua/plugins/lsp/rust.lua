return {
    {
        'mrcjkb/rustaceanvim',
        version = '^5', -- Recommended
        lazy = false,   -- This plugin is already lazy
    },
    {
        "saecki/crates.nvim",
        event = { "BufRead Cargo.toml" },
        config = true,
        lazy = true
    }, -- helps managing crates.io dependencies
}
