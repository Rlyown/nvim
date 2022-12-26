return function()
	require("esqueleto").setup({
		-- Directory where templates are stored
		directory = vim.fn.stdpath("config") .. "/templates/",

		-- Patterns to match when creating new file
		-- Can be either (i) file names or (ii) file types.
		-- Exact file name match have priority
		patterns = {
			-- file name
			".clang-format",
			".clang-tidy",

			-- file type
			"c",
			"cpp",
		},
	})
end
