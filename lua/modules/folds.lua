local M = {}

function M.markdown(buf)
    local ranges = require("ufo").getFolds(buf, "treesitter")
    if not ranges then return ranges end
    local root = vim.treesitter.get_parser(buf, "markdown"):parse()[1]:root()
    local outer
    for node in root:iter_children() do
        if node:type() == "section" then
            local heading = node:named_child(0)
            if heading and (heading:type() == "atx_heading" or heading:type() == "setext_heading") then
                if outer then return ranges end
                outer = node
            end
        end
    end
    if not outer then return ranges end
    local start = outer:start()
    -- Keep the document title visible without treating headings in code as sections.
    return vim.tbl_filter(function(range)
        return range.kind ~= "section" or range.startLine ~= start
    end, ranges)
end

return M
