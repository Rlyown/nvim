local M = {}

local ainput = require("core.gfunc").fn.async_ui_input_wrap()

function M.term_id_cmds(cmd_str)
    local opts = {
        prompt = "Input Terminal ID:",
        kind = "center",
        default = "1",
    }
    local function on_confirm(input)
        local id = tonumber(input)
        if not id or (id < 1) then
            return
        end

        local s = string.format("%s %d", cmd_str, id)
        vim.cmd(s)
    end

    local do_func = function()
        ainput(opts, on_confirm)
    end

    return do_func
end

function M.term_multi_hv(rate, direction)
    local opts = {
        prompt = "Input Terminal ID:",
        kind = "center",
        default = "1",
    }

    local function on_confirm(input)
        local id = tonumber(input)
        if not id or (id < 1) then
            return
        end

        local size = 20

        if direction == "vertical" then
            size = vim.o.columns * rate
        elseif direction == "horizontal" then
            size = vim.o.lines * rate
        end

        local s = string.format("%dToggleTerm size=%d direction=%s", id, size, direction)
        vim.cmd(s)
    end

    local do_func = function()
        ainput(opts, on_confirm)
    end

    return do_func
end

return M
