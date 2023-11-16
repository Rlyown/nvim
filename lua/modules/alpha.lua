return function()
    local alpha = require("alpha")

    local dashboard = require("alpha.themes.dashboard")
    local get_banner = require("modules.alpha_banner_info").get_random_banner

    dashboard.section.header.val = get_banner()
    dashboard.section.buttons.val = {
        dashboard.button("a", "  Agenda", ":Neorg workspace work<CR>"),
        dashboard.button("f", "  Find file", ":lua require('telescope.builtin').find_files()<CR>"),
        dashboard.button("e", "  New file", ":ene <BAR> startinsert <CR>"),
        dashboard.button("s", "  Select Session", ":SessionManager load_session<CR>"),
        dashboard.button("r", "  Recently used files", ":lua require('telescope.builtin').oldfiles() <CR>"),
        dashboard.button("t", "  Find text", ":lua require('telescope.builtin').live_grep() <CR>"),
        dashboard.button("c", "  Configuration", ":cd ~/.config/nvim | e init.lua <CR>"),
        dashboard.button("p", "  Plugins", ":Lazy profile<cr>"),
        dashboard.button("q", "  Quit Neovim", ":qa<CR>"),
    }

    local function footer()
        -- NOTE: requires the fortune-mod package to work
        local handle = io.popen("fortune")
        if not handle then
            return [[The Second Law of Thermodynamics:
	If you think things are in a mess now, just wait!
		-- Jim Warner]]
        end
        local fortune = handle:read("*a")
        handle:close()
        return fortune
    end

    dashboard.section.footer.val = footer()

    dashboard.section.footer.opts.hl = "Type"
    dashboard.section.header.opts.hl = "Include"
    dashboard.section.buttons.opts.hl = "Keyword"

    dashboard.opts.opts.noautocmd = true
    -- vim.cmd([[autocmd User AlphaReady echo 'ready']])
    alpha.setup(dashboard.opts)
end
