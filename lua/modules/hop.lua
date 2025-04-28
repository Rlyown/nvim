return function()
    local hop = require("hop")

    hop.setup({
        teasing = false, -- Hop should tease you when you do something you are not supposed to
        jump_on_sole_occurrence = true,
        direction = nil,
        inclusive_jump = false,
        uppercase_labels = false,
        char2_fallback_key = nil,
        multi_windows = false, -- Enable cross-windows support and hint all the currently visible windows.
    })
end
