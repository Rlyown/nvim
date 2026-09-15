local M = {}

function M.launch_with_args()
    local dap = require("dap")
    if dap.session() then
        vim.notify("Finish the current debug session before launching with arguments", vim.log.levels.WARN)
        return
    end
    require("modules.debug_mode").exit()
    vim.ui.input({ prompt = "Program arguments: " }, function(value)
        if value == nil then return end
        local ok, args = pcall(require("dap.utils").splitstr, value)
        if not ok or type(args) ~= "table" then
            vim.notify("Unable to parse program arguments", vim.log.levels.ERROR)
            return
        end
        dap.continue({ before = function(config)
            local launch = vim.deepcopy(config)
            launch.args = args
            return launch
        end })
    end)
end

function M.logpoint()
    require("modules.debug_mode").exit()
    local buf, line = vim.api.nvim_get_current_buf(), vim.fn.line(".")
    vim.ui.input({ prompt = "Logpoint message: " }, function(value)
        if not value or value == "" or not vim.api.nvim_buf_is_valid(buf) then return end
        vim.api.nvim_buf_call(buf, function()
            local cursor = vim.api.nvim_win_get_cursor(0)
            vim.api.nvim_win_set_cursor(0, { math.min(line, vim.api.nvim_buf_line_count(buf)), 0 })
            local ok, err = pcall(require("dap").set_breakpoint, nil, nil, value)
            vim.api.nvim_win_set_cursor(0, cursor)
            if not ok then vim.notify(tostring(err), vim.log.levels.ERROR) end
        end)
    end)
end

return M
