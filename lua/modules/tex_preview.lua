local M = {}

local previews = {}
local prefetch_pages = 3
local attach_page
local update_visible_pages
local queue_visible_update
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

local function compiler_running(buf)
    local ok, running = pcall(vim.api.nvim_buf_call, buf, function()
        return vim.fn.eval("b:vimtex.compiler.is_running()")
    end)
    return ok and (running == true or running == 1)
end

local function output_pdf(buf)
    return compiler_file(buf, "pdf")
end

local function find_synctex_file(pdf, source_dir, compiler_file_path)
    if compiler_file_path and compiler_file_path ~= "" and vim.uv.fs_stat(compiler_file_path) then
        return compiler_file_path
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

local function run_synctex(args, cwd, pdf, source_dir, compiler_file_path)
    if vim.fn.executable("synctex") ~= 1 then
        notify("SyncTeX is not on PATH; install/configure a TeX distribution with SyncTeX.", vim.log.levels.ERROR)
        return nil
    end
    local synctex_file = pdf and find_synctex_file(pdf, source_dir or cwd, compiler_file_path)
    if pdf and not synctex_file then
        notify(
            "No SyncTeX data found for " .. vim.fn.fnamemodify(pdf, ":t")
                .. ". The matching .synctex or .synctex.gz file is missing. Run <leader>lb to make VimTeX force a one-time SyncTeX rebuild.",
            vim.log.levels.WARN
        )
        return nil
    end

    local command = vim.list_extend({}, args)
    local synctex_dir = synctex_file and vim.fn.fnamemodify(synctex_file, ":h")
    if synctex_dir and synctex_dir ~= vim.fn.fnamemodify(pdf, ":h") then
        table.insert(command, "-d")
        table.insert(command, synctex_dir)
    end
    local result = vim.system(command, { cwd = cwd, text = true }):wait()
    if result.code ~= 0 then
        local detail = vim.trim((result.stderr or "") .. "\n" .. (result.stdout or ""))
        if detail:find("No SyncTeX available", 1, true) then
            notify(
                "SyncTeX could not match " .. vim.fn.fnamemodify(pdf or "PDF", ":t")
                    .. ". Confirm the sidecar belongs to the current PDF and that compilation has finished.",
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
    local ctime = stat.ctime or {}
    -- Compilers may replace a PDF with another file of identical size and
    -- timestamp precision. Include inode/ctime so a completed rebuild still
    -- invalidates Snacks' converted-page cache when the filesystem exposes them.
    return table.concat({
        stat.dev or 0,
        stat.ino or 0,
        stat.size or 0,
        mtime.sec or 0,
        mtime.nsec or 0,
        ctime.sec or 0,
        ctime.nsec or 0,
    }, "-")
end

local function advance_revision(state, pdf_revision)
    state.pdf_revision = pdf_revision
    state.page_aspects = {}
    state.render_generation = (state.render_generation or 0) + 1
    -- A unique render identity also invalidates the cache when metadata is
    -- unchanged (for example, an identical-output rebuild).
    state.revision = pdf_revision .. "-" .. state.render_generation
end

local function pdf_page_count(pdf)
    if vim.fn.executable("pdfinfo") == 1 then
        local result = vim.system({ "pdfinfo", pdf }, { text = true }):wait()
        if result.code == 0 then
            local count = tonumber((result.stdout or ""):match("Pages:%s*(%d+)"))
            if count and count > 0 then return count end
        end
    end

    -- Kitty machines often have ImageMagick/Ghostscript for Snacks.image but
    -- do not have Poppler's pdfinfo. ImageMagick's scene index is zero-based.
    if vim.fn.executable("magick") == 1 then
        local result = vim.system({ "magick", "identify", "-format", "%p\n", pdf }, { text = true }):wait()
        if result.code == 0 then
            local last_page = -1
            for page in (result.stdout or ""):gmatch("%d+") do
                last_page = math.max(last_page, tonumber(page))
            end
            if last_page >= 0 then return last_page + 1 end
        end
    end
end

local function statusline(state)
    local mode = state.zoom_mode == "full-page" and "Full page" or "Fit width"
    local scroll = state.zoom_mode == "full-page" and "j/k: page" or "j/k: 1/4 page"
    return string.format(
        " PDF %d/%s | %s | %s | n/p: page | ?: keys | click: SyncTeX | q: close ",
        state.page,
        state.page_count or "?",
        mode,
        scroll
    )
end

local function win_is_showing(win, buf)
    return win and vim.api.nvim_win_is_valid(win) and vim.api.nvim_win_get_buf(win) == buf
end

local function page_start_line(state, page)
    return (page - 1) * state.page_span + 1
end

local function page_end_line(state, page)
    return page * state.page_span
end

local function line_page(state, line)
    local page = math.floor((math.max(1, line) - 1) / state.page_span) + 1
    return math.max(1, math.min(state.page_count or page, page))
end

local function help_config(state)
    if not win_is_showing(state.win, state.buf) then return nil end
    local win_width = vim.api.nvim_win_get_width(state.win)
    local win_height = vim.api.nvim_win_get_height(state.win)
    local height = math.max(1, math.min(13, math.floor(win_height / 2)))
    local width = math.max(1, math.min(76, win_width - 2))
    return {
        relative = "win",
        win = state.win,
        -- Leave room for the float's top and bottom border inside the preview.
        row = math.max(0, win_height - height - 2),
        col = math.max(0, math.floor((win_width - width) / 2)),
        width = width,
        height = height,
        style = "minimal",
        border = "rounded",
        title = " PDF preview keys ",
        title_pos = "center",
        zindex = 80,
    }
end

local function close_help(state, restore_focus)
    local win, buf = state.help_win, state.help_buf
    state.help_win, state.help_buf = nil, nil
    if win and vim.api.nvim_win_is_valid(win) then
        pcall(vim.api.nvim_win_close, win, true)
    end
    if buf and vim.api.nvim_buf_is_valid(buf) then
        pcall(vim.api.nvim_buf_delete, buf, { force = true })
    end
    if restore_focus and win_is_showing(state.win, state.buf) then
        pcall(vim.api.nvim_set_current_win, state.win)
    end
end

local function toggle_help(state)
    if state.help_win and vim.api.nvim_win_is_valid(state.help_win) then
        close_help(state, true)
        return
    end
    local config = help_config(state)
    if not config then return end

    local buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, {
        "j/k  1/4-page scroll; pages in full-page mode",
        "n/p  next / previous PDF page",
        "PgDn/PgUp  next / previous PDF page",
        "Wheel  scroll/page, depending on zoom mode",
        "",
        "w  fit width (default)",
        "f  fit full page",
        "z  toggle zoom mode",
        "",
        "Click  SyncTeX reverse search",
        "r  refresh PDF",
        "? / Esc  close this helper",
        "q  close the PDF preview",
    })
    vim.bo[buf].buftype = "nofile"
    vim.bo[buf].bufhidden = "wipe"
    vim.bo[buf].swapfile = false
    vim.bo[buf].modifiable = false
    vim.bo[buf].readonly = true
    local win = vim.api.nvim_open_win(buf, true, config)
    state.help_buf, state.help_win = buf, win
    vim.wo[win].wrap = true
    vim.wo[win].number = false
    vim.wo[win].relativenumber = false
    vim.wo[win].cursorline = false
    vim.wo[win].winhighlight = "Normal:NormalFloat,FloatBorder:FloatBorder"

    local function map_helper(lhs, callback, desc)
        vim.keymap.set("n", lhs, callback, { buffer = buf, silent = true, desc = desc })
    end
    map_helper("j", function() M.scroll(state.buf, 1) end, "Scroll PDF down")
    map_helper("k", function() M.scroll(state.buf, -1) end, "Scroll PDF up")
    map_helper("n", function() M.next_page(state.buf) end, "Next PDF page")
    map_helper("p", function() M.previous_page(state.buf) end, "Previous PDF page")
    map_helper("<PageDown>", function() M.next_page(state.buf) end, "Next PDF page")
    map_helper("<PageUp>", function() M.previous_page(state.buf) end, "Previous PDF page")
    map_helper("<ScrollWheelDown>", function() M.scroll(state.buf, 1) end, "Scroll PDF down")
    map_helper("<ScrollWheelUp>", function() M.scroll(state.buf, -1) end, "Scroll PDF up")
    map_helper("w", function() M.set_zoom(state.buf, "fit-width") end, "Fit PDF to preview width")
    map_helper("f", function() M.set_zoom(state.buf, "full-page") end, "Fit PDF page to window")
    map_helper("z", function() M.toggle_zoom(state.buf) end, "Toggle PDF zoom mode")
    map_helper("r", function() M.refresh(state.buf) end, "Refresh PDF preview")
    map_helper("q", function()
        close_help(state, true)
        if win_is_showing(state.win, state.buf) then
            pcall(vim.api.nvim_win_close, state.win, true)
        end
    end, "Close PDF preview")
    for _, key in ipairs({ "<Esc>", "?" }) do
        map_helper(key, function() close_help(state, true) end, "Close PDF preview help")
    end
end

local function find_state(buf)
    for _, state in pairs(previews) do
        if state.buf == buf then return state end
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
    vim.wo[win].scrolloff = 0
    vim.wo[win].conceallevel = 2
    vim.wo[win].concealcursor = "nvic"
    vim.wo[win].winbar = ""
    vim.wo[win].statusline = statusline(state)
    return win
end

local function cache_for(pdf, revision)
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

local function close_placements(state)
    for _, placement in pairs(state.pending) do
        placement:close()
    end
    for _, placement in pairs(state.placements) do
        placement:close()
    end
    state.pending = {}
    state.placements = {}
end

local function placement_dimensions(state)
    if not win_is_showing(state.win, state.buf) then return 1, 1 end
    -- Snacks.image encodes placement coordinates with at most 100 diacritics.
    local width = math.max(1, math.min(100, vim.api.nvim_win_get_width(state.win)))
    local height = math.max(1, math.min(100, vim.api.nvim_win_get_height(state.win)))
    if state.zoom_mode ~= "full-page" then
        -- A tall bound lets the page keep its natural aspect ratio while filling
        -- the preview width; full-page mode instead fits both window dimensions.
        height = 100
    end
    return width, height
end

local function resize_placements(state)
    if not win_is_showing(state.win, state.buf) then return end
    local width, height = placement_dimensions(state)
    for _, placements in ipairs({ state.pending, state.placements }) do
        for _, placement in pairs(placements) do
            if placement.opts then
                placement.opts.width = width
                placement.opts.height = height
                pcall(placement.update, placement)
            end
        end
    end
    vim.wo[state.win].statusline = statusline(state)
end

local function schedule_resize(state)
    if state.resize_scheduled then return end
    state.resize_scheduled = true
    vim.schedule(function()
        state.resize_scheduled = false
        if not vim.api.nvim_buf_is_valid(state.buf) or not win_is_showing(state.win, state.buf) then return end
        resize_placements(state)
        if state.help_win and vim.api.nvim_win_is_valid(state.help_win) then
            local config = help_config(state)
            if config then pcall(vim.api.nvim_win_set_config, state.help_win, config) end
        end
        queue_visible_update(state)
    end)
end

local function set_document_lines(state, count)
    if state.buffer_pages == count then return end
    if state.buffer_pages then close_placements(state) end

    local lines = {}
    for _ = 1, count * state.page_span do
        lines[#lines + 1] = " "
    end
    vim.bo[state.buf].modifiable = true
    vim.api.nvim_buf_set_lines(state.buf, 0, -1, false, lines)
    vim.bo[state.buf].modifiable = false
    vim.bo[state.buf].modified = false
    state.buffer_pages = count
end

local function viewport_pages(state)
    if not win_is_showing(state.win, state.buf) then
        local page = math.max(1, state.page or 1)
        return page, page
    end

    -- nvim_win_call returns a single callback result through the API boundary;
    -- returning two Lua values here leaves `bottom` nil on some Neovim versions.
    local ok, bounds = pcall(vim.api.nvim_win_call, state.win, function()
        return { top = vim.fn.line("w0"), bottom = vim.fn.line("w$") }
    end)
    local fallback = math.max(1, math.min(state.page_count or 1, state.page or 1))
    if not ok or type(bounds) ~= "table" then
        return fallback, fallback
    end

    local top = tonumber(bounds.top)
    local bottom = tonumber(bounds.bottom)
    if not top or not bottom then
        return fallback, fallback
    end

    top = line_page(state, top)
    bottom = line_page(state, bottom)
    return top, math.max(top, bottom)
end

queue_visible_update = function(state)
    if state.update_scheduled then return end
    state.update_scheduled = true
    vim.schedule(function()
        state.update_scheduled = false
        if vim.api.nvim_buf_is_valid(state.buf) then
            update_visible_pages(state)
        end
    end)
end

update_visible_pages = function(state)
    if not state.page_count or not vim.api.nvim_buf_is_valid(state.buf)
        or not win_is_showing(state.win, state.buf) then
        return
    end

    local top, bottom = viewport_pages(state)
    local first = math.max(1, top - prefetch_pages)
    local last = math.min(state.page_count, bottom + prefetch_pages)
    local visible = math.max(1, math.min(state.page_count, top))
    if state.page ~= visible then
        state.page = visible
        vim.wo[state.win].statusline = statusline(state)
    end

    for page = first, last do
        attach_page(state, page)
    end

    -- Retain a wider margin than the prefetch range to avoid tearing down and
    -- recreating Kitty placements while the user scrolls quickly back and forth.
    local keep_first = math.max(1, first - prefetch_pages)
    local keep_last = math.min(state.page_count, last + prefetch_pages)
    for page, placement in pairs(state.placements) do
        if page < keep_first or page > keep_last then
            placement:close()
            state.placements[page] = nil
        end
    end
    for page, placement in pairs(state.pending) do
        if page < keep_first or page > keep_last then
            placement:close()
            state.pending[page] = nil
        end
    end
end

attach_page = function(state, page)
    if state.placements[page] and state.placements[page].tex_revision == state.revision then return end
    if state.pending[page] and state.pending[page].tex_revision == state.revision then return end
    if state.pending[page] then
        state.pending[page]:close()
        state.pending[page] = nil
    end
    if not vim.api.nvim_buf_is_valid(state.buf) then return end

    -- Snacks caches conversions per source page. Keep a revision-specific cache
    -- so a quick recompile can never reuse pixels from the previous PDF.
    local image_config = Snacks.image.config
    local old_cache = image_config.cache
    image_config.cache = cache_for(state.pdf, state.revision)
    local requested_revision = state.revision
    local requested_pdf_revision = state.pdf_revision
    local old_placement = state.placements[page]
    local width, height = placement_dimensions(state)
    local first_line = page_start_line(state, page)
    local last_line = page_end_line(state, page)
    local ok, placement = pcall(Snacks.image.placement.new, state.buf, state.pdf .. "#page=" .. page, {
        pos = { first_line, 0 },
        range = { first_line, 0, last_line, 0 },
        width = width,
        height = height,
        auto_resize = true,
        inline = true,
        conceal = true,
        on_update = function(next_placement)
            if state.pending[page] ~= next_placement then return end
            if requested_revision ~= state.revision or requested_pdf_revision ~= stats_revision(state.pdf) then
                state.pending[page] = nil
                next_placement:close()
                return
            end
            state.pending[page] = nil
            next_placement.tex_revision = requested_revision
            local info = next_placement.img and next_placement.img.info
            if info and info.size and info.size.width > 0 and info.size.height > 0 then
                state.page_aspects[page] = info.size.height / info.size.width
            end
            state.placements[page] = next_placement
            if old_placement and old_placement ~= next_placement then old_placement:close() end
            if win_is_showing(state.win, state.buf) then
                vim.wo[state.win].statusline = statusline(state)
            end
        end,
    })
    image_config.cache = old_cache
    if not ok then
        notify("Could not render PDF page " .. page .. ": " .. tostring(placement), vim.log.levels.ERROR)
        return
    end
    placement.tex_revision = requested_revision
    state.pending[page] = placement
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
    vim.bo[buf].modifiable = false
    vim.bo[buf].modified = false
    state = {
        buf = buf,
        pdf = pdf,
        page = 1,
        page_count = nil,
        win = nil,
        placements = {},
        pending = {},
        render_generation = 0,
        zoom_mode = "fit-width",
        page_aspects = {},
        page_span = 100,
    }
    previews[key] = state

    local function map(lhs, callback, desc)
        vim.keymap.set("n", lhs, callback, { buffer = buf, silent = true, desc = desc })
    end
    map("j", function() M.scroll(buf, 1) end, "Scroll down or next PDF page")
    map("k", function() M.scroll(buf, -1) end, "Scroll up or previous PDF page")
    map("n", function() M.next_page(buf) end, "Next PDF page")
    map("p", function() M.previous_page(buf) end, "Previous PDF page")
    map("<PageDown>", function() M.next_page(buf) end, "Next PDF page")
    map("<PageUp>", function() M.previous_page(buf) end, "Previous PDF page")
    map("<ScrollWheelDown>", function() M.scroll(buf, 1) end, "Scroll down or next PDF page")
    map("<ScrollWheelUp>", function() M.scroll(buf, -1) end, "Scroll up or previous PDF page")
    map("w", function() M.set_zoom(buf, "fit-width") end, "Fit PDF to preview width")
    map("f", function() M.set_zoom(buf, "full-page") end, "Fit PDF page to window")
    map("z", function() M.toggle_zoom(buf) end, "Toggle PDF zoom mode")
    map("?", function() toggle_help(state) end, "Show PDF preview key helper")
    map("r", function() M.refresh(buf) end, "Refresh PDF preview")
    map("q", function()
        local win = vim.api.nvim_get_current_win()
        if vim.api.nvim_win_get_buf(win) == buf then vim.api.nvim_win_close(win, true) end
    end, "Close PDF preview")
    map("<LeftMouse>", function() M.mouse_click(buf) end, "Focus clicked window or SyncTeX reverse search")

    return state
end

local function set_page(state, page)
    if not vim.uv.fs_stat(state.pdf) then
        notify("PDF not found yet. Compile the LaTeX document first.", vim.log.levels.WARN)
        return false
    end
    page = math.max(1, math.min(state.page_count, math.floor(page)))
    state.page = page
    if win_is_showing(state.win, state.buf) then
        -- Each PDF page occupies a fixed range of placeholder lines. Restore
        -- the view without scrolloff so the target page starts at the top.
        pcall(vim.api.nvim_win_call, state.win, function()
            vim.fn.winrestview({
                topline = page_start_line(state, page),
                topfill = 0,
                lnum = page_start_line(state, page),
                col = 0,
                leftcol = 0,
            })
        end)
        queue_visible_update(state)
    end
    if win_is_showing(state.win, state.buf) then
        vim.wo[state.win].statusline = statusline(state)
    end
    return true
end

local function current_page(pdf, source, line, column, cwd, compiler_file_path)
    if vim.fn.executable("synctex") ~= 1 then return 1 end
    local output = run_synctex(
        { "synctex", "view", "-i", string.format("%d:%d:%s", line, column, source), "-o", pdf },
        cwd,
        pdf,
        cwd,
        compiler_file_path
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

function M.compile()
    local buf = vim.api.nvim_get_current_buf()
    local project = vimtex_state(buf)
    local pdf = project and output_pdf(buf)
    local sidecar = pdf and find_synctex_file(pdf, project.root, compiler_file(buf, "synctex.gz"))

    if pdf and vim.uv.fs_stat(pdf) and not sidecar then
        if compiler_running(buf) then
            notify("VimTeX is already compiling; leaving that build running. Preview will use SyncTeX when the sidecar is ready.")
            return
        end
        -- latexmk does not rebuild a PDF just because SyncTeX was enabled in
        -- the editor config. Force a one-time rebuild to create the sidecar.
        return vim.fn["vimtex#compiler#compile"]("-g")
    end
    return vim.fn["vimtex#compiler#compile"]()
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

    local page_count = pdf_page_count(pdf)
    if not page_count or page_count < 1 then
        notify("Could not read the PDF page count. Check that ImageMagick/Ghostscript can open this PDF.", vim.log.levels.ERROR)
        return
    end
    local line, column = unpack(vim.api.nvim_win_get_cursor(source_win))
    local source = vim.api.nvim_buf_get_name(source_buf)
    local has_synctex = find_synctex_file(pdf, project.root, synctex_file)
    local compiling_without_sidecar = not has_synctex and compiler_running(source_buf)
    local page = compiling_without_sidecar and 1
        or current_page(pdf, source, line, column, project.root, synctex_file)
    local state = preview_for(pdf)
    local revision = stats_revision(pdf)
    if state.pdf_revision ~= revision then
        advance_revision(state, revision)
        close_placements(state)
    end
    state.source_buf = source_buf
    state.source = source
    state.source_line = line
    state.source_column = column
    state.source_dir = project.root
    state.synctex_file = synctex_file
    state.page_count = page_count
    set_document_lines(state, page_count)
    ensure_window(state, source_win)
    set_page(state, page)
    update_visible_pages(state)
    if vim.api.nvim_win_is_valid(source_win) then vim.api.nvim_set_current_win(source_win) end
end

function M.next_page(buf)
    local state = find_state(buf)
    if not state then return end
    state.page_count = state.page_count or pdf_page_count(state.pdf)
    if not state.page_count then
        notify("Could not read the PDF page count. Check that ImageMagick/Ghostscript can open this PDF.", vim.log.levels.ERROR)
        return
    end
    local page = state.page
    if win_is_showing(state.win, state.buf) then
        page = line_page(state, vim.api.nvim_win_get_cursor(state.win)[1])
    end
    set_page(state, page + 1)
end

function M.previous_page(buf)
    local state = find_state(buf)
    if not state then return end
    local page = state.page
    if win_is_showing(state.win, state.buf) then
        page = line_page(state, vim.api.nvim_win_get_cursor(state.win)[1])
    end
    set_page(state, page - 1)
end

function M.scroll(buf, direction)
    local state = find_state(buf)
    if not state then return end
    if state.zoom_mode == "full-page" then
        if direction > 0 then M.next_page(buf) else M.previous_page(buf) end
        return
    end
    if not win_is_showing(state.win, state.buf) then return end

    local page = line_page(state, vim.api.nvim_win_get_cursor(state.win)[1])
    local placement = state.placements[page]
    if placement and placement.tex_revision ~= state.revision then
        placement = nil
    end
    local page_rows
    if placement then
        local ok, placement_state = pcall(placement.state, placement)
        page_rows = ok and placement_state and placement_state.loc and placement_state.loc.height
    end
    if not page_rows then
        local aspect = state.page_aspects[page] or (792 / 612)
        local terminal = Snacks.image.terminal.size()
        local width = placement_dimensions(state)
        local cell_width = terminal.cell_width or 1
        local cell_height = terminal.cell_height or 1
        page_rows = width * aspect * cell_width / cell_height
    end

    local count = math.max(1, math.floor(page_rows / 4 + 0.5))
    local scroll_key = direction > 0 and string.char(5) or string.char(25) -- Ctrl-E / Ctrl-Y
    pcall(vim.api.nvim_win_call, state.win, function()
        vim.cmd.normal({ args = { tostring(count) .. scroll_key }, bang = true })
    end)
    queue_visible_update(state)
end

function M.set_zoom(buf, mode)
    local state = find_state(buf)
    if not state or (mode ~= "fit-width" and mode ~= "full-page") or state.zoom_mode == mode then return end
    state.zoom_mode = mode
    resize_placements(state)
    set_page(state, state.page)
    schedule_resize(state)
end

function M.toggle_zoom(buf)
    local state = find_state(buf)
    if not state then return end
    M.set_zoom(buf, state.zoom_mode == "fit-width" and "full-page" or "fit-width")
end

function M.refresh(buf)
    local state = find_state(buf)
    if not state then return end
    if not can_preview() then return end
    local count = pdf_page_count(state.pdf)
    if not count or count < 1 then
        notify("Could not refresh the PDF page count. Check that ImageMagick/Ghostscript can open this PDF.", vim.log.levels.ERROR)
        return
    end
    state.page_count = count
    advance_revision(state, stats_revision(state.pdf))
    set_document_lines(state, count)
    state.page = math.min(state.page, count)
    close_placements(state)
    if win_is_showing(state.win, state.buf) then update_visible_pages(state) end
end

local function placement_at_mouse(state, mouse)
    if not win_is_showing(state.win, state.buf) then return end
    for page, placement in pairs(state.placements) do
        local ok, placement_state = pcall(function() return placement:state() end)
        local loc = ok and placement_state and placement_state.loc
        local info = placement.img and placement.img.info
        if loc and info and info.size and info.dpi and info.dpi.width > 0 and info.dpi.height > 0 then
            local first_line = page_start_line(state, page)
            local screen = vim.fn.screenpos(state.win, first_line, 1)
            local image_col, image_row
            if screen and screen.row > 0 and screen.col > 0 then
                -- The page range is backed by physical placeholder rows and
                -- Snacks overlays one image row on each row in the range.
                image_col = screen.col
                image_row = screen.row
            else
                -- If the page start is above the viewport, the next page start
                -- gives the current page's image origin from its rendered height.
                local next_line = page < state.page_count
                    and vim.fn.screenpos(state.win, page_start_line(state, page + 1), 1)
                if next_line and next_line.row > 0 and next_line.col > 0 then
                    image_col = next_line.col
                    image_row = next_line.row - loc.height
                else
                    -- Pages use real placeholder rows, so a viewport scrolled
                    -- into a page can recover the image origin from its top row.
                    local view_ok, view = pcall(vim.api.nvim_win_call, state.win, function()
                        return vim.fn.winsaveview()
                    end)
                    local top_line = view_ok and type(view) == "table" and tonumber(view.topline)
                    local visible = top_line and vim.fn.screenpos(state.win, top_line, 1)
                    if top_line and line_page(state, top_line) == page and visible
                        and visible.row > 0 and visible.col > 0 then
                        image_col = visible.col
                        image_row = visible.row - (top_line - first_line)
                    end
                end
            end
            if image_col and image_row then
                local x_cells = mouse.screencol - image_col
                local y_cells = mouse.screenrow - image_row
                if x_cells >= 0 and y_cells >= 0 and x_cells < loc.width and y_cells < loc.height then
                    return page, x_cells, y_cells, loc, info
                end
            end
        end
    end
end

function M.reverse_search(buf)
    local state = find_state(buf)
    if not state then return end
    local mouse = vim.fn.getmousepos()
    if not mouse or mouse.winid ~= state.win then return end

    local page, x_cells, y_cells, loc, info = placement_at_mouse(state, mouse)
    if not page then
        notify("Click inside a rendered PDF page to run SyncTeX reverse search.", vim.log.levels.INFO)
        return
    end
    local page_width = info.size.width / info.dpi.width * 72
    local x = math.floor(x_cells / loc.width * page_width)
    local y = math.floor(y_cells / loc.height * (info.size.height / info.dpi.height * 72))
    local output = run_synctex({
        "synctex", "edit", "-o", string.format("%d:%d:%d:%s", page, x, y, state.pdf),
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

local function focus_mouse_window(mouse, preview_win)
    local target_win = mouse.winid
    if not target_win or target_win == preview_win or not vim.api.nvim_win_is_valid(target_win) then return end

    local function focus_and_place_cursor()
        if not vim.api.nvim_win_is_valid(target_win) then return end
        pcall(vim.api.nvim_set_current_win, target_win)
        local target_buf = vim.api.nvim_win_get_buf(target_win)
        local line_count = vim.api.nvim_buf_line_count(target_buf)
        local line = math.max(1, math.min(mouse.line or 1, line_count))
        local line_text = vim.api.nvim_buf_get_lines(target_buf, line - 1, line, false)[1] or ""
        local column = math.min(math.max((mouse.column or 1) - 1, 0), #line_text)
        pcall(vim.api.nvim_win_set_cursor, target_win, { line, column })
    end

    -- The buffer-local mouse mapping replaces Neovim's built-in <LeftMouse>
    -- action. Apply both focus and cursor placement ourselves after dispatch.
    focus_and_place_cursor()
    vim.schedule(focus_and_place_cursor)
end

function M.mouse_click(buf)
    local state = find_state(buf)
    if not state then return end
    local mouse = vim.fn.getmousepos()
    if not mouse or not mouse.winid or not vim.api.nvim_win_is_valid(mouse.winid) then return end
    if mouse.winid == state.win then
        M.reverse_search(buf)
    else
        focus_mouse_window(mouse, state.win)
    end
end

local function refresh_after_compile()
    for _, state in pairs(previews) do
        if vim.api.nvim_buf_is_valid(state.buf) and vim.uv.fs_stat(state.pdf) then
            local revision = stats_revision(state.pdf)
            if state.pdf_revision ~= revision then
                local count = pdf_page_count(state.pdf)
                if count and count > 0 then
                    state.page_count = count
                    advance_revision(state, revision)
                    set_document_lines(state, count)
                    state.page = math.min(state.page, count)

                    local source_buf = state.source_buf
                    if source_buf and vim.api.nvim_buf_is_valid(source_buf) then
                        local synctex_file = compiler_file(source_buf, "synctex.gz")
                        if find_synctex_file(state.pdf, state.source_dir, synctex_file) then
                            state.synctex_file = synctex_file
                            local line, column = state.source_line or 1, state.source_column or 0
                            state.page = current_page(
                                state.pdf,
                                state.source or vim.api.nvim_buf_get_name(source_buf),
                                line,
                                column,
                                state.source_dir,
                                synctex_file
                            )
                        else
                            notify(
                                "VimTeX reported a successful build, but no SyncTeX sidecar was produced. Check the effective latexmk command and project latexmkrc.",
                                vim.log.levels.WARN
                            )
                        end
                    end

                    if win_is_showing(state.win, state.buf) then
                        set_page(state, state.page)
                        update_visible_pages(state)
                    end
                else
                    notify("PDF was rebuilt, but its page count could not be read.", vim.log.levels.WARN)
                end
            end
        end
    end
end

function M.on_compile_success()
    -- VimTeX's latexmk backend may copy its temporary PDF to the final output
    -- path in another VimtexEventCompileSuccess autocmd. Defer our stat/cache
    -- refresh until the whole User event has finished, otherwise we can inspect
    -- the old PDF and never notice the copied build until the preview is opened
    -- again.
    vim.schedule(refresh_after_compile)
end

function M.setup()
    vim.api.nvim_create_autocmd("User", {
        group = group,
        pattern = "VimtexEventCompileSuccess",
        callback = M.on_compile_success,
    })
    vim.api.nvim_create_autocmd("WinResized", {
        group = group,
        callback = function()
            for _, state in pairs(previews) do
                schedule_resize(state)
            end
        end,
    })
    vim.api.nvim_create_autocmd({ "WinScrolled", "CursorMoved" }, {
        group = group,
        callback = function(args)
            local win = args.event == "WinScrolled" and tonumber(args.match) or vim.api.nvim_get_current_win()
            for _, state in pairs(previews) do
                if state.win == win or (args.event == "CursorMoved" and args.buf == state.buf) then
                    queue_visible_update(state)
                end
            end
        end,
    })
    vim.api.nvim_create_autocmd("WinClosed", {
        group = group,
        callback = function(args)
            local closed = tonumber(args.match)
            for _, state in pairs(previews) do
                if state.help_win == closed then
                    state.help_win, state.help_buf = nil, nil
                end
                if state.win == closed then
                    close_help(state, false)
                    close_placements(state)
                    state.win = nil
                end
            end
        end,
    })
    vim.api.nvim_create_autocmd("BufWipeout", {
        group = group,
        callback = function(args)
            for key, state in pairs(previews) do
                if state.buf == args.buf then
                    close_placements(state)
                    previews[key] = nil
                    break
                end
            end
        end,
    })
end

return M
