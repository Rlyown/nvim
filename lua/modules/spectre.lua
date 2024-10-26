return function()
    require("spectre").setup({
        live_update = true,
        use_trouble_qf = true,
        mapping = {
            ['tab'] = {
                map = '<leader>S[',
                cmd = "<cmd>lua require('spectre').tab()<cr>",
                desc = 'next query'
            },
            ['shift-tab'] = {
                map = '<leader>S]',
                cmd = "<cmd>lua require('spectre').tab_shift()<cr>",
                desc = 'previous query'
            },
            ['toggle_line'] = {
                map = "<leader>SD",
                cmd = "<cmd>lua require('spectre').toggle_line()<CR>",
                desc = "toggle item"
            },
            ['enter_file'] = {
                map = "<cr>",
                cmd = "<cmd>lua require('spectre.actions').select_entry()<CR>",
                desc = "open file"
            },
            ['send_to_qf'] = {
                map = "<leader>Sq",
                cmd = "<cmd>lua require('spectre.actions').send_to_qf()<CR>",
                desc = "send all items to quickfix"
            },
            ['replace_cmd'] = {
                map = "<leader>Sc",
                cmd = "<cmd>lua require('spectre.actions').replace_cmd()<CR>",
                desc = "input replace command"
            },
            ['show_option_menu'] = {
                map = "<leader>So",
                cmd = "<cmd>lua require('spectre').show_options()<CR>",
                desc = "show options"
            },
            ['run_current_replace'] = {
                map = "<leader>SL",
                cmd = "<cmd>lua require('spectre.actions').run_current_replace()<CR>",
                desc = "replace current line"
            },
            ['run_replace'] = {
                map = "<leader>SR",
                cmd = "<cmd>lua require('spectre.actions').run_replace()<CR>",
                desc = "replace all"
            },
            ['change_view_mode'] = {
                map = "<leader>Sv",
                cmd = "<cmd>lua require('spectre').change_view()<CR>",
                desc = "change result view mode"
            },
            ['change_replace_sed'] = {
                map = "<leader>Sts",
                cmd = "<cmd>lua require('spectre').change_engine_replace('sed')<CR>",
                desc = "use sed to replace"
            },
            ['change_replace_oxi'] = {
                map = "<leader>Sto",
                cmd = "<cmd>lua require('spectre').change_engine_replace('oxi')<CR>",
                desc = "use oxi to replace"
            },
            ['toggle_live_update'] = {
                map = "<leader>Stu",
                cmd = "<cmd>lua require('spectre').toggle_live_update()<CR>",
                desc = "update when vim writes to file"
            },
            ['toggle_ignore_case'] = {
                map = "<leader>Sti",
                cmd = "<cmd>lua require('spectre').change_options('ignore-case')<CR>",
                desc = "toggle ignore case"
            },
            ['toggle_ignore_hidden'] = {
                map = "<leader>Sth",
                cmd = "<cmd>lua require('spectre').change_options('hidden')<CR>",
                desc = "toggle search hidden"
            },
            ['resume_last_search'] = {
                map = "<leader>Sl",
                cmd = "<cmd>lua require('spectre').resume_last_search()<CR>",
                desc = "repeat last search"
            },
            ['select_template'] = {
                map = '<leader>Sp',
                cmd = "<cmd>lua require('spectre.actions').select_template()<CR>",
                desc = 'pick template',
            },
            ['delete_line'] = {
                map = '<leader>Sd',
                cmd = "<cmd>lua require('spectre.actions').run_delete_line()<CR>",
                desc = 'delete line',
            }
            -- you can put your mapping here it only use normal mode
        },
    })
end
