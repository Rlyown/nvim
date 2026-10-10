local M = {}

local previews = {}
local previous_mousefocus
local group = vim.api.nvim_create_augroup("ConfigTexPreview", { clear = true })

local function notify(message, level)
    vim.notify(message, level or vim.log.levels.INFO, { title = "LaTeX preview" })
end

local function vimtex_state(buf)
    local ok, state = pcall(function() return vim.b[buf].vimtex end)
    if not ok or type(state) ~= "table" or not state.compiler then return nil end
    return state
end

local function compiler_file(buf, extension)
    local ok, path = pcall(vim.api.nvim_buf_call, buf, function()
        return vim.fn.eval("b:vimtex.compiler.get_file(" .. vim.fn.string(extension) .. ")")
    end)
    if not ok or type(path) ~= "string" or path == "" then return nil end
    return vim.fn.fnamemodify(path, ":p")
end

local function output_pdf(buf)
    return compiler_file(buf, "pdf")
end

local function find_synctex_file(pdf, source_dir, compiler_file)
    if compiler_file and compiler_file ~= "" and vim.uv.fs_stat(compiler_file) then
        return compiler_file
    end

    local stem = vim.fn.fnamemodify(pdf, ":t:r")
    local dirs = { vim.fn.fnamemodify(pdf, ":h"), source_dir }
    local seen = {}
    for _, dir in ipairs(dirs) do
        if dir and dir ~= "" and not seen[dir] then
            seen[dir] = true
            for _, suffix in ipairs({ ".synctex.gz", ".synctex" }) do
                local path = vim.fs.joinpath(dir, stem .. suffix)
                if vim.uv.fs_stat(path) then return path end
            end
        end
    end
end

local function run_synctex(args, cwd, pdf, source_dir, compiler_file)
    if vim.fn.executable("synctex") ~= 1 then
        notify("SyncTeX is not on PATH; install/configure a TeX distribution with SyncTeX.", vim.log.levels.ERROR)
        return nil
    end
    local synctex_file = pdf and find_synctex_file(pdf, source_dir or cwd, compiler_file)
    if pdf and not synctex_file then
        notify(
            "No SyncTeX data found for " .. vim.fn.fnamemodify(pdf, ":t")
                .. ". Compile this document with VimTeX (,lb), or ensure your build keeps the matching .synctex.gz file.",
            vim.log.levels.WARN
        )
        return nil
    end

    local command = vim.list_extend({}, args)
    local synctex_dir = synctex_file and vim.fn.fnamemodify(synctex_file, ":h")
    if synctex_dir and synctex_dir ~= vim.fn.fnamemodify(pdf, ":h") then
        -- SyncTeX parses -d after the required -o argument on both subcommands.
        table.insert(command, "-d")
        table.insert(command, synctex_dir)
    end
    local result = vim.system(command, { cwd = cwd, text = true }):wait()
    if result.code ~= 0 then
        local detail = vim.trim((result.stderr or "") .. "\n" .. (result.stdout or ""))
        if detail:find("No SyncTeX available", 1, true) then
            notify(
                "SyncTeX could not match " .. vim.fn.fnamemodify(pdf or "PDF", ":t")
                    .. ". Check that its .synctex.gz belongs to the current PDF and that the build has finished.",
                vim.log.levels.WARN
            )
        else
            notify("SyncTeX failed" .. (detail ~= "" and (": " .. detail) or "."), vim.log.levels.WARN)
        end
        return nil
    end
    return vim.split(result.stdout or "", "\n", { trimempty = true })
end

local function project_key(pdf)
    return vim.fn.sha256(vim.fs.normalize(pdf))
end

local function stats_revision(pdf)
    local stat = vim.uv.fs_stat(pdf)
    if not stat then return "missing" end
    local mtime = stat.mtime or {}
    return table.concat({ stat.size or 0, mtime.sec or 0, mtime.nsec or 0 }, "-")
end

local function statusline(state)
    return string.format(" PDF  %d  |  n/p or wheel: page  |  click: SyncTeX  |  r: refresh  |  q: close ", state.page)
end

local function win_is_showing(win, buf)
    return win and vim.api.nvim_win_is_valid(win) and vim.api.nvim_win_get_buf(win) == buf
end

local function update_mousefocus()
    local has_preview = false
    for _, state in pairs(previews) do
        if win_is_showing(state.win, state.buf) then
            has_preview = true
            break
        end
    end

    if has_preview then
        if previous_mousefocus == nil then previous_mousefocus = vim.o.mousefocus end
        vim.o.mousefocus = true
    elseif previous_mousefocus ~= nil then
        if vim.o.mousefocus then vim.o.mousefocus = previous_mousefocus end
        previous_mousefocus = nil
    end
end

local function ensure_window(state, source_win)
    if win_is_showing(state.win, state.buf) then return state.win end
    if source_win and vim.api.nvim_win_is_valid(source_win) then
        vim.api.nvim_set_current_win(source_win)
    end
    vim.cmd("botright vsplit")
    local win = vim.api.nvim_get_current_win()
    vim.api.nvim_win_set_buf(win, state.buf)
    vim.cmd("vertical resize " .. math.max(30, math.floor(vim.o.columns * 0.46)))
    state.win = win
    vim.wo[win].number = false
    vim.wo[win].relativenumber = false
    vim.wo[win].signcolumn = "no"
    vim.wo[win].foldcolumn = "0"
    vim.wo[win].statuscolumn = ""
    vim.wo[win].wrap = false
    vim.wo[win].winbar = ""
    return win
end

local function cache_for(pdf)
    local revision = stats_revision(pdf)
    local tag = vim.fn.sha256(pdf .. "\0" .. revision):sub(1, 16)
    return vim.fn.stdpath("cache") .. "/snacks/image/tex/" .. tag
end

local function can_preview()
    if not Snacks or not Snacks.image or not Snacks.image.config.enabled then
        notify("Enable the images capability to use Snacks.image PDF preview.", vim.log.levels.WARN)
        return false
    end
    if not Snacks.image.supports_terminal() then
        notify("Snacks.image PDF preview requires a Kitty-compatible graphics terminal (Kitty).", vim.log.levels.ERROR)
        return false
    end
    if vim.fn.executable("magick") ~= 1 or vim.fn.executable("gs") ~= 1 then
        notify("PDF preview requires ImageMagick (magick) and Ghostscript (gs).", vim.log.levels.ERROR)
        return false
    end
    return true
end

local function attach(state)
    if not vim.api.nvim_buf_is_valid(state.buf) then return end
    if not can_preview() then return end

    Snacks.image.placement.clean(state.buf)
    vim.bo[state.buf].modifiable = true
    vim.api.nvim_buf_set_lines(state.buf, 0, -1, false, { " " })
    vim.bo[state.buf].modifiable = false
    vim.bo[state.buf].modified = false

    -- Snacks caches conversions by source path and page. Use a PDF-revision-specific
    -- cache directory so recompiling the same PDF path cannot display stale pixels.
    local image_config = Snacks.image.config
    local old_cache = image_config.cache
    image_config.cache = cache_for(state.pdf)
    -- Snacks' converter understands the #page selector, but its initial format
    -- check currently sees "pdf#page=N" as an unsupported extension.
    local old_supports = Snacks.image.supports
    Snacks.image.supports = function(src)
        return old_supports(src:gsub("#page=%d+$", ""))
    end
    local ok, placement = pcall(Snacks.image.buf._attach, state.buf, {
        src = state.pdf .. "#page=" .. state.page,
        pos = { 1, 0 },
        auto_resize = true,
    })
    Snacks.image.supports = old_supports
    image_config.cache = old_cache
    if not ok then
        notify("Could not attach PDF page: " .. tostring(placement), vim.log.levels.ERROR)
        return
    end
    state.placement = placement
    state.revision = stats_revision(state.pdf)
    if state.win and vim.api.nvim_win_is_valid(state.win) then
        vim.wo[state.win].statusline = statusline(state)
    end
end

local function preview_for(pdf)
    local key = project_key(pdf)
    local state = previews[key]
    if state and vim.api.nvim_buf_is_valid(state.buf) then
        state.pdf = pdf
        return state
    end

    local buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_name(buf, "snacks-pdf://" .. key:sub(1, 16))
    vim.bo[buf].buftype = "nofile"
    vim.bo[buf].bufhidden = "hide"
    vim.bo[buf].swapfile = false
    vim.bo[buf].buflisted = false
    local created = { buf = buf, pdf = pdf, page = 1, win = nil, placement = nil }
    previews[key] = created

    local function map(lhs, callback, desc)
        vim.keymap.set("n", lhs, callback, { buffer = buf, silent = true, desc = desc })
    end
    map("n", function() M.next_page(buf) end, "Next PDF page")
    map("<PageDown>", function() M.next_page(buf) end, "Next PDF page")
    map("<ScrollWheelDown>", function() M.next_page(buf) end, "Next PDF page")
    map("p", function() M.previous_page(buf) end, "Previous PDF page")
    map("<PageUp>", function() M.previous_page(buf) end, "Previous PDF page")
    map("<ScrollWheelUp>", function() M.previous_page(buf) end, "Previous PDF page")
    map("r", function() M.refresh(buf) end, "Refresh PDF preview")
    map("q", function()
        local win = vim.api.nvim_get_current_win()
        if vim.api.nvim_win_get_buf(win) == buf then vim.api.nvim_win_close(win, true) end
    end, "Close PDF preview")
    map("<LeftMouse>", function() M.reverse_search(buf) end, "SyncTeX reverse search")

    return created
end

local function set_page(state, page)
    if not vim.uv.fs_stat(state.pdf) then
        notify("PDF not found yet. Compile the LaTeX document first.", vim.log.levels.WARN)
        return false
    end
    page = math.max(1, math.floor(page))
    state.page = page
    attach(state)
    return true
end

local function current_page(pdf, source, line, column, cwd, compiler_file)
    if vim.fn.executable("synctex") ~= 1 then return 1 end
    local output = run_synctex(
        { "synctex", "view", "-i", string.format("%d:%d:%s", line, column, source), "-o", pdf },
        cwd,
        pdf,
        cwd,
        compiler_file
    )
    if not output then return 1 end
    for _, record in ipairs(output) do
        local page = tonumber(record:match("^Page:%s*(%d+)"))
        if page then return page end
    end
    return 1
end

local function source_context(buf)
    local project = vimtex_state(buf)
    if not project then
        notify("No VimTeX project is attached to this buffer.", vim.log.levels.WARN)
        return nil
    end
    local pdf = output_pdf(buf)
    if not pdf then
        notify("VimTeX has not selected a PDF output yet. Compile once, then retry.", vim.log.levels.WARN)
        return nil
    end
    return project, pdf, compiler_file(buf, "synctex.gz")
end

function M.open()
    local source_win = vim.api.nvim_get_current_win()
    local source_buf = vim.api.nvim_get_current_buf()
    local project, pdf, synctex_file = source_context(source_buf)
    if not project then return end
    if not vim.uv.fs_stat(pdf) then
        notify("Compile the LaTeX document before opening its PDF preview.", vim.log.levels.WARN)
        return
    end
    if not can_preview() then return end
    if vim.fn.executable("synctex") ~= 1 then
        notify("SyncTeX is not on PATH; forward and reverse search are unavailable.", vim.log.levels.ERROR)
        return
    end
    local line, column = unpack(vim.api.nvim_win_get_cursor(source_win))
    local page = current_page(
        pdf,
        vim.api.nvim_buf_get_name(source_buf),
        line,
        column,
        project.root,
        synctex_file
    )
    local state = preview_for(pdf)
    state.source_dir = project.root
    state.synctex_file = synctex_file
    ensure_window(state, source_win)
    update_mousefocus()
    set_page(state, page)
    if vim.api.nvim_win_is_valid(source_win) then vim.api.nvim_set_current_win(source_win) end
end

local function page_count(state)
    if vim.fn.executable("pdfinfo") ~= 1 then return nil end
    local result = vim.system({ "pdfinfo", state.pdf }, { text = true }):wait()
    if result.code ~= 0 then return nil end
    return tonumber((result.stdout or ""):match("\nPages:%s*(%d+)"))
end

function M.next_page(buf)
    local state
    for _, candidate in pairs(previews) do if candidate.buf == buf then state = candidate; break end end
    if not state then return end
    local count = page_count(state)
    set_page(state, count and math.min(state.page + 1, count) or state.page + 1)
end

function M.previous_page(buf)
    local state
    for _, candidate in pairs(previews) do if candidate.buf == buf then state = candidate; break end end
    if not state then return end
    set_page(state, math.max(1, state.page - 1))
end

function M.refresh(buf)
    local state
    for _, candidate in pairs(previews) do if candidate.buf == buf then state = candidate; break end end
    if not state then return end
    attach(state)
end

function M.reverse_search(buf)
    local state
    for _, candidate in pairs(previews) do if candidate.buf == buf then state = candidate; break end end
    if not state or not state.placement then return end
    local mouse = vim.fn.getmousepos()
    if not mouse or mouse.winid ~= state.win then return end

    local wininfo = vim.fn.getwininfo(state.win)[1]
    local placement = state.placement
    local loc = placement:state().loc
    local info = placement.img.info
    if not wininfo or not info or not info.size or not info.dpi or info.dpi.width <= 0 or info.dpi.height <= 0 then
        notify("PDF page geometry is not ready yet; try again in a moment.", vim.log.levels.WARN)
        return
    end
    local x_cells = mouse.screencol - (wininfo.wincol + wininfo.textoff)
    local y_cells = mouse.screenrow - wininfo.winrow
    if x_cells < 0 or y_cells < 0 or x_cells >= loc.width or y_cells >= loc.height then return end

    local page_width = info.size.width / info.dpi.width * 72
    local page_height = info.size.height / info.dpi.height * 72
    local x = math.floor(x_cells / loc.width * page_width)
    local y = math.floor(y_cells / loc.height * page_height)
    local output = run_synctex({
        "synctex", "edit", "-o", string.format("%d:%d:%d:%s", state.page, x, y, state.pdf),
    },
        state.source_dir or vim.fn.fnamemodify(state.pdf, ":h"),
        state.pdf,
        state.source_dir,
        state.synctex_file
    )
    if not output then return end

    local file, line, column
    for _, record in ipairs(output) do
        file = file or record:match("^Input:%s*(.+)$")
        line = line or tonumber(record:match("^Line:%s*(%d+)"))
        column = column or tonumber(record:match("^Column:%s*(-?%d+)"))
    end
    if not file or not line or line < 1 then
        notify("No source location was found at that PDF position.", vim.log.levels.WARN)
        return
    end
    local ok, err = pcall(vim.fn["vimtex#view#inverse_search"], line, file, math.max(column or 0, 0))
    if not ok then notify("VimTeX reverse search failed: " .. tostring(err), vim.log.levels.ERROR) end
end

function M.on_compile_success()
    for _, state in pairs(previews) do
        if vim.api.nvim_buf_is_valid(state.buf) and vim.uv.fs_stat(state.pdf)
            and state.revision ~= stats_revision(state.pdf) then
            attach(state)
        end
    end
end

function M.setup()
    vim.api.nvim_create_autocmd("User", {
        group = group,
        pattern = "VimtexEventCompileSuccess",
        callback = M.on_compile_success,
    })
    vim.api.nvim_create_autocmd({ "WinClosed", "BufWinLeave" }, {
        group = group,
        callback = function()
            vim.schedule(update_mousefocus)
        end,
    })
end

return M
