local M = {}

local apps = {
    ["Alacritty"] = "Alacritty",
    ["Apple_Terminal"] = "Terminal",
    ["Ghostty"] = "Ghostty",
    ["iTerm.app"] = "iTerm",
    ["iTerm2"] = "iTerm",
    ["kitty"] = "kitty",
    ["WezTerm"] = "WezTerm",
    ["WarpTerminal"] = "Warp",
}

function M.focus_app()
    local configured = vim.g.config_tex_focus_app
    if type(configured) == "string" and configured ~= "" then return configured end
    local detected = apps[vim.env.TERM_PROGRAM]
    if detected then return detected end
    if (vim.env.TERM or ""):lower():find("kitty", 1, true) then return "kitty" end
    return "kitty"
end

function M.focus_terminal()
    if vim.fn.has("mac") == 1 and vim.fn.executable("open") == 1 then
        vim.fn.jobstart({ "open", "-a", M.focus_app() })
    end
end

return M
