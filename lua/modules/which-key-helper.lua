local M = {}

local ainput = require("core.gfunc").fn.async_ui_input_wrap()

function M.term_id_cmds(name, cmd_str)
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

    return { do_func, name }
end

function M.term_multi_hv(name, rate, direction)
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

    return { do_func, name }
end

function M.telescope_neorg_bind_helper(name, show_name)
    local cmd_format = "<cmd>lua require('telescope').extensions.neorg.%s()<cr>"

    return { string.format(cmd_format, name), show_name }
end

-- bufdelete.nvim plugin cannot kill terminal by Bdelete command
function M.close_buffer()
    local toggleterm_pattern = "^term://.*#toggleterm#%d+"
    if string.find(vim.fn.bufname(), toggleterm_pattern) then
        vim.cmd("bdelete!")
    else
        vim.cmd("lua require('bufdelete').bufdelete(0, true)")
    end
end

function M.markdown_helper()
    local opts = {
        prompt = "Current filetype isn't markdown. Do you want to change it and continue?[Y/n] ",
        kind = "center",
        default = "no",
    }
    local function on_confirm(input)
        if not input or #input == 0 then
            return
        else
            input = string.lower(input)
            if input == "y" or input == "yes" then
                vim.bo.ft = "markdown"
            else
                return
            end
        end
        vim.cmd("MarkdownPreviewToggle")
    end

    local do_func = function()
        if vim.bo.ft == "markdown" then
            vim.cmd("MarkdownPreviewToggle")
        else
            ainput(opts, on_confirm)
        end
    end

    return do_func
end

function M.filetype_check(ft_list)
    local ft = vim.bo.ft
    if type(ft_list) == "string" then
        if ft == ft_list then
            return true
        end
    elseif type(ft_list) == "table" then
        for k, v in ipairs(ft_list) do
            if ft == v then
                return true
            end
        end
    end

    local force = false
    local opts = {
        prompt = "Current filetype not included in allowed list, force run?[Y/n] ",
        kind = "center",
        default = "no",
    }
    local function on_confirm(input)
        input = string.lower(input)
        if #input > 0 and (input == "y" or input == "yes") then
            force = true
        end
    end

    ainput(opts, on_confirm)

    return force
end

function M.lazygit_toggle()
    local Terminal = require("toggleterm.terminal").Terminal
    local lazygit = Terminal:new({
        cmd = [[VISUAL="nvim" EDITOR="nvim" lazygit]],
        hidden = true,
    })
    lazygit:toggle()
end

return M
