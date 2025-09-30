return {
    {
        "iamcco/markdown-preview.nvim",
        enabled = false,
        build = "cd app && yarn install ",
        ft = { "markdown", "Avante" },
        keys = {
            {
                "<leader>lm",
                function()
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

                    local ainput = require("core.gfunc").fn.async_ui_input_wrap()
                    local do_func = function()
                        if vim.bo.ft == "markdown" then
                            vim.cmd("MarkdownPreviewToggle")
                        else
                            ainput(opts, on_confirm)
                        end
                    end

                    return do_func
                end,
                desc = "Markdown Preview"
            },
        }
    }, -- markdown preview plugin

    {
        -- Make sure to set this up properly if you have lazy=true
        'MeanderingProgrammer/render-markdown.nvim',
        opts = {
            file_types = { "markdown", "Avante" },
            latex = { enabled = false }
        },
        ft = { "markdown", "Avante" },
    },
}
