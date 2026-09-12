return {
    { "williamboman/mason.nvim", cmd = { "Mason", "MasonInstall" }, opts = {} },
    { "WhoIsSethDaniel/mason-tool-installer.nvim", dependencies = { "williamboman/mason.nvim" },
        cmd = { "MasonToolsInstallSync", "MasonToolsUpdateSync" }, opts = {
            ensure_installed = require("config").plan().tools,
            auto_update = false, run_on_start = false,
        },
    },
}
