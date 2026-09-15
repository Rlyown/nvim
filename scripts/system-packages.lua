-- Platform package names; selection logic always comes from config.plan().
local map = {
    node = { "nodejs npm", "node" },
    git = { "git", "git" }, curl = { "curl", "curl" }, unzip = { "unzip", "unzip" },
    ripgrep = { "ripgrep", "ripgrep" }, fd = { "fd-find", "fd" }, trash = { "trash-cli", "trash" },
    cc = { "build-essential", "llvm" }, ["tree-sitter"] = { "npm", "tree-sitter-cli" },
    cmake = { "cmake", "cmake" }, go = { "golang-go", "go" }, rust = { "cargo", "rust" },
    python = { "python3 python3-venv", "python" }, latex = { "latexmk texlive-latex-extra", "texlive" },
    formulas = { "python3-pylatexenc", "pipx" }, fonts = { "fonts-firacode", "font-jetbrains-mono-nerd-font" },
    kitty = { "kitty", "kitty" }, images = { "imagemagick", "imagemagick" }, copilot = { "nodejs", "node" },
}
vim.opt.rtp:prepend(assert(vim.env.NVIM_CONFIG_ROOT))
local packages = {}
for _, item in ipairs(require("config").plan().system) do
    local value = assert(map[item], "Undefined system package: " .. item)[vim.env.NVIM_INSTALL_OS == "Darwin" and 2 or 1]
    for package in value:gmatch("%S+") do packages[package] = true end
end
local list = vim.tbl_keys(packages)
table.sort(list)
vim.fn.writefile(list, assert(vim.env.NVIM_PACKAGES_OUTPUT))
vim.cmd.qa()
