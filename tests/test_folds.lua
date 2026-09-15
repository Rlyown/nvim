local ok, err = xpcall(function()
    if vim.env.NVIM_TEST_PARSER_ROOT then vim.opt.rtp:append(vim.env.NVIM_TEST_PARSER_ROOT) end
    require("lazy").load({ plugins = { "nvim-ufo", "render-markdown.nvim" } })
    local ufo = require("ufo")
    local function press(keys)
        vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(keys, true, false, true), "xt", false)
        vim.cmd.redraw()
        vim.wait(400)
        vim.cmd.redraw()
    end
    local function document(lines)
        vim.cmd("enew!")
        vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)
        vim.bo.filetype = "markdown"
        ufo.attach()
        vim.wait(400)
        return require("modules.folds").markdown(vim.api.nvim_get_current_buf())
    end
    local function section_at(ranges, row)
        for _, range in ipairs(ranges) do
            if range.kind == "section" and range.startLine == row then return true end
        end
        return false
    end

    local ranges = document({ "# Title", "", "## One", "text", "", "## Two", "text", "" })
    assert(not section_at(ranges, 0) and section_at(ranges, 2) and section_at(ranges, 5))
    assert(vim.fn.foldclosed(1) == -1, "A lone document title must stay visible")
    press("zM")
    assert(vim.wo.foldlevel == 99, "Close all must not lower foldlevel")
    assert(vim.fn.foldclosed(1) == -1 and vim.fn.foldclosed(3) == 3 and vim.fn.foldclosed(6) == 6)
    vim.api.nvim_win_set_cursor(0, { 3, 0 })
    press("<CR>")
    assert(vim.fn.foldclosed(3) == -1)
    press("i<Esc>")
    assert(vim.fn.foldclosed(3) == -1, "Leaving insert mode must preserve an opened section")
    assert(vim.fn.foldclosed(6) == 6, "An unrelated closed section must stay closed")
    vim.api.nvim_win_set_cursor(0, { 4, 0 })
    press("iupdated <Esc>")
    assert(vim.fn.foldclosed(3) == -1 and vim.fn.foldclosed(6) == 6, "Edits must preserve fold choices")
    press("zR")
    assert(vim.wo.foldlevel == 99 and vim.fn.foldclosed(6) == -1)

    ranges = document({ "# One", "text", "", "# Two", "text", "" })
    assert(section_at(ranges, 0) and section_at(ranges, 3), "Multiple outer headings must remain foldable")
    ranges = document({ "# One", "text", "", "# Empty" })
    assert(section_at(ranges, 0), "An empty second heading still counts as a sibling")
    ranges = document({ "Title", "=====", "", "text", "" })
    assert(not section_at(ranges, 0), "A lone Setext title must stay visible")
    ranges = document({ "# Title", "", "```markdown", "# Not a heading", "```", "", "## Section", "text", "" })
    assert(not section_at(ranges, 0) and section_at(ranges, 6), "Code block contents must not count as headings")
    local code_fold = false
    for _, range in ipairs(ranges) do
        if range.kind == "fenced_code_block" then code_fold = true end
    end
    assert(code_fold, "Code block folds must be retained")
    print("Markdown fold visibility and insert-mode persistence checks passed")
end, debug.traceback)
if not ok then io.stderr:write(err); vim.cmd("cquit 1") else vim.cmd("qa!") end
