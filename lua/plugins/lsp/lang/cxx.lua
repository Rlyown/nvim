return {
    {
        "julianolf/nvim-dap-lldb",
        enabled = require("core.features").enabled("cpp"),
        dependencies = { "mfussenegger/nvim-dap" },
        config = true,
    }
}
