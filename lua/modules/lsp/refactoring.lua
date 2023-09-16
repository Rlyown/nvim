return function()
    local refactoring = require("refactoring")

    refactoring.setup()
    require("telescope").load_extension("refactoring")
end
