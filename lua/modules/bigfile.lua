return function()
    local ts_context = {
        name = "TSContext",  -- name
        opts = {
            defer = false,   -- set to true if `disable` should be called on `BufReadPost` and not `BufReadPre`
        },
        disable = function() -- called to disable the feature
            vim.cmd("TSContextDisable")
        end,
    }

    local function disable_pattern(bufnr, filesize_mib)
        -- you can't use `nvim_buf_line_count` because this runs on BufReadPre
        local file_contents = vim.fn.readfile(vim.api.nvim_buf_get_name(bufnr))
        local file_length = #file_contents
        local filetype = vim.filetype.match({ buf = bufnr })
        if file_length > 10000 and filetype == "c" then
            return true
        end
    end

    require("bigfile").config({
        filesize = 2,              -- size of the file in MiB, the plugin round file sizes to the closest MiB
        pattern = disable_pattern, -- autocmd pattern
        features = {               -- features to disable
            "indent_blankline",
            "illuminate",
            "lsp",
            "treesitter",
            "syntax",
            -- "matchparen",
            "vimopts",
            "filetype",
            ts_context,
        },
    })
end
