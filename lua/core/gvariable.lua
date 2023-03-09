local M = {}

local system = require("core.gfunc").fn.system

-- Set the python3 path which installed pynvim
vim.g.python3_host_prog = system("command -v python3")

-- path to debuggers
M.debuggers = {
    delve = "dlv",
    --[[ codelldb = vim.fn.stdpath("data") .. "/mason/packages/codelldb/extension", ]]
    debugpy = vim.g.python3_host_prog,
    lldb_vscode = system("command -v lldb-vscode"),
}

M.modules_dir = vim.fn.stdpath("config") .. "/lua/modules"
M.snippet_dir = vim.fn.stdpath("config") .. "/snippets"
M.neorg_dir = vim.fn.stdpath("state") .. "/neorg-notes"

M.zeal_path = system("command -v zeal")
M.node_path = system("command -v node")

M.compiler = {
    system("command -v clang"),
    system("command -v clang++"),
    system("command -v gcc"),
    system("command -v g++"),
}

if vim.fn.has("mac") == 1 then
    local arch = require("jit").arch
    local homebrew_prefix = ""

    if arch == "x64" then
        homebrew_prefix = "/usr/local/"
    elseif arch == "arm64" then
        homebrew_prefix = "/opt/homebrew"
    end

    M.os = "mac"
    -- Set the python3 path which installed pynvim
    M.dash_path = "/Applications/Dash.app"
    M.node_path = homebrew_prefix .. "/opt/node@16/bin/node"

    M.debuggers.lldb_vscode = homebrew_prefix .. "/opt/llvm/bin/lldb-vscode"
elseif vim.fn.has("unix") == 1 then
    M.os = "unix"
    M.node_path = "/home/linuxbrew/.linuxbrew/opt/node@16/bin/node"
    M.debuggers.lldb_vscode = "/home/linuxbrew/.linuxbrew/opt/llvm/bin/lldb-vscode"
else
    M.os = "unsupport"
end

M.symbol_map = {
    Text = "",
    Method = "",
    Function = "",
    Constructor = "",
    Field = "ﰠ",
    Variable = "",
    Class = "ﴯ",
    Interface = "",
    Module = "",
    Property = "ﰠ",
    Unit = "塞",
    Value = "",
    Enum = "",
    Keyword = "",
    Key = "",
    Null = "ﳠ ",
    Snippet = "",
    Color = "",
    File = "",
    Reference = "",
    Folder = "",
    EnumMember = "",
    Constant = "",
    Struct = "פּ",
    Event = "",
    Operator = "",
    TypeParameter = "",
    Namespace = "",
    Package = "",
    String = "",
    Number = "",
    Boolean = "⊨",
    Array = "",
    Object = "⦿",
}

-- This function will be called at the end of init.lua
function M.setup()
    -- custom variable to enable or disable auto format by default.
    -- You can toggle it with keybinding <leader>lF
    vim.g.custom_enable_auto_format = true

    -- set default colorscheme
    local catppuccin_status_ok, _ = pcall(require, "catppuccin")
    if catppuccin_status_ok then
        vim.g.catppuccin_flavour = "mocha" -- latte, frappe, macchiato, mocha
        vim.cmd([[colorscheme catppuccin]])
    end

    -- set default notify function
    local notify_status_ok, notify = pcall(require, "notify")
    if notify_status_ok then
        vim.notify = notify
    end

    -- If you want to toggle git-editor with current nvim instead of a nested one after ":terminal",
    -- you can uncomment the following settings(tool "neovim-remote" is required):
    -- if vim.fn.has("nvim") and vim.fn.executable("nvr") then
    -- 	vim.cmd([[let $GIT_EDITOR = "nvr -cc split --remote-wait +'set bufhidden=delete'" ]])
    -- end
end

return M
