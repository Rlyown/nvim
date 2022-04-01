local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities.offsetEncoding = { "utf-16" }

return {
	cmd = { "clangd", "--fallback-style=google" },
	capabilities = capabilities,
}
