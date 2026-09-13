local M = {}
local catalog = require("config.capabilities")
local function csv(value)
    return vim.split(value or "", ",", { trimempty = true })
end
function M.resolve(user, override, env)
    user, override, env = user or {}, override or {}, env or vim.env
    local profile = env.NVIM_PROFILE or override.profile or user.profile or "minimal"
    assert(profile == "minimal" or profile == "developer", "Unknown profile: " .. profile)
    local result = { profile = profile, languages = {}, features = vim.deepcopy(catalog.features), sources = {} }
    for name in pairs(catalog.languages) do
        result.languages[name] = profile == "developer" and vim.tbl_contains({ "cpp", "go", "rust", "python" }, name)
        result.sources["languages." .. name] = "profile:" .. profile
    end
    for name in pairs(catalog.features) do result.sources["features." .. name] = "profile:" .. profile end
    local function set(kind, name, value, source)
        assert(catalog[kind][name] ~= nil, "Unknown " .. kind .. ": " .. name)
        assert(type(value) == "boolean", name .. " must be a boolean")
        result[kind][name] = value
        result.sources[kind .. "." .. name] = source
    end
    local function merge(value, source)
        for key in pairs(value) do assert(vim.tbl_contains({ "profile", "languages", "features" }, key), "Unknown configuration: " .. key) end
        for _, kind in ipairs({ "languages", "features" }) do
            for name, enabled in pairs(value[kind] or {}) do
                if type(name) == "number" then set(kind, enabled, true, source) else set(kind, name, enabled, source) end
            end
        end
    end
    merge(user, "user"); merge(override, "local")
    for _, name in ipairs(csv(env.NVIM_DISABLE_LANGS)) do
        set(name == "copilot" and "features" or "languages", name, false, "legacy-env")
    end
    for _, name in ipairs(csv(env.NVIM_ENABLE_LANGS)) do
        set(name == "copilot" and "features" or "languages", name, true, "legacy-env")
    end
    if env.NVIM_LANGUAGES ~= nil then
        for name in pairs(result.languages) do set("languages", name, false, "env") end
        for _, name in ipairs(csv(env.NVIM_LANGUAGES)) do set("languages", vim.trim(name), true, "env") end
    end
    for _, item in ipairs(csv(env.NVIM_FEATURES)) do
        local name, value = item:match("^([^=]+)=(.+)$")
        if name then
            assert(value == "true" or value == "false" or value == "1" or value == "0", "Invalid feature value: " .. item)
            set("features", vim.trim(name), value == "true" or value == "1", "env")
        else
            set("features", item:gsub("^-", ""), item:sub(1, 1) ~= "-", "env")
        end
    end
    result.offline = env.NVIM_OFFLINE == "1"
    if result.offline then
        for _, name in ipairs({ "ai", "copilot", "remote" }) do set("features", name, false, "offline") end
    end
    return result
end
function M.get()
    if not M.current then
        local path = (vim.env.NVIM_CONFIG_ROOT or vim.fn.stdpath("config")) .. "/lua/config/local.lua"
        local override = vim.uv.fs_stat(path) and dofile(path) or {}
        M.current = M.resolve(require("config.user"), override)
        if M.current.offline then
            vim.env.CARGO_NET_OFFLINE = "true"
            vim.env.GOPROXY = "off"
            vim.env.GOSUMDB = "off"
            vim.env.GOTOOLCHAIN = "local"
        end
    end
    return M.current
end
function M.enabled(name)
    local c = M.get()
    assert(c.features[name] ~= nil or c.languages[name] ~= nil, "Unknown capability: " .. name)
    return c.features[name] == true or c.languages[name] == true
end
function M.plan(config)
    local c = config or M.get()
    local p = { tools = {}, parsers = {}, system = { "git", "curl", "unzip" }, servers = {}, sources = {} }
    local function add(key, values, source)
        for _, value in ipairs(values or {}) do
            if not vim.tbl_contains(p[key], value) then table.insert(p[key], value) end
            p.sources[key .. "." .. value] = source
        end
    end
    if c.features.search or c.features.explorer then add("system", { "ripgrep", "fd", "trash" }, "search/explorer") end
    if c.features.treesitter then
        add("parsers", catalog.base_parsers, "base")
        add("system", { "cc", "tree-sitter" }, "treesitter")
    end
    for name, enabled in pairs(c.languages) do
        if enabled then
            local pack = catalog.languages[name]
            add("tools", pack.tools, name); add("system", pack.system, name); add("servers", pack.servers, name)
            if c.features.treesitter then add("parsers", pack.parsers, name) end
            if c.features.dap then add("tools", pack.debug, name .. "+dap") end
        end
    end
    if #p.tools > 0 then add("system", { "node", "python" }, "mason") end
    for _, feature in ipairs({ "fonts", "kitty", "formulas", "images", "copilot" }) do
        if c.features[feature] then add("system", { feature }, feature) end
    end
    for _, key in ipairs({ "tools", "parsers", "system", "servers" }) do table.sort(p[key]) end
    return p
end
return M
