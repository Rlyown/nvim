-- Standalone offline configuration for Neovim 0.12.4+.
-- Uses only the built-in runtime; optional tools are detected but never installed.
-- Use ,sk or :SingleHelp for keymaps; use ,xh or :SingleHealth for diagnostics.
local settings = {
    leader = ",",
    colorscheme = "habamax",
    autoformat = false,
    autopairs = true,
    max_files = 20000,
    max_file_bytes = 1024 * 1024,
    max_matches = 5000,
    max_search_output_bytes = 16 * 1024 * 1024,
    ignored_dirs = { ".git", "node_modules", "target", "build", "dist", ".venv", "venv", "__pycache__" },
}

if _G.SingleConfig and _G.SingleConfig.loaded then
    vim.notify("Single configuration is already loaded; restart Neovim after editing it")
    return
end
-- 1. Isolated startup and base settings. Do not load other configurations or packages.
vim.opt.loadplugins = false
vim.opt.runtimepath = { vim.env.VIMRUNTIME }
vim.opt.packpath = { vim.env.VIMRUNTIME }
vim.opt.exrc = false
if vim.fn.has("nvim-0.12.4") ~= 1 then
    vim.api.nvim_echo({ { "single-config.lua requires Neovim 0.12.4 or newer", "ErrorMsg" } }, true, {})
    return
end
local S = { loaded = true, actions = {}, terminals = {}, settings = settings }
_G.SingleConfig = S
local api, fn, uv = vim.api, vim.fn, vim.uv
-- Some distributions place bundled parsers in the installation prefix's lib/nvim.
local prefix = vim.fs.dirname(vim.fs.dirname(vim.fs.dirname(vim.env.VIMRUNTIME)))
for _, lib in ipairs({ "/lib/nvim", "/lib64/nvim" }) do
    local path = prefix .. lib
    if fn.isdirectory(path) == 1 then vim.opt.runtimepath:append(path) end
end
-- Built-in ftplugins start Tree-sitter directly; fall back to syntax highlighting when absent.
local treesitter_start = vim.treesitter.start
vim.treesitter.start = function(buf, language)
    if buf == nil or buf == 0 then buf = api.nvim_get_current_buf() end
    if vim.b[buf].single_large then return end
    local ok, err = pcall(treesitter_start, buf, language)
    if not ok then
        if tostring(err):find("Parser could not be created", 1, true) then
            vim.bo[buf].syntax = vim.bo[buf].filetype
        else error(err) end
    end
end
local group = api.nvim_create_augroup("SingleConfig", { clear = true })
local function notify(message, level)
    vim.notify(message, level or vim.log.levels.INFO, { title = "Single configuration" })
end
local function available(command)
    return fn.executable(command) == 1
end
local function action(lhs, callback, description, mode)
    vim.keymap.set(mode or "n", lhs, callback, { silent = true, desc = description })
    S.actions[#S.actions + 1] = { lhs = lhs, label = lhs .. "  " .. description, callback = callback, mode = mode or "n" }
end
local function command(name, callback, opts)
    api.nvim_create_user_command("Single" .. name, callback, opts or {})
end
vim.g.mapleader = settings.leader
vim.g.maplocalleader = " "
local options = {
    number = true, relativenumber = false, cursorline = true, signcolumn = "yes",
    expandtab = true, shiftwidth = 4, tabstop = 4, smartindent = true,
    ignorecase = true, smartcase = true, hlsearch = true, incsearch = true,
    splitbelow = true, splitright = true, scrolloff = 8, sidescrolloff = 8,
    mouse = "a", termguicolors = true, laststatus = 3, showtabline = 2,
    showmode = false, completeopt = { "menu", "menuone", "noselect" }, pumheight = 12,
    updatetime = 300, timeoutlen = 500, hidden = true, confirm = true,
    backup = false, writebackup = true, swapfile = true, undofile = true,
    autoread = true, autowrite = false, autowriteall = false, wrap = true,
    foldmethod = "indent", foldlevel = 99, foldlevelstart = 99,
    fileencodings = "ucs-bom,utf-8,gb18030,latin1",
}
for name, value in pairs(options) do vim.opt[name] = value end
vim.opt.shortmess:append("c")
vim.cmd("filetype plugin indent on")
vim.cmd("syntax enable")
pcall(vim.cmd.colorscheme, settings.colorscheme)
-- Explicitly load bundled components after noloadplugins; never load user plugins.
vim.cmd("runtime plugin/netrwPlugin.vim")
vim.cmd("runtime plugin/matchit.vim")
vim.g.netrw_banner = 0
vim.g.netrw_liststyle = 3
vim.g.netrw_winsize = 25
local state_dir = fn.stdpath("state") .. "/single-config"
local state_ok, state_error = pcall(function()
    fn.mkdir(state_dir .. "/undo", "p", 448)
    fn.mkdir(state_dir .. "/sessions", "p", 448)
    if fn.filewritable(state_dir .. "/undo") ~= 2 or fn.filewritable(state_dir .. "/sessions") ~= 2 then
        error("state directory is not writable")
    end
end)
if state_ok then
    vim.opt.undodir = state_dir .. "/undo//"
    vim.opt.shadafile = state_dir .. "/main.shada"
else
    vim.opt.undofile = false
    vim.opt.shadafile = "NONE"
    vim.schedule(function() notify("Persistent undo and sessions are unavailable: " .. tostring(state_error), vim.log.levels.WARN) end)
end
-- Use ordinary registers without a system clipboard; use ,xy for explicit OSC52 copy.
local system_clipboard = available("pbcopy") or available("win32yank.exe") or available("clip.exe")
    or (vim.env.WAYLAND_DISPLAY and available("wl-copy"))
    or (vim.env.DISPLAY and (available("xclip") or available("xsel")))
if system_clipboard then vim.opt.clipboard = "unnamedplus" end

local markers = {
    c = { "CMakeLists.txt", "compile_commands.json", "Makefile" },
    cpp = { "CMakeLists.txt", "compile_commands.json", "Makefile" },
    go = { "go.work", "go.mod" }, rust = { "Cargo.toml" },
    python = { "pyproject.toml", "setup.py", "requirements.txt" },
    lua = { ".luarc.json", ".luarc.jsonc" },
}
function S.root(buf)
    buf = buf or api.nvim_get_current_buf()
    local name = api.nvim_buf_get_name(buf)
    if name == "" or vim.bo[buf].buftype ~= "" then return uv.cwd() end
    local candidates = vim.deepcopy(markers[vim.bo[buf].filetype] or {})
    candidates[#candidates + 1] = ".git"
    return vim.fs.root(name, candidates) or uv.cwd()
end
function S.explorer()
    local current = api.nvim_buf_get_name(0)
    local directory = current ~= "" and fn.isdirectory(current) == 1 and current
        or (current ~= "" and fn.fnamemodify(current, ":p:h") or S.root())
    vim.cmd("Explore " .. fn.fnameescape(directory))
end
function S.close_buffer()
    if vim.bo.buftype ~= "" then
        vim.cmd("close")
        return
    end
    vim.cmd("confirm bdelete")
end
local function scratch(title, lines, filetype)
    vim.cmd("botright new")
    local buf = api.nvim_get_current_buf()
    vim.bo[buf].buftype = "nofile"
    vim.bo[buf].bufhidden = "wipe"
    vim.bo[buf].swapfile = false
    vim.bo[buf].filetype = filetype or "singleinfo"
    api.nvim_buf_set_lines(buf, 0, -1, false, lines)
    vim.bo[buf].modifiable = false
    pcall(api.nvim_buf_set_name, buf, "single://" .. title .. "/" .. buf)
    vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = buf, desc = "Close" })
    return buf
end
local function process(argv, cwd, callback, output_limit)
    if not available(argv[1]) then notify("Missing executable: " .. argv[1], vim.log.levels.WARN); return end
    local opts = { cwd = cwd, text = true }
    local chunks, bytes, truncated, job = {}, 0, false, nil
    if output_limit then
        -- Limit accumulated rg output instead of buffering an unbounded result.
        opts.stdout = function(err, data)
            if err or not data or truncated then return end
            local remaining = output_limit - bytes
            chunks[#chunks + 1] = data:sub(1, remaining)
            bytes = bytes + math.min(#data, remaining)
            if #data > remaining then
                truncated = true
                if job then pcall(job.kill, job, 15) end
            end
        end
    end
    local ok, result = pcall(vim.system, argv, opts, vim.schedule_wrap(function(output)
        if output_limit then output.stdout = table.concat(chunks); output.truncated = truncated end
        callback(output)
    end))
    if not ok then notify(tostring(result), vim.log.levels.ERROR); return end
    job = result
    return job
end
local function open_item(item, layout)
    if item.callback then item.callback(); return end
    if layout == "split" then vim.cmd("split") elseif layout == "vsplit" then vim.cmd("vsplit") end
    if item.bufnr and api.nvim_buf_is_valid(item.bufnr) then
        api.nvim_set_current_buf(item.bufnr)
    elseif item.filename then
        vim.cmd.edit(fn.fnameescape(item.filename))
    end
    if item.lnum then
        local line = math.min(item.lnum, api.nvim_buf_line_count(0))
        local length = #(api.nvim_buf_get_lines(0, line - 1, line, false)[1] or "")
        api.nvim_win_set_cursor(0, { line, math.min(math.max((item.col or 1) - 1, 0), length) })
        vim.cmd("normal! zvzz")
    end
end
local function quickfix(items, title)
    local entries = {}
    for _, item in ipairs(items) do
        if item.filename or item.bufnr then
            entries[#entries + 1] = {
                filename = item.filename, bufnr = item.bufnr, lnum = item.lnum or 1,
                col = item.col or 1, text = item.text or item.label or "",
            }
        end
    end
    fn.setqflist({}, " ", { title = title, items = entries })
    if #entries > 0 then vim.cmd("botright copen") else notify("No jumpable results") end
end

-- 2. A unified floating picker. Closing it cancels pending scan results.
function S.pick(title, items)
    if S.picker then S.picker.close() end
    local origin = api.nvim_get_current_win()
    local input = api.nvim_create_buf(false, true)
    local list = api.nvim_create_buf(false, true)
    local width = math.max(10, math.min(100, vim.o.columns - 4))
    local height = math.max(1, math.min(16, vim.o.lines - 8))
    local row = math.max(0, math.floor((vim.o.lines - height - 5) / 2))
    local col = math.max(0, math.floor((vim.o.columns - width) / 2))
    local input_win = api.nvim_open_win(input, true, {
        relative = "editor", row = row, col = col, width = width, height = 1,
        border = "rounded", title = " " .. title .. " ", style = "minimal",
    })
    local list_win = api.nvim_open_win(list, false, {
        relative = "editor", row = row + 3, col = col, width = width, height = height,
        border = "rounded", style = "minimal", focusable = false,
        footer = " Enter open · C-x/C-v split · C-q quickfix · Esc cancel ",
    })
    vim.bo[input].bufhidden = "wipe"
    vim.bo[list].bufhidden = "wipe"
    vim.bo[input].filetype = "singlepicker"
    vim.wo[list_win].cursorline = true
    local p = { items = items or {}, filtered = {}, index = 1, alive = true, input = input, list = list }
    S.picker = p
    function p.close()
        if not p.alive then return end
        p.alive = false
        if p.cancel then p.cancel() end
        if S.picker == p then S.picker = nil end
        pcall(vim.cmd, "stopinsert")
        for _, win in ipairs({ input_win, list_win }) do
            if api.nvim_win_is_valid(win) then api.nvim_win_close(win, true) end
        end
        if api.nvim_win_is_valid(origin) then api.nvim_set_current_win(origin) end
    end
    function p.refresh()
        if not p.alive or not api.nvim_buf_is_valid(input) then return end
        local query = api.nvim_buf_get_lines(input, 0, 1, false)[1] or ""
        local labels = {}
        for i, item in ipairs(p.items) do
            labels[i] = { label = item.label or item.filename or tostring(i), item = item }
        end
        local matched = query == "" and labels or fn.matchfuzzy(labels, query, { key = "label" })
        p.filtered = {}
        for _, match in ipairs(matched) do p.filtered[#p.filtered + 1] = match.item end
        p.index = math.max(1, math.min(p.index, #p.filtered))
        local start = math.max(1, p.index - height + 1)
        local lines = {}
        for i = start, math.min(#matched, start + height - 1) do
            lines[#lines + 1] = matched[i].label:gsub("[\r\n\t]", " ")
        end
        if #lines == 0 then lines = { "(no matches)" } end
        api.nvim_buf_set_lines(list, 0, -1, false, lines)
        api.nvim_win_set_cursor(list_win, { math.max(1, p.index - start + 1), 0 })
    end
    function p.update(new_items)
        if not p.alive then return end
        p.items = new_items
        p.refresh()
    end
    local function choose(layout)
        local selected = p.filtered[p.index]
        if not selected then return end
        p.close()
        vim.schedule(function() open_item(selected, layout) end)
    end
    local function move(delta)
        p.index = math.max(1, math.min(#p.filtered, p.index + delta))
        p.refresh()
    end
    for lhs, callback in pairs({
        ["<CR>"] = function() choose() end,
        ["<C-x>"] = function() choose("split") end,
        ["<C-v>"] = function() choose("vsplit") end,
        ["<Esc>"] = p.close, ["<C-c>"] = p.close,
        ["<Down>"] = function() move(1) end, ["<C-n>"] = function() move(1) end,
        ["<Up>"] = function() move(-1) end, ["<C-p>"] = function() move(-1) end,
        ["<C-q>"] = function()
            local selected = p.filtered
            p.close()
            vim.schedule(function() quickfix(selected, title) end)
        end,
    }) do vim.keymap.set({ "n", "i" }, lhs, callback, { buffer = input, silent = true }) end
    api.nvim_create_autocmd({ "TextChangedI", "TextChanged" }, { buffer = input, callback = p.refresh })
    api.nvim_create_autocmd("BufWipeout", { buffer = input, once = true, callback = function()
        vim.schedule(p.close)
    end })
    api.nvim_create_autocmd("WinLeave", { buffer = input, once = true, callback = function()
        vim.schedule(p.close)
    end })
    p.refresh()
    vim.cmd("startinsert")
    return p
end

-- 3. File and project search. Without rg, walk directories in scheduled batches.
local ignored = {}
for _, name in ipairs(settings.ignored_dirs) do ignored[name] = true end
function S.walk(root, visit, done)
    local task = { cancelled = false, count = 0, truncated = false }
    local pending, scanner = { root }, nil
    local function step()
        if task.cancelled then return end
        for _ = 1, 100 do
            if not scanner then
                local directory = table.remove(pending)
                if not directory then done(task); return end
                scanner = { handle = uv.fs_scandir(directory), directory = directory }
            end
            local name, kind
            if scanner.handle then name, kind = uv.fs_scandir_next(scanner.handle) end
            if not name then
                scanner = nil
            else
                local path = scanner.directory .. "/" .. name
                if kind == "directory" and not ignored[name] then pending[#pending + 1] = path end
                if kind == "file" then
                    task.count = task.count + 1
                    if visit(path) == false then done(task); return end
                    if task.count >= settings.max_files then task.truncated = true; done(task); return end
                end
            end
        end
        vim.schedule(step)
    end
    vim.schedule(step)
    return task
end
local function relative(path, root)
    return path:sub(1, #root + 1) == root .. "/" and path:sub(#root + 2) or path
end
local function rg_args()
    local args = { "rg", "--hidden" }
    for _, name in ipairs(settings.ignored_dirs) do
        vim.list_extend(args, { "--glob", "!" .. name .. "/**", "--glob", "!**/" .. name .. "/**" })
    end
    return args
end
function S.files()
    local root = S.root()
    local p = S.pick("Files · " .. root, {})
    local entries = {}
    if available("rg") then
        local args = rg_args()
        vim.list_extend(args, { "--files", "--null" })
        local job = process(args, root, function(result)
            if not p.alive then return end
            if result.code > 1 and not result.truncated then notify(result.stderr or "File scan failed", vim.log.levels.WARN); return end
            for path in (result.stdout or ""):gmatch("([^%z]+)%z") do
                entries[#entries + 1] = { label = path, filename = root .. "/" .. path }
                if #entries >= settings.max_files then notify("File list limit reached"); break end
            end
            p.update(entries)
            if result.truncated then notify("File scan output was truncated; narrow the directory"); end
        end, settings.max_search_output_bytes)
        p.cancel = function() if job then pcall(job.kill, job, 15) end end
    else
        local task = S.walk(root, function(path)
            entries[#entries + 1] = { label = relative(path, root), filename = path }
        end, function(result)
            if not p.alive then return end
            p.update(entries)
            if result.truncated then notify("File scan limit reached") end
        end)
        p.cancel = function() task.cancelled = true end
    end
end
local function read_text(path)
    local stat = uv.fs_stat(path)
    if not stat or stat.size > settings.max_file_bytes then return end
    local file = io.open(path, "rb")
    if not file then return end
    local text = file:read(settings.max_file_bytes + 1)
    file:close()
    if not text or #text > settings.max_file_bytes or text:find("\0", 1, true) then return end
    return text
end
function S.cancel_search()
    if S.search then
        S.search.cancelled = true
        if S.search.job then pcall(S.search.job.kill, S.search.job, 15) end
        if S.search.walk then S.search.walk.cancelled = true end
        S.search = nil
    end
end
function S.grep(query, root, callback)
    if not query or query == "" then return end
    root = root or S.root()
    S.cancel_search()
    local task = { cancelled = false }
    S.search = task
    S.last_search = { query = query, root = root }
    local entries = {}
    local function finish(truncated)
        if task.cancelled then return end
        S.search = nil
        if truncated then notify("Search results were truncated; narrow the query") end
        if callback then callback(entries) else quickfix(entries, "Search: " .. query) end
    end
    if available("rg") then
        local args = rg_args()
        vim.list_extend(args, { "--json", "--fixed-strings", "--smart-case", "--max-filesize",
            tostring(settings.max_file_bytes), "--", query, "." })
        task.job = process(args, root, function(result)
            if task.cancelled then return end
            if result.code > 1 and not result.truncated then
                S.search = nil
                notify(result.stderr or "Search failed", vim.log.levels.WARN)
                return
            end
            local truncated = result.truncated or false
            for line in (result.stdout or ""):gmatch("[^\n]+") do
                local ok, event = pcall(vim.json.decode, line)
                if ok and event.type == "match" and event.data.path.text and event.data.lines.text then
                    local data = event.data
                    local path = root .. "/" .. data.path.text
                    entries[#entries + 1] = { filename = path, lnum = data.line_number,
                        col = data.submatches[1].start + 1, text = data.lines.text:gsub("[\r\n]+$", "") }
                    if #entries >= settings.max_matches then truncated = true; break end
                end
            end
            finish(truncated)
        end, settings.max_search_output_bytes)
    else
        local case_sensitive = query:find("%u") ~= nil
        local needle = case_sensitive and query or query:lower()
        task.walk = S.walk(root, function(path)
            local text = read_text(path)
            if text then
                local number = 0
                for line in (text .. "\n"):gmatch("(.-)\n") do
                    number = number + 1
                    local haystack = case_sensitive and line or line:lower()
                    local col = haystack:find(needle, 1, true)
                    if col then
                        entries[#entries + 1] = { filename = path, lnum = number, col = col, text = line }
                        if #entries >= settings.max_matches then return false end
                    end
                end
            end
        end, function(result) finish(result.truncated or #entries >= settings.max_matches) end)
    end
    notify("Searching; use :SingleCancel to cancel")
    return task
end
local function prompt_grep()
    local root = S.root()
    vim.ui.input({ prompt = "Project text (literal): " }, function(query) S.grep(query, root) end)
end
local function buffers(recent)
    local entries, seen = {}, {}
    for _, buf in ipairs(api.nvim_list_bufs()) do
        if vim.bo[buf].buflisted then
            local name = api.nvim_buf_get_name(buf)
            entries[#entries + 1] = { label = (vim.bo[buf].modified and "+ " or "  ") .. (name ~= "" and name or "[No Name]"), bufnr = buf }
            seen[name] = true
        end
    end
    if recent then
        for _, name in ipairs(vim.v.oldfiles) do
            if not seen[name] and fn.filereadable(name) == 1 then
                entries[#entries + 1] = { label = name, filename = name }
            end
        end
    end
    S.pick(recent and "Buffers and Recent Files" or "Buffers", entries)
end
local function lines_picker()
    local entries, buf = {}, api.nvim_get_current_buf()
    for i, line in ipairs(api.nvim_buf_get_lines(buf, 0, -1, false)) do
        entries[#entries + 1] = { label = i .. "  " .. line, text = line, bufnr = buf, lnum = i }
    end
    S.pick("Current File Lines", entries)
end
local function diagnostics()
    local entries = {}
    for _, d in ipairs(vim.diagnostic.get()) do
        entries[#entries + 1] = { label = fn.fnamemodify(api.nvim_buf_get_name(d.bufnr), ":t") .. ":" .. (d.lnum + 1) .. " " .. d.message,
            bufnr = d.bufnr, lnum = d.lnum + 1, col = d.col + 1, text = d.message }
    end
    S.pick("Diagnostics", entries)
end
local function replace_project()
    local root = S.root()
    vim.ui.input({ prompt = "Project replace - find literal: " }, function(query)
        if not query or query == "" then return end
        vim.ui.input({ prompt = "Replace with (literal): " }, function(replacement)
            if replacement == nil then return end
            S.grep(query, root, function(entries)
                quickfix(entries, "Pending replacement: " .. query)
                if #entries == 0 then return end
                local pattern = "\\V" .. (query:find("%u") and "\\C" or "\\c") .. fn.escape(query, "\\/")
                -- :cdo asks for native confirmation on each matching line; buffers are not saved.
                local replacement_text = fn.escape(replacement, "\\/&~")
                vim.cmd("cdo substitute/" .. pattern .. "/" .. replacement_text .. "/gc")
            end)
        end)
    end)
end

-- 4. Editing experience and interface.
local function status_escape(text) return tostring(text):gsub("%%", "%%%%") end
function S.statusline()
    local buf = api.nvim_get_current_buf()
    local counts = vim.diagnostic.count(buf)
    local mode = api.nvim_get_mode().mode
    local labels = { n = "NORMAL", i = "INSERT", v = "VISUAL", V = "V-LINE", c = "COMMAND", t = "TERMINAL", R = "REPLACE" }
    return " " .. (labels[mode] or mode) .. "  %<%f %m%r %= "
        .. "E:" .. (counts[vim.diagnostic.severity.ERROR] or 0)
        .. " W:" .. (counts[vim.diagnostic.severity.WARN] or 0)
        .. "  " .. status_escape(vim.bo[buf].filetype) .. "  %l:%c  %p%% "
end
function S.tabline()
    local parts = {}
    for _, buf in ipairs(api.nvim_list_bufs()) do
        if vim.bo[buf].buflisted then
            local name = fn.fnamemodify(api.nvim_buf_get_name(buf), ":t")
            parts[#parts + 1] = (buf == api.nvim_get_current_buf() and "%#TabLineSel#" or "%#TabLine#")
                .. " " .. buf .. ":" .. status_escape(name ~= "" and name or "[No Name]") .. (vim.bo[buf].modified and "+ " or " ")
        end
    end
    return table.concat(parts) .. "%#TabLineFill#%="
end
vim.o.statusline = "%!v:lua.SingleConfig.statusline()"
vim.o.tabline = "%!v:lua.SingleConfig.tabline()"
api.nvim_create_autocmd("TextYankPost", { group = group, callback = function() vim.hl.on_yank({ timeout = 180 }) end })
api.nvim_create_autocmd("BufReadPost", { group = group, callback = function(event)
    local position = api.nvim_buf_get_mark(event.buf, '"')
    if position[1] > 1 and position[1] <= api.nvim_buf_line_count(event.buf) then
        pcall(api.nvim_win_set_cursor, 0, position)
    end
end })
api.nvim_create_autocmd("BufReadPre", { group = group, callback = function(event)
    local stat = uv.fs_stat(event.file)
    if stat and stat.size > settings.max_file_bytes then
        vim.b[event.buf].single_large = true
        vim.bo[event.buf].undofile = false
        vim.bo[event.buf].swapfile = false
        vim.bo[event.buf].synmaxcol = 200
    end
end })
api.nvim_create_autocmd("FileType", { group = group, callback = function(event)
    vim.opt_local.formatoptions:remove({ "c", "r", "o" })
    if vim.b[event.buf].single_large then
        vim.bo[event.buf].syntax = "OFF"
        vim.opt_local.foldmethod = "manual"
    end
    if vim.tbl_contains({ "qf", "help", "man" }, vim.bo[event.buf].filetype) then
        vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = event.buf })
    end
end })
api.nvim_create_autocmd({ "FocusGained", "TermClose" }, { group = group, callback = function() vim.cmd("checktime") end })
local pairs_map = { ["("] = ")", ["["] = "]", ["{"] = "}", ['"'] = '"', ["'"] = "'", ["`"] = "`" }
for opening, closing in pairs(pairs_map) do
    vim.keymap.set("i", opening, function()
        if not settings.autopairs or vim.bo.buftype ~= "" or vim.b.single_large or fn.pumvisible() == 1 then return opening end
        local line, col = api.nvim_get_current_line(), api.nvim_win_get_cursor(0)[2]
        local next_char, previous = line:sub(col + 1, col + 1), line:sub(col, col)
        if opening == closing and next_char == closing then return "<Right>" end
        if previous == "\\" or (opening == closing and previous:match("[%w_]")) then return opening end
        if next_char ~= "" and not next_char:match("[%s%)%]%},;]") then return opening end
        return opening .. closing .. "<Left>"
    end, { expr = true, desc = "Simple pair insertion" })
end
for _, closing in ipairs({ ")", "]", "}" }) do
    vim.keymap.set("i", closing, function()
        local col = api.nvim_win_get_cursor(0)[2]
        if settings.autopairs and vim.bo.buftype == "" and api.nvim_get_current_line():sub(col + 1, col + 1) == closing then return "<Right>" end
        return closing
    end, { expr = true })
end
vim.keymap.set("i", "<BS>", function()
    local col = api.nvim_win_get_cursor(0)[2]
    local line = api.nvim_get_current_line()
    if settings.autopairs and vim.bo.buftype == "" and col > 0 and pairs_map[line:sub(col, col)] == line:sub(col + 1, col + 1) then
        return "<BS><Del>"
    end
    return "<BS>"
end, { expr = true })
local snippets = {
    c = { { "main", "int main(int argc, char **argv) {\n\t${0}\n\treturn 0;\n}" } },
    cpp = { { "main", "#include <iostream>\n\nint main() {\n\t${0}\n\treturn 0;\n}" } },
    go = { { "error handling", "if err != nil {\n\treturn ${1:err}\n}\n$0" }, { "main", "package main\n\nfunc main() {\n\t$0\n}" } },
    rust = { { "main", "fn main() {\n\t$0\n}" }, { "test", "#[test]\nfn ${1:test_name}() {\n\t$0\n}" } },
    python = { { "main", 'if __name__ == "__main__":\n\t$0' }, { "function", "def ${1:name}(${2:args}):\n\t$0" } },
    lua = { { "function", "local function ${1:name}(${2:args})\n\t$0\nend" } },
    sh = { { "script", "#!/usr/bin/env bash\nset -euo pipefail\n\n$0" } },
}
local function snippet_picker()
    local entries = {}
    for _, entry in ipairs(snippets[vim.bo.filetype] or {}) do
        entries[#entries + 1] = { label = entry[1], callback = function() vim.snippet.expand(entry[2]) end }
    end
    if #entries == 0 then notify("No built-in snippets for this filetype"); return end
    S.pick("Snippets", entries)
end
vim.keymap.set({ "i", "s" }, "<Tab>", function()
    if vim.snippet.active({ direction = 1 }) then return "<Cmd>lua vim.snippet.jump(1)<CR>" end
    return fn.pumvisible() == 1 and "<C-n>" or "<Tab>"
end, { expr = true })
vim.keymap.set({ "i", "s" }, "<S-Tab>", function()
    if vim.snippet.active({ direction = -1 }) then return "<Cmd>lua vim.snippet.jump(-1)<CR>" end
    return fn.pumvisible() == 1 and "<C-p>" or "<S-Tab>"
end, { expr = true })

-- 5. Native LSP. Server commands are explicit and require no lspconfig.
-- LSP initialization needs a log directory; preserve editing when unavailable.
local lsp_ok, lsp = false, nil
if state_ok then lsp_ok, lsp = pcall(require, "vim.lsp") end
if not lsp_ok then lsp = { buf = {}, get_clients = function() return {} end } end
local servers = {
    clangd = { cmd = { "clangd" }, filetypes = { "c", "cpp", "objc", "objcpp", "cuda" } },
    gopls = { cmd = { "gopls" }, filetypes = { "go", "gomod", "gowork", "gotmpl" },
        cmd_env = { GOPROXY = "off", GOSUMDB = "off", GOTOOLCHAIN = "local", GOTELEMETRY = "off" } },
    rust_analyzer = { cmd = { "rust-analyzer" }, filetypes = { "rust" }, cmd_env = { CARGO_NET_OFFLINE = "true" } },
    pyright = { cmd = { "pyright-langserver", "--stdio" }, filetypes = { "python" } },
    lua_ls = { cmd = { "lua-language-server" }, filetypes = { "lua" }, settings = {
        Lua = { diagnostics = { globals = { "vim" } }, workspace = { checkThirdParty = false }, telemetry = { enable = false } },
    } },
    bashls = { cmd = { "bash-language-server", "start" }, filetypes = { "sh", "bash" } },
}
S.servers = servers
for name, spec in pairs(servers) do
    if lsp_ok and available(spec.cmd[1]) then
        local config = vim.deepcopy(spec)
        -- Portable environments may have low file descriptor limits; disable recursive watchers.
        config.capabilities = {
            workspace = { didChangeWatchedFiles = { dynamicRegistration = false } },
        }
        config.root_dir = function(buf, on_dir)
            if not vim.b[buf].single_large then on_dir(S.root(buf)) end
        end
        lsp.config("single_" .. name, config)
        lsp.enable("single_" .. name)
    end
end
vim.diagnostic.config({ virtual_text = false, signs = true, underline = true, severity_sort = true, float = { border = "rounded" } })
local function lsp_supported(method, buf)
    return lsp.get_clients({ bufnr = buf or 0, method = method })
end
local function lsp_call(method, callback)
    return function()
        if #lsp_supported(method) == 0 then notify("No language server supports this action"); return end
        callback()
    end
end
function S.format(buf)
    buf = buf or api.nvim_get_current_buf()
    local clients = lsp_supported("textDocument/formatting", buf)
    if #clients == 0 then notify("No language server provides formatting"); return end
    table.sort(clients, function(a, b) return a.id < b.id end)
    local ok, err = pcall(lsp.buf.format, { bufnr = buf, id = clients[1].id, timeout_ms = 3000 })
    if not ok then notify(tostring(err), vim.log.levels.WARN) end
end
api.nvim_create_autocmd("LspAttach", { group = group, callback = function(event)
    local client = lsp.get_client_by_id(event.data.client_id)
    if not client then return end
    if client:supports_method("textDocument/completion", event.buf) then
        lsp.completion.enable(true, client.id, event.buf, { autotrigger = true })
    end
    if client:supports_method("textDocument/foldingRange", event.buf) then
        for _, win in ipairs(fn.win_findbuf(event.buf)) do
            vim.wo[win].foldmethod = "expr"
            vim.wo[win].foldexpr = "v:lua.vim.lsp.foldexpr()"
        end
    end
end })
api.nvim_create_autocmd("LspDetach", { group = group, callback = function(event)
    vim.schedule(function()
        if not api.nvim_buf_is_valid(event.buf) then return end
        if #lsp_supported("textDocument/foldingRange", event.buf) == 0 then
            for _, win in ipairs(fn.win_findbuf(event.buf)) do vim.wo[win].foldmethod = "indent" end
        end
    end)
end })
api.nvim_create_autocmd("BufWritePre", { group = group, callback = function(event)
    if settings.autoformat and not vim.b[event.buf].single_large and #lsp_supported("textDocument/formatting", event.buf) > 0 then S.format(event.buf) end
end })
local function symbols(workspace)
    local opts = { on_list = function(result)
        local entries = {}
        for _, item in ipairs(result.items) do
            item.label = item.text
            entries[#entries + 1] = item
        end
        S.pick("Symbols", entries)
    end }
    if workspace then
        vim.ui.input({ prompt = "Workspace symbol: " }, function(query)
            if query then lsp.buf.workspace_symbol(query, opts) end
        end)
    else lsp.buf.document_symbol(opts) end
end

-- 6. Terminals. IDs identify processes; changing layout reuses the shell.
function S.terminal(id, layout, toggle, cwd)
    id, layout = id or 1, layout or "horizontal"
    local term = S.terminals[id]
    if term and term.win and api.nvim_win_is_valid(term.win) and api.nvim_win_get_buf(term.win) == term.buf then
        if toggle and term.layout == layout then
            if #api.nvim_list_wins() > 1 then api.nvim_win_close(term.win, false) else vim.cmd("enew") end
            term.win = nil
            return term
        end
        if term.layout == layout and term.job and fn.jobwait({ term.job }, 0)[1] == -1 then
            api.nvim_set_current_win(term.win)
            return term
        end
        if #api.nvim_list_wins() > 1 then api.nvim_win_close(term.win, false) else vim.cmd("enew") end
        term.win = nil
    end
    cwd = cwd or S.root()
    local origin = api.nvim_get_current_win()
    if not term or not api.nvim_buf_is_valid(term.buf) or not term.job or fn.jobwait({ term.job }, 0)[1] ~= -1 then
        term = { buf = api.nvim_create_buf(true, false), cwd = cwd }
        S.terminals[id] = term
        vim.bo[term.buf].bufhidden = "hide"
    end
    if layout == "float" then
        local width = math.max(10, math.floor(vim.o.columns * 0.85))
        local height = math.max(1, math.floor((vim.o.lines - 4) * 0.75))
        term.win = api.nvim_open_win(term.buf, true, { relative = "editor", width = width, height = height,
            row = 1, col = math.max(0, math.floor((vim.o.columns - width) / 2)), border = "rounded", title = " Terminal " .. id, style = "minimal" })
    else
        if layout == "vertical" then vim.cmd("botright vsplit")
        elseif layout == "tab" then vim.cmd("tabnew")
        else vim.cmd("botright 12split") end
        term.win = api.nvim_get_current_win()
        api.nvim_win_set_buf(term.win, term.buf)
    end
    term.origin = origin
    term.layout = layout
    if not term.job then
        local ok, job = pcall(fn.jobstart, { vim.o.shell }, { term = true, cwd = term.cwd })
        if not ok or job <= 0 then notify("Terminal failed to start: " .. tostring(job), vim.log.levels.ERROR); return term end
        term.job = job
    end
    vim.wo[term.win].number = false
    vim.wo[term.win].relativenumber = false
    vim.cmd("startinsert")
    return term
end
function S.send(id, text, cwd)
    local term = S.terminal(id, "horizontal", false, cwd)
    if term and term.job then fn.chansend(term.job, text .. "\n") end
end
local function send_lines(selection)
    local root, text = S.root(), api.nvim_get_current_line()
    if selection then
        local start, finish = fn.getpos("v"), fn.getpos(".")
        text = table.concat(fn.getregion(start, finish, { type = fn.mode() }), "\n")
    end
    local id = vim.v.count1
    vim.ui.input({ prompt = "Send to terminal ID: ", default = tostring(id) }, function(value)
        local number = tonumber(value)
        if number and number >= 1 and number % 1 == 0 then S.send(number, text, root) end
    end)
end
function S.run(kind)
    local buf, root = api.nvim_get_current_buf(), S.root()
    local ft, path = vim.bo[buf].filetype, api.nvim_buf_get_name(buf)
    if path == "" or vim.bo[buf].buftype ~= "" then notify("Save a source file first"); return end
    if vim.bo[buf].modified then
        local ok = pcall(vim.cmd, "write")
        if not ok then return end
    end
    local commands = {
        python = { run = { "python3", path }, test = { "python3", "-m", "unittest" } },
        go = { run = { "go", "run", "." }, build = { "go", "build", "./..." }, test = { "go", "test", "./..." } },
        rust = { run = { "cargo", "run", "--offline" }, build = { "cargo", "build", "--offline" }, test = { "cargo", "test", "--offline" } },
        c = { build = { "cmake", "--build", "build" }, test = { "ctest", "--test-dir", "build" } },
        sh = { run = { "bash", path } },
    }
    commands.cpp, commands.bash = commands.c, commands.sh
    local function launch(argv)
        if not available(argv[1]) then notify("Missing or unavailable executable: " .. argv[1], vim.log.levels.WARN); return end
        -- Start each task in an independent terminal to keep its working directory stable.
        vim.cmd("botright 12new")
        local ok, job = pcall(fn.jobstart, argv, { term = true, cwd = root,
            env = { GOPROXY = "off", GOSUMDB = "off", GOTOOLCHAIN = "local" } })
        if not ok or job <= 0 then notify("Task failed to start: " .. tostring(job), vim.log.levels.ERROR); return end
        vim.cmd("startinsert")
    end
    if (ft == "c" or ft == "cpp") and kind == "run" then
        vim.ui.input({ prompt = "Executable path: ", completion = "file" }, function(value)
            if value and value ~= "" then launch({ vim.fs.abspath(value) }) end
        end)
        return
    end
    local argv = commands[ft] and commands[ft][kind]
    if not argv then notify("No task for this filetype; use :make or the built-in terminal"); return end
    launch(argv)
end

-- 7. Read-only Git inspection. Arguments are passed independently; no implicit writes.
function S.git(kind)
    local root, path = S.root(), api.nvim_buf_get_name(0)
    local line = api.nvim_win_get_cursor(0)[1]
    if not available("git") then notify("git is not installed", vim.log.levels.WARN); return end
    process({ "git", "rev-parse", "--show-toplevel" }, root, function(result)
        if result.code ~= 0 then notify("The current directory is not a Git repository"); return end
        local git_root = (result.stdout or ""):gsub("[\r\n]+$", "")
        local file = relative(path, git_root)
        local args = {
            status = { "git", "status", "--short", "--untracked-files=normal" },
            log = { "git", "--no-pager", "log", "-50", "--oneline", "--decorate" },
            branches = { "git", "branch", "--all", "--no-color" },
            blame = { "git", "--no-pager", "blame", "-L", line .. "," .. line, "--", file },
        }
        if kind == "diff" then
            if path == "" or file == path then notify("The current file is outside the Git repository"); return end
            local source = fn.bufnr(path)
            process({ "git", "show", "HEAD:" .. file }, git_root, function(diff_result)
                if diff_result.code ~= 0 then notify("The file does not exist in HEAD (it may be uncommitted)"); return end
                if source < 0 or not api.nvim_buf_is_valid(source) then return end
                vim.cmd("tabnew")
                api.nvim_set_current_buf(source)
                vim.cmd("diffthis")
                vim.cmd("leftabove vnew")
                local baseline = api.nvim_get_current_buf()
                vim.bo[baseline].buftype = "nofile"
                vim.bo[baseline].bufhidden = "wipe"
                vim.bo[baseline].swapfile = false
                local text = diff_result.stdout or ""
                api.nvim_buf_set_lines(baseline, 0, -1, false, vim.split(text:gsub("\n$", ""), "\n", { plain = true }))
                vim.bo[baseline].filetype = vim.bo[source].filetype
                vim.bo[baseline].modifiable = false
                api.nvim_buf_set_name(baseline, "single://HEAD/" .. baseline .. "/" .. file)
                vim.cmd("diffthis")
                vim.keymap.set("n", "q", "<cmd>tabclose<cr>", { buffer = baseline, desc = "Close diff tab" })
            end)
        elseif args[kind] then
            process(args[kind], git_root, function(output)
                if output.code ~= 0 then notify(output.stderr or "Git command failed", vim.log.levels.WARN); return end
                scratch("git-" .. kind, vim.split(output.stdout or "", "\n", { plain = true }), kind == "blame" and "git" or "singleinfo")
            end)
        end
    end)
end

-- 8. Project sessions. Save file windows only; do not save terminals or auto-restore.
function S.session_path(root)
    return state_dir .. "/sessions/" .. fn.sha256(root or S.root()) .. ".vim"
end
function S.session(kind)
    if not state_ok then notify("State directory is not writable; sessions are unavailable"); return end
    local path = S.session_path()
    if kind == "save" then
        local old = vim.o.sessionoptions
        vim.o.sessionoptions = "buffers,curdir,folds,help,tabpages,winsize"
        local ok, err = pcall(vim.cmd, "mksession! " .. fn.fnameescape(path))
        vim.o.sessionoptions = old
        if not ok then notify(tostring(err), vim.log.levels.ERROR) else notify("Project session saved") end
    elseif kind == "load" then
        if fn.filereadable(path) == 0 then notify("No saved session for this project"); return end
        local ok, err = pcall(vim.cmd, "source " .. fn.fnameescape(path))
        if not ok then notify(tostring(err), vim.log.levels.WARN) end
    elseif kind == "delete" then
        if fn.filereadable(path) == 0 then notify("No session for this project"); return end
        vim.ui.select({ "Cancel", "Delete" }, { prompt = "Delete the saved project session?" }, function(value)
            if value == "Delete" then
                if fn.delete(path) == 0 then notify("Session deleted") else notify("Session deletion failed", vim.log.levels.WARN) end
            end
        end)
    end
end
local function health()
    local lines = {
        "Single configuration - Health", "", "Neovim: " .. tostring(vim.version()),
        "Project root: " .. S.root(), "Runtime: " .. vim.env.VIMRUNTIME,
        "State directory: " .. state_dir .. (state_ok and " (writable)" or " (not writable)"),
        "Clipboard: " .. (system_clipboard and "system provider" or "ordinary register; ,xy uses OSC52"),
        "LSP: " .. (lsp_ok and "detected" or "unavailable because state initialization failed"),
        "Format on save: " .. tostring(settings.autoformat), "", "Optional tools (missing tools do not block startup):",
    }
    for _, tool in ipairs({ "rg", "git", "clangd", "gopls", "rust-analyzer", "pyright-langserver", "lua-language-server",
        "bash-language-server", "cmake", "ctest", "go", "cargo", "python3", "bash" }) do
        lines[#lines + 1] = (available(tool) and "[available] " or "[missing] ") .. tool
    end
    vim.list_extend(lines, { "", "Without rg: Lua search; without LSP: word/path completion and indent folding.",
        "Pyright does not format; use a local formatter in the terminal.",
        "No DAP UI, AI, image, database, or extra Tree-sitter parsers are included.",
        "Native completion: C-n/C-p words, C-x C-f paths, C-x C-o omnifunc.",
        "Search uses literals and smart case; file limit " .. settings.max_files .. ", match limit " .. settings.max_matches .. ".",
        "Lua fallback ignores .gitignore; rg follows it; both skip common build directories.",
    })
    scratch("health", lines)
end
local function help()
    local entries = vim.deepcopy(S.actions)
    table.sort(entries, function(a, b) return a.label < b.label end)
    -- Help only displays keymaps; it never executes actions after context is lost.
    local lines = { "Single configuration - Keymaps (<leader> = " .. settings.leader .. ")", "" }
    for _, entry in ipairs(entries) do lines[#lines + 1] = entry.label end
    vim.list_extend(lines, { "", "Native: gcc/gc comment; za/zR/zM folds; % matching; :make build.",
        "Picker: type to filter, C-n/C-p move, Enter open, C-x/C-v split, C-q quickfix, Esc cancel.",
        "Completion: C-n/C-p words; C-x C-f paths; C-x C-o omnifunc; Tab jumps snippets.",
        "Search: :SingleGrep text; :SingleCancel cancels background work.", "q closes this page." })
    scratch("help", lines)
end

-- 9. Register unified actions and preserve the main plugin configuration keymaps.
action("<leader>w", "<cmd>write<cr>", "Save file")
action("<leader>e", "<cmd>edit<cr>", "Reload file")
action("<leader>q", "<cmd>x<cr>", "Save and close window")
action("<leader>Q", "<cmd>xa<cr>", "Save and quit")
action("<leader>c", S.close_buffer, "Close buffer")
action("<leader>h", "<cmd>nohlsearch<cr>", "Clear search highlight")
for lhs, rhs in pairs({ H = "bprevious", L = "bnext", ["[b"] = "bprevious", ["]b"] = "bnext" }) do action(lhs, "<cmd>" .. rhs .. "<cr>", "Switch buffer") end
for lhs, direction in pairs({ ["<C-h>"] = "h", ["<C-j>"] = "j", ["<C-k>"] = "k", ["<C-l>"] = "l" }) do action(lhs, "<C-w>" .. direction, "Focus window") end
for lhs, rhs in pairs({ ["<M-Up>"] = "resize -2", ["<M-Down>"] = "resize +2", ["<M-Left>"] = "vertical resize -2", ["<M-Right>"] = "vertical resize +2" }) do action(lhs, "<cmd>" .. rhs .. "<cr>", "Resize window") end
action("jk", "<Esc>", "Exit insert mode", "i")
action("J", ":move '>+1<cr>gv=gv", "Move selection down", "x")
action("K", ":move '<-2<cr>gv=gv", "Move selection up", "x")
action("p", '"_dP', "Paste without replacing register", "x")
action("<", "<gv", "Decrease indent and keep selection", "x")
action(">", ">gv", "Increase indent and keep selection", "x")
action("<leader>n", S.explorer, "Open directory explorer")
action("<leader>f", S.files, "Find project files")
action("<leader>F", prompt_grep, "Search project text")
action("<leader>sg", prompt_grep, "Search project text")
action("<leader>sw", function() S.grep(fn.expand("<cword>")) end, "Search word under cursor")
action("<leader>sb", lines_picker, "Search current file lines")
action("<leader>b", function() buffers(false) end, "Switch buffer")
action("<leader>so", function() buffers(true) end, "Buffers and recent files")
action("<leader>sd", diagnostics, "Diagnostics")
action("<leader>sr", replace_project, "Confirm project replacement")
action("<leader>sR", function()
    if S.last_search then S.grep(S.last_search.query, S.last_search.root) else notify("There is no previous search") end
end, "Repeat previous search")
action("<leader>sh", function()
    local entries = {}
    for _, tag in ipairs(fn.getcompletion("", "help")) do
        entries[#entries + 1] = { label = tag, callback = function() vim.cmd.help(fn.escape(tag, " |")) end }
    end
    S.pick("Neovim Help", entries)
end, "Search help tags")
action("<leader>sk", function()
    local entries = {}
    for _, entry in ipairs(S.actions) do
        entries[#entries + 1] = { label = entry.label, callback = function() notify(entry.label) end }
    end
    S.pick("Keymaps · <leader> = " .. settings.leader, entries)
end, "Search keymaps")
action("<leader>su", function() scratch("undo", vim.split(fn.execute("undolist"), "\n")); notify("Use :earlier / :later / :undo {number} to browse undo history") end, "Show undo history")
action("<leader>sc", function() scratch("history", vim.split(fn.execute("history cmd"), "\n")) end, "Show command history")
action("<leader>sn", function() scratch("messages", vim.split(fn.execute("messages"), "\n")) end, "Show message history")
action("<leader>xi", health, "Show configuration health")
action("<leader>xh", health, "Check optional tools")
action("<leader>xy", function() require("vim.ui.clipboard.osc52").copy("+")(fn.getreg('"', 1, true), fn.getregtype('"')) end, "Copy last register with OSC52")
action("<leader>uw", function() vim.wo.wrap = not vim.wo.wrap end, "Toggle wrap")
action("<leader>un", function() vim.wo.relativenumber = not vim.wo.relativenumber end, "Toggle relative numbers")
action("<leader>up", function() settings.autopairs = not settings.autopairs; notify("Auto pairs: " .. tostring(settings.autopairs)) end, "Toggle simple auto pairs")
action("<leader>li", snippet_picker, "Insert code snippet")
action("<leader>lz", function()
    local start, finish = fn.getpos("v"), fn.getpos(".")
    local mode = fn.mode()
    if mode ~= "v" then notify("Surround requires a characterwise visual selection"); return end
    local buf = api.nvim_get_current_buf()
    if start[2] > finish[2] or (start[2] == finish[2] and start[3] > finish[3]) then start, finish = finish, start end
    local tick = api.nvim_buf_get_changedtick(buf)
    local end_line = api.nvim_buf_get_lines(buf, finish[2] - 1, finish[2], false)[1]
    local char = fn.strcharpart(end_line:sub(finish[3]), 0, 1)
    local end_col = math.min(#end_line, finish[3] - 1 + #char)
    local text = api.nvim_buf_get_text(buf, start[2] - 1, start[3] - 1, finish[2] - 1, end_col, {})
    vim.ui.input({ prompt = "Surround character (for example ( [ { or a quote): " }, function(value)
        if not value or not pairs_map[value] then return end
        if not api.nvim_buf_is_valid(buf) or api.nvim_buf_get_changedtick(buf) ~= tick then return end
        text[1], text[#text] = value .. text[1], text[#text] .. pairs_map[value]
        if #text == 1 then text[1] = value .. api.nvim_buf_get_text(buf, start[2] - 1, start[3] - 1, finish[2] - 1, end_col, {})[1] .. pairs_map[value] end
        api.nvim_buf_set_text(buf, start[2] - 1, start[3] - 1, finish[2] - 1, end_col, text)
    end)
end, "Surround characterwise selection", "x")
for _, spec in ipairs({
    { "gd", "textDocument/definition", lsp.buf.definition, "Go to definition" },
    { "<leader>ld", "textDocument/definition", lsp.buf.definition, "Go to definition" },
    { "<leader>lR", "textDocument/references", lsp.buf.references, "Find references" },
    { "<leader>lh", "textDocument/hover", lsp.buf.hover, "Hover documentation" },
    { "<leader>ln", "textDocument/rename", lsp.buf.rename, "Rename symbol" },
    { "<leader>lc", "textDocument/codeAction", lsp.buf.code_action, "Code action" },
    { "<leader>ss", "textDocument/documentSymbol", function() symbols(false) end, "Document symbols" },
    { "<leader>sS", "workspace/symbol", function() symbols(true) end, "Workspace symbols" },
    { "<leader>o", "textDocument/documentSymbol", function() symbols(false) end, "Document outline" },
    { "<leader>lo", "textDocument/documentSymbol", function() symbols(false) end, "Document outline" },
}) do action(spec[1], lsp_call(spec[2], spec[3]), spec[4]) end
action("<leader>lf", function() S.format() end, "Format current file")
action("<leader>lF", function() settings.autoformat = not settings.autoformat; notify("Format on save: " .. tostring(settings.autoformat)) end, "Toggle format on save")
action("[d", function() vim.diagnostic.jump({ count = -1, float = true }) end, "Previous diagnostic")
action("]d", function() vim.diagnostic.jump({ count = 1, float = true }) end, "Next diagnostic")
action("gl", vim.diagnostic.open_float, "Diagnostic details")
action("[q", "<cmd>cprevious<cr>", "Previous quickfix item")
action("]q", "<cmd>cnext<cr>", "Next quickfix item")
for suffix, layout in pairs({ h = "horizontal", v = "vertical", f = "float", t = "tab" }) do
    action("<leader>t" .. suffix, function() S.terminal(vim.v.count1, layout, true) end, "Toggle terminal: " .. layout)
end
action("<C-\\>", function()
    local id = vim.v.count1
    if vim.bo.buftype == "terminal" then
        for number, term in pairs(S.terminals) do if term.buf == api.nvim_get_current_buf() then id = number; break end end
    end
    S.terminal(id, S.terminals[id] and S.terminals[id].layout or "horizontal", true)
end, "Toggle terminal", { "n", "t" })
vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal input mode" })
action("<leader>ta", function()
    local visible = false
    for _, term in pairs(S.terminals) do
        if term.win and api.nvim_win_is_valid(term.win) and api.nvim_win_get_buf(term.win) == term.buf then visible = true end
    end
    for id, term in pairs(S.terminals) do
        if visible then
            if term.win and api.nvim_win_is_valid(term.win) and api.nvim_win_get_buf(term.win) == term.buf then S.terminal(id, term.layout, true) end
        else S.terminal(id, "horizontal", false) end
    end
end, "Toggle all terminals")
action("<leader>tc", function() send_lines(false) end, "Send current line to terminal")
action("<leader>tl", function() send_lines(true) end, "Send selection to terminal", "x")
action("<leader>ts", function() send_lines(true) end, "Send selection to terminal", "x")
for suffix, kind in pairs({ r = "run", b = "build", t = "test" }) do action("<leader>l" .. suffix, function() S.run(kind) end, "Language task: " .. kind) end
for suffix, kind in pairs({ g = "status", l = "log", B = "branches", b = "blame", d = "diff" }) do action("<leader>g" .. suffix, function() S.git(kind) end, "Git view: " .. kind) end
action("<leader>gn", "]c", "Next diff hunk")
action("<leader>gN", "[c", "Previous diff hunk")
for suffix, kind in pairs({ s = "save", l = "load", c = "load", d = "delete" }) do action("<leader>p" .. suffix, function() S.session(kind) end, "Project session: " .. kind) end
command("Files", S.files)
command("Explorer", S.explorer)
command("Close", S.close_buffer)
command("Grep", function(args) if args.args == "" then prompt_grep() else S.grep(args.args) end end, { nargs = "*" })
command("Cancel", function() S.cancel_search(); if S.picker then S.picker.close() end end)
command("Help", help)
command("Health", health)
command("Run", function() S.run("run") end)
command("Build", function() S.run("build") end)
command("Test", function() S.run("test") end)
command("SessionSave", function() S.session("save") end)
command("SessionLoad", function() S.session("load") end)
command("SessionDelete", function() S.session("delete") end)
