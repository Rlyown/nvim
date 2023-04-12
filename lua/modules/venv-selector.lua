return function()
	require("venv-selector").setup({
		-- auto_refresh (default: false). Will automatically start a new search every time VenvSelect is opened.
		-- When its set to false, you can refresh the search manually by pressing ctrl-r. For most users this
		-- is probably the best default setting since it takes time to search and you usually work within the same
		-- directory structure all the time.
		auto_refresh = false,

		-- search_venv_managers (default: true). Will search for Poetry and Pipenv virtual environments in their
		-- default location. If you dont use the default location, you can
		search_venv_managers = true,

		-- search_workspace (default: true). Your lsp has the concept of "workspaces" (project folders), and
		-- with this setting, the plugin will look in those folders for venvs. If you only use venvs located in
		-- project folders, you can set search = false and search_workspace = true.
		search_workspace = true,

		-- path (optional, default not set). Absolute path on the file system where the plugin will look for venvs.
		-- Only set this if your venvs are far away from the code you are working on for some reason. Otherwise its
		-- probably better to let the VenvSelect search for venvs in parent folders (relative to your code). VenvSelect
		-- searchs for your venvs in parent folders relative to what file is open in the current buffer, so you get
		-- different results when searching depending on what file you are looking at.
		-- path = "/home/username/your_venvs",

		-- search (default: true) - Search your computer for virtual environments outside of Poetry and Pipenv.
		-- Used in combination with parents setting to decide how it searches.
		-- You can set this to false to speed up the plugin if your virtual envs are in your workspace, or in Poetry
		-- or Pipenv locations. No need to search if you know where they will be.
		search = true,

		-- parents (default: 2) - Used when search = true only. How many parent directories the plugin will go up
		-- (relative to where your open file is on the file system when you run VenvSelect). Once the parent directory
		-- is found, the plugin will traverse down into all children directories to look for venvs. The higher
		-- you set this number, the slower the plugin will usually be since there is more to search.
		-- You may want to set this to to 0 if you specify a path in the path setting to avoid searching parent
		-- directories.
		parents = 2,

		-- name (default: venv) - The name of the venv directories to look for.
		name = "venv", -- NOTE: You can also use a lua table here for multiple names: {"venv", ".venv"}`

		-- fd_binary_name (default: fd) - The name of the fd binary on your system.
		fd_binary_name = "fd",
	})
end
