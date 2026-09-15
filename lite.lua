-- Zero-plugin remote configuration for Neovim 0.12.4. Usage: nvim --clean -u /path/to/lite.lua
if vim.fn.has("nvim-0.12.4") ~= 1 then
    vim.api.nvim_echo({ { "lite.lua requires Neovim 0.12.4 or later", "ErrorMsg" } }, true, {})
    return
end

vim.g.mapleader = " "

local options = {
    backup = false,
    clipboard = "unnamedplus",
    completeopt = { "menu", "menuone", "noselect" },
    expandtab = true,
    ignorecase = true,
    mouse = "a",
    number = true,
    scrolloff = 8,
    shiftwidth = 4,
    smartcase = true,
    signcolumn = "yes",
    splitbelow = true,
    splitright = true,
    tabstop = 4,
    termguicolors = true,
    undofile = true,
    updatetime = 300,
}

for name, value in pairs(options) do
    vim.opt[name] = value
end

local map = vim.keymap.set
map("n", "<leader>w", "<cmd>write<cr>", { desc = "Save" })
map("n", "<leader>q", "<cmd>quit<cr>", { desc = "Quit" })
map("n", "<leader>h", "<cmd>nohlsearch<cr>", { desc = "Clear search highlight" })
map("n", "<leader>e", "<cmd>Explore<cr>", { desc = "File explorer" })
map("n", "<leader>t", "<cmd>split | terminal<cr>", { desc = "Terminal" })
map("n", "[d", function() vim.diagnostic.jump({ count = -1, float = true }) end, { desc = "Previous diagnostic" })
map("n", "]d", function() vim.diagnostic.jump({ count = 1, float = true }) end, { desc = "Next diagnostic" })
map("n", "gl", vim.diagnostic.open_float, { desc = "Diagnostic details" })
map("n", "gd", vim.lsp.buf.definition, { desc = "Go to definition" })
map("n", "gr", vim.lsp.buf.references, { desc = "References" })
map("n", "K", vim.lsp.buf.hover, { desc = "Hover" })
map("n", "<leader>lr", vim.lsp.buf.rename, { desc = "Rename symbol" })
map("n", "<leader>lf", function() vim.lsp.buf.format({ async = true }) end, { desc = "Format buffer" })

local function quickfix_from(command, title, errorformat)
    local output = vim.fn.systemlist(command)
    if vim.v.shell_error ~= 0 and #output == 0 then
        vim.notify(title .. " failed: " .. command[1], vim.log.levels.WARN)
        return
    end
    vim.fn.setqflist({}, " ", { title = title, lines = output, efm = errorformat })
    vim.cmd("copen")
end

vim.api.nvim_create_user_command("LiteFiles", function()
    local command = vim.fn.executable("rg") == 1 and { "rg", "--files", "--hidden", "--glob", "!.git" }
        or { "find", ".", "-type", "f" }
    quickfix_from(command, "Files", "%f")
end, {})

vim.api.nvim_create_user_command("LiteGrep", function(args)
    if vim.fn.executable("rg") ~= 1 then
        vim.notify("LiteGrep requires ripgrep (rg)", vim.log.levels.WARN)
        return
    end
    quickfix_from({ "rg", "--vimgrep", args.args }, "Grep: " .. args.args, "%f:%l:%c:%m")
end, { nargs = 1 })

map("n", "<leader>ff", "<cmd>LiteFiles<cr>", { desc = "Find files" })
map("n", "<leader>fg", function()
    vim.ui.input({ prompt = "Grep> " }, function(query)
        if query and query ~= "" then
            vim.cmd("LiteGrep " .. vim.fn.fnameescape(query))
        end
    end)
end, { desc = "Grep project" })

local servers = {
    clangd = { command = "clangd", filetypes = { "c", "cpp", "objc", "objcpp", "cuda" } },
    gopls = { command = "gopls", filetypes = { "go", "gomod", "gowork", "gotmpl" } },
    rust_analyzer = { command = "rust-analyzer", filetypes = { "rust" } },
    pyright = { command = "pyright-langserver", filetypes = { "python" } },
    lua_ls = { command = "lua-language-server", filetypes = { "lua" } },
}

for name, server in pairs(servers) do
    if vim.fn.executable(server.command) == 1 then
        vim.lsp.config(name, {
            cmd = { server.command },
            filetypes = server.filetypes,
            root_markers = { ".git" },
        })
        vim.lsp.enable(name)
    end
end

local group = vim.api.nvim_create_augroup("lite_lsp", { clear = true })
vim.api.nvim_create_autocmd("LspAttach", {
    group = group,
    callback = function(event)
        local client = vim.lsp.get_client_by_id(event.data.client_id)
        if client and client:supports_method("textDocument/formatting") then
            map("n", "<leader>lf", function()
                vim.lsp.buf.format({ bufnr = event.buf, async = true })
            end, { buffer = event.buf, desc = "Format buffer" })
        end
    end,
})
