local status_ok, sig = pcall(require, "lsp_signature")
if not status_ok then
    return
end

sig.setup({
    bind = true, -- This is mandatory, otherwise border config won't get registered.
    handler_opts = {
        border = "rounded"
    }
})
