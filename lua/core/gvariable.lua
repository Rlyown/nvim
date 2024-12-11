local M = {}

if vim.fn.has("mac") == 1 then
    M.os = "mac"
elseif vim.fn.has("unix") == 1 then
    M.os = "unix"
else
    M.os = "unsupport"
end

local system = require("core.gfunc").fn.system

-- Set the python3 path which installed pynvim
vim.g.python3_host_prog = "python3"

M.modules_dir = vim.fn.stdpath("config") .. "/lua/modules"
M.snippet_dir = vim.fn.stdpath("config") .. "/snippets"
M.neorg_dir = vim.fn.stdpath("state") .. "/neorg-notes"

M.node_path = "node"

M.compiler = {
    "clang",
    "clang++",
    "gcc",
    "g++",
}

M.symbol_map = {
    Text = "T",
    Method = "",
    Function = "f",
    Constructor = "",
    Field = "",
    Variable = "",
    Class = "",
    Interface = "",
    Module = "m",
    Property = "",
    Unit = "",
    Value = "",
    Enum = "",
    Keyword = "",
    Key = "",
    Null = "0",
    Snippet = "",
    Color = "",
    File = "",
    Reference = "",
    Folder = "",
    EnumMember = "",
    Constant = "",
    Struct = "",
    Event = "",
    Operator = "",
    TypeParameter = "",
    Namespace = "",
    Package = "",
    String = "",
    Number = "N",
    Boolean = "",
    Array = "",
    Object = "⦿",
    Copilot = "",
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
