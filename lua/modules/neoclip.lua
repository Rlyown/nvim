return function()
    require("neoclip").setup()
    require("telescope").load_extension("neoclip")
    require("telescope").load_extension("macroscope")
end
