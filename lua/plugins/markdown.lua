return {
    { "MeanderingProgrammer/render-markdown.nvim", ft = "markdown", opts = {
        latex = { enabled = require("config").enabled("formulas"), converter = "latex2text" },
    } },
}
