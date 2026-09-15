local M = {}
function M.get()
    local c = require("config")
    local specs = {}
    local function add(module)
        vim.list_extend(specs, require("plugins." .. module))
    end
    -- Explicit module boundaries keep helper modules out of Lazy scanning.
    add("colorschemes")
    if c.enabled("editor") then add("editor") end
    if c.enabled("ui") then add("ui") end
    if c.enabled("search") or c.enabled("explorer") or c.enabled("terminal") or c.enabled("images") then add("snacks") end
    if c.enabled("completion") then add("completions") end
    if c.enabled("treesitter") then add("treesitter") end
    if c.enabled("git") then add("git") end
    if c.enabled("session") then add("session") end
    if c.enabled("ai") then add("ai") end
    if c.enabled("copilot") then add("copilot") end
    if c.enabled("remote") then add("remote") end
    add("markdown")
    local plan = c.plan()
    if #plan.tools > 0 then add("tools") end
    if #plan.servers > 0 or c.enabled("rust") or c.enabled("sql") or c.enabled("web") then add("lsp") end
    for _, lang in ipairs({ "go", "rust", "tex", "sql", "csv" }) do
        if c.enabled(lang) then add("languages." .. lang) end
    end
    if c.enabled("dap") then add("dap") end
    -- Declare disabled lock entries to preserve optional plugin revisions when installing the base profile.
    local active = {}
    local roots = {}
    for _, spec in ipairs(specs) do if not spec.optional and spec.enabled ~= false then roots[spec[1]] = true end end
    local function visit(spec)
        if type(spec) == "string" then active[spec:match("[^/]+$")] = true; return end
        if spec.enabled == false or (spec.optional and not roots[spec[1]]) then return end
        if spec[1] then active[spec.name or spec[1]:match("[^/]+$")] = true end
        for _, dep in ipairs(spec.dependencies or {}) do visit(dep) end
    end
    for _, spec in ipairs(specs) do visit(spec) end
    local lock = vim.env.NVIM_LOCKFILE or (vim.env.NVIM_CONFIG_ROOT or vim.fn.stdpath("config")) .. "/lazy-lock.json"
    if vim.fn.filereadable(lock) == 1 then
        for name in pairs(vim.json.decode(table.concat(vim.fn.readfile(lock), "\n"))) do
            if name ~= "lazy.nvim" and not active[name] then table.insert(specs, { name, name = name, enabled = false }) end
        end
    end
    return specs
end
return M
