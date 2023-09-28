return function()
    local indent_blankline = require("ibl")

    indent_blankline.setup({
        exclude = {
            filetypes = {
                "Outline",
                "help",
                "startify",
                "dashboard",
                "packer",
                "neogitstatus",
                "NvimTree",
                "Trouble",
                "undotree",
                "checkhealth",
            },
        }
    })
end
