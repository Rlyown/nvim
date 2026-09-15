local M = { active = false }

function M.exit()
    if M.active then M.hydra.layer:exit() end
end

local function source_window()
    return vim.bo.buftype == "" and vim.api.nvim_get_mode().mode == "n"
        and vim.api.nvim_win_get_config(0).relative == ""
end

function M.enter()
    local session = require("dap").session()
    if not session or session.closed or not source_window() then return end
    M.session = session
    if not M.active then
        M.entering = true
        M.hydra:activate()
        M.entering = false
    end
end

function M.continue()
    require("dap").continue()
    M.enter()
end

function M.setup(dap, ui)
    M.hydra = require("hydra")({
        name = "Debug",
        mode = "n",
        hint = "_n_: Step Over  _s_: Step Into  _o_: Step Out\n_c_: Continue  _b_: Breakpoint  _q_: Terminate  _<Esc>_: Exit Mode",
        config = {
            color = "pink",
            hint = { position = "bottom", float_opts = { border = "rounded" } },
            on_enter = function() M.active = true end,
            on_exit = function() M.active = false end,
        },
        heads = {
            { "n", dap.step_over, { desc = "Step Over" } },
            { "s", dap.step_into, { desc = "Step Into" } },
            { "o", dap.step_out, { desc = "Step Out" } },
            { "c", dap.continue, { desc = "Continue" } },
            { "b", dap.toggle_breakpoint, { desc = "Breakpoint" } },
            { "q", dap.terminate, { exit = true, desc = "Terminate" } },
            { "<Esc>", nil, { exit = true, nowait = true, desc = "Return to Editing" } },
        },
    })
    local group = vim.api.nvim_create_augroup("ConfigDebugMode", { clear = true })
    vim.api.nvim_create_autocmd({ "ModeChanged", "BufEnter", "WinEnter" }, {
        group = group,
        callback = function(a)
            local function check()
                if M.active and not M.entering and not source_window() then M.exit() end
            end
            -- Hint updates temporarily switch buffers; check focus after window operations finish.
            if a.event == "ModeChanged" then check() else vim.schedule(check) end
        end,
    })
    -- Activate only after initialization succeeds; cancellation and startup failure leave no active mode.
    dap.listeners.after.event_initialized.config = function(session)
        M.session = session
        session.on_close.config_debug_mode = function()
            vim.schedule(function()
                if M.session == session then M.exit(); ui.close() end
            end)
        end
        ui.open()
        vim.schedule(function()
            if not session.closed and dap.session() == session then M.enter() end
        end)
    end
    local function finish(session)
        if M.session == session then M.exit(); ui.close() end
    end
    dap.listeners.before.event_terminated.config = finish
    dap.listeners.before.event_exited.config = finish
    dap.listeners.after.disconnect.config = finish
end

return M
