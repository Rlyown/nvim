return {
    {
        'mfussenegger/nvim-dap',
        config = function()
            local dap = require("dap")

            -- setup adapter and language

            require("plugins.dap.settings.codelldb") -- for C/Cpp/Rust

            -- Set up keybindings
            vim.api.nvim_create_user_command("RunScriptWithArgs", function(t)
                -- :help nvim_create_user_command
                args = vim.split(vim.fn.expand(t.args), '\n')
                approval = vim.fn.confirm(
                    "Will try to run:\n    " ..
                    vim.bo.filetype .. " " ..
                    vim.fn.expand('%') .. " " ..
                    t.args .. "\n\n" ..
                    "Do you approve? ",
                    "&Yes\n&No", 1
                )
                if approval == 1 then
                    dap.run({
                        type = vim.bo.filetype,
                        request = 'launch',
                        name = 'Launch file with custom arguments (adhoc)',
                        program = '${file}',
                        args = args,
                    })
                end
            end, {
                complete = 'file',
                nargs = '*'
            })


            -- Notify dap integration
            local notify_status_ok, _ = pcall(require, "notify")
            if notify_status_ok then
                local client_notifs = {}

                local function get_notif_data(client_id, token)
                    if not client_notifs[client_id] then
                        client_notifs[client_id] = {}
                    end

                    if not client_notifs[client_id][token] then
                        client_notifs[client_id][token] = {}
                    end

                    return client_notifs[client_id][token]
                end

                local spinner_frames = { "⣾", "⣽", "⣻", "⢿", "⡿", "⣟", "⣯", "⣷" }

                local function update_spinner(client_id, token)
                    local notif_data = get_notif_data(client_id, token)

                    if notif_data.spinner then
                        local new_spinner = (notif_data.spinner + 1) % #spinner_frames
                        notif_data.spinner = new_spinner

                        notif_data.notification = vim.notify(nil, nil, {
                            hide_from_history = true,
                            icon = spinner_frames[new_spinner],
                            replace = notif_data.notification,
                        })

                        vim.defer_fn(function()
                            update_spinner(client_id, token)
                        end, 100)
                    end
                end

                local function format_title(title, client_name)
                    return client_name .. (#title > 0 and ": " .. title or "")
                end

                local function format_message(message, percentage)
                    return (percentage and percentage .. "%\t" or "") .. (message or "")
                end

                -- DAP integration
                -- Make sure to also have the snippet with the common helper functions in your config!
                dap.listeners.before["event_progressStart"]["progress-notifications"] = function(session, body)
                    local notif_data = get_notif_data("dap", body.progressId)

                    local message = format_message(body.message, body.percentage)
                    notif_data.notification = vim.notify(message, "info", {
                        title = format_title(body.title, session.config.type),
                        icon = spinner_frames[1],
                        timeout = false,
                        hide_form_history = false,
                    })

                    notif_data.notification.spinner = 1
                    update_spinner("dap", body.progressId)
                end

                dap.listeners.before["event_progressUpdate"]["progress-notifications"] = function(session, body)
                    local notif_data = get_notif_data("dap", body.progressId)
                    notif_data.notification = vim.notify(format_message(body.message, body.percentage), "info", {
                        replace = notif_data.notification,
                        hide_form_history = false,
                    })
                end

                dap.listeners.before["event_progressEnd"]["progress-notifications"] = function(session, body)
                    local notif_data = client_notifs["dap"][body.progressId]
                    notif_data.notification = vim.notify(body.message and format_message(body.message) or "Complete",
                        "info", {
                            icon = "?",
                            replace = notif_data.notification,
                            timeout = 1500,
                        })
                    notif_data.spinner = nil
                end

                require("telescope").load_extension("dap")
            end
        end,
        keys = {
            { "<leader>da", ":RunScriptWithArgs ",                                                                       desc = "Run with Args", },
            {
                '<Leader>dc',
                function()
                    -- if buffer type is go
                    if vim.bo.ft == "go" then
                        vim.cmd("GoDebug")
                    elseif vim.bo.ft == "rust" then
                        vim.cmd.RustLsp('debuggables')
                    else
                        require('dap').continue()
                    end
                end,
                desc = "Run/Continue"
            },
            { '<Leader>db', function() require('dap').toggle_breakpoint() end,                                           desc = "Toggle Breakpoint" },
            { '<Leader>dm', function() require('dap').set_breakpoint(nil, nil, vim.fn.input('Log point message: ')) end, desc = "Log Point" },
            { '<Leader>dR', function() require('dap').repl.toggle() end,                                                 desc = "Toggle Repl" },
            { '<Leader>dr', function() require('dap').run_last() end,                                                    desc = "Rerun" },
            { '<Leader>dK', function() require('dap.ui.widgets').hover() end,                                            desc = "Hover" },
            { '<Leader>dp', function() require('dap.ui.widgets').preview() end,                                          desc = "preview" },
            {
                '<leader>dq',
                function()
                    require('dap').terminate()
                end,
                desc = "Terminate"
            },
            {
                "<leader>ds",
                function()
                    require("hydra").spawn("dap-hydra")
                end,
                desc = "Step Mode",
            },
        },
        lazy = true,
    },
    {
        'theHamsta/nvim-dap-virtual-text',
        dependencies = { 'mfussenegger/nvim-dap' },
        config = true,
        lazy = true,
    },
    {
        "rcarriga/nvim-dap-ui",
        dependencies = { "mfussenegger/nvim-dap", "nvim-neotest/nvim-nio" },
        config = function()
            require("dapui").setup()
            local dap, dapui = require("dap"), require("dapui")
            dap.listeners.before.attach.dapui_config = function()
                dapui.open()
            end
            dap.listeners.before.launch.dapui_config = function()
                dapui.open()
            end
            dap.listeners.before.event_terminated.dapui_config = function()
                dapui.close()
            end
            dap.listeners.before.event_exited.dapui_config = function()
                dapui.close()
            end
            require("plugins.dap.utils").dap_signs_scheme(3)
        end,
        lazy = true,
    },
    { "LiadOz/nvim-dap-repl-highlights" },
    {
        "mfussenegger/nvim-dap-python",
        config = function()
            require("dap-python").setup(vim.fn.stdpath('data') .. '/mason/packages/debugpy/venv/bin/python')
        end,
    },
}
