return function()
    local toggleterm = require("toggleterm")

    -- float config
    local float_cfg = {
        size = 20,
        open_mapping = [[<c-\>]],
        hide_numbers = true,
        shade_filetypes = {},
        shade_terminals = true,
        shading_factor = 2,
        start_in_insert = true,
        insert_mappings = true,
        persist_size = true,
        direction = "float",
        close_on_exit = true,
        shell = vim.o.shell,
        float_opts = {
            border = "curved",
            winblend = 0,
            highlights = {
                border = "Normal",
                background = "Normal",
            },
        },
    }

    toggleterm.setup(float_cfg)

    -- Create custom terminals
    local Terminal = require("toggleterm.terminal").Terminal

    -- Setup nvim as default editor for lazygit
    local lazygit = Terminal:new({
        cmd = [[VISUAL="nvim" EDITOR="nvim" lazygit]],
        hidden = true,
    })
    function _G._LAZYGIT_TOGGLE()
        lazygit:toggle()
    end

    local python3 = Terminal:new({ cmd = "python3", hidden = true })
    function _G._PYTHON3_TOGGLE()
        python3:toggle()
    end

    local dlv_debug = Terminal:new({ cmd = "dlv debug", hidden = true })
    function _G._DLV_DEBUG_TOGGLE()
        dlv_debug:toggle()
    end
end
