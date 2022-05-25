-- :help options
-- Or you can find chinese version in website https://yianwillis.github.io/vimcdoc/doc/options.html
local options = {
	backup = false, -- creates a backup file
	clipboard = "unnamedplus", -- allows neovim to access the system clipboard
	cmdheight = 2, -- more space in the neovim command line for displaying messages
	completeopt = { "menuone", "noselect" }, -- mostly just for cmp
	conceallevel = 0, -- so that `` is visible in markdown file
	fileencoding = "utf-8", -- the encoding written to a file
	fileencodings = "utf-8, ucs-bom, gbk, cp936, gb2312, gb18030",
	hlsearch = true, -- highlight all matches on previous search pattern
	ignorecase = true, -- ignore case in search patterns
	mouse = "a", -- allow the mouse to be used in neovim
	pumheight = 10, -- pop up menu height
	showmode = false, -- we don't need to see things like -- INSERT -- anymore
	showtabline = 2, -- always show tabs
	autoindent = true, -- apply the indentation in normal mode
	cindent = true, -- c/cpp indent
	smartcase = true, -- smart case
	smartindent = true, -- make indenting smarter again
	splitbelow = true, -- force all horizontal splits to go below current window
	splitright = true, -- force all vertical splits to go to the right of current window
	swapfile = true, -- creates a swapfile
	termguicolors = true, -- set term gui colors (most terminals support this)
	timeoutlen = 100, -- time to wait for a mapped sequence to complete (in milliseconds)
	undofile = true, -- enable persistent undo
	updatetime = 300, -- faster completion (4000ms default)
	writebackup = false, -- if a file is being edited by another program (or was written to file while editing with another program), it is not allowed to be edited
	expandtab = true, -- convert tabs to spaces
	shiftwidth = 4, -- the number of spaces inserted for each indentation
	tabstop = 4, -- insert 4 spaces for a tab
	cursorline = true, -- highlight the current line
	cursorcolumn = true, -- highlight the current current
	number = true, -- set numbered lines
	relativenumber = false, -- set relative numbered lines
	numberwidth = 4, -- set number column width to 2 {default 4}
	-- Issue: https://github.com/neovim/neovim/issues/16632
	signcolumn = "yes", -- always show the sign column, otherwise it would shift the text each time
	wrap = false, -- display lines as one long line
	scrolloff = 8, -- is one of my fav
	sidescrolloff = 8,
	guifont = "monospace:h17", -- the font used in graphical neovim applications
	autoread = true, -- auto re-read file when modified by third editor
	confirm = true, -- confirm when file is unsaved or read-only
	autowrite = true, -- enable auto write buffer
	autowriteall = true, -- similar to autowrite. It will auto save in some extra events
	foldmethod = "expr",
	foldexpr = "nvim_treesitter#foldexpr()",
	foldenable = false, -- when off, all folds are open
	spell = true, -- enable spell check, spellfile will set in gvariable.lua
	spelllang = "en", -- set language
}

vim.opt.shortmess:append("c") -- enable short message with flag "c"

for k, v in pairs(options) do
	vim.opt[k] = v
end

-- a way to type vimscript string options
vim.cmd("set whichwrap+=<,>,[,],h,l") -- enable this key to go next/before line at line end/head.
vim.cmd([[set iskeyword+=-]]) -- set word to keyword
vim.cmd([[set formatoptions-=cro]]) -- TODO: this doesn't seem to work
vim.cmd([[set cinoptions=g0,:0,N-s,(0]]) -- set c/cpp indent options
vim.cmd([[filetype indent on]]) -- auto indent for different filetype
