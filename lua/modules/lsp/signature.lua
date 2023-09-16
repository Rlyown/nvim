return function()
    local sig = require("lsp_signature")

    sig.setup({
        bind = true, -- This is mandatory, otherwise border config won't get registered.
        handler_opts = {
            border = "rounded",
        },
        noice = true,
    })
end
