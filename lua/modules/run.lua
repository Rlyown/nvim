local M = {}
function M.command(argv)
    local terminal = require("modules.terminal")
    local id = vim.v.count1
    terminal.show(id, "horizontal")
    terminal.send(id, table.concat(vim.tbl_map(vim.fn.shellescape, argv), " "))
end
function M.keys()
    if not require("config").enabled("terminal") then return {} end
    local keys = {}
    local function add(lang, lhs, command, label)
        if not require("config").enabled(lang) then return end
        table.insert(keys, { "<localleader>" .. lhs, function()
            local argv = type(command) == "function" and command() or command
            if argv then M.command(argv) end
        end, ft = require("config.capabilities").languages[lang].ft, desc = label })
    end
    add("python", "r", function() return { "python3", vim.api.nvim_buf_get_name(0) } end, "Run Python")
    add("python", "t", { "python3", "-m", "unittest" }, "Test Python")
    add("cpp", "b", { "cmake", "--build", "build" }, "Build C/C++")
    add("cpp", "t", { "ctest", "--test-dir", "build" }, "Test C/C++")
    add("cpp", "r", function()
        vim.ui.input({ prompt = "Executable path: ", completion = "file" }, function(path)
            if path and path ~= "" then M.command({ vim.fn.fnamemodify(path, ":p") }) end
        end)
    end, "Run C/C++")
    add("rust", "b", { "cargo", "build" }, "Build Rust")
    add("shell", "r", function() return { "bash", vim.api.nvim_buf_get_name(0) } end, "Run Script")
    return keys
end
return M
