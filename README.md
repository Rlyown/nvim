# Nvim 

My neovim config is inspired by [LunarVim/Neovim-from-scratch](https://github.com/LunarVim/Neovim-from-scratch) repository.

Configuration tree:
```shell
.
├── init.lua
├── lua
│   ├── core
│   │   ├── autocommands.lua    # autocommands configuration
│   │   ├── gvarible.lua				# global varible set
│   │   ├── keymaps.lua					# vim-builtin keymap set
│   │   └── options.lua					# vim option set
│   ├── modules									# plugins configuration
│   └── plugin									# plugin manager
├── my-snippets									# customizer snippets
└── plugin											# compiled packer location
```

## Install 

Make sure to remove or move your current `nvim` directory.

**IMPORTANT** Configuration based on neovim v0.6.0. 

```shell
git clone https://github.com/Rlyown/nvim.git ~/.config/nvim
```

Install the follow dependencies:

* On MacOS

```shell
brew install ripgrep fd lazygit fortune bear clang-format asmfmt stylua black
```


Then run `nvim` and wait for the plugins to be installed.

## Check Health 

Run `nvim` and type the following:
```
:checkhealth
```

You can see plugins' diagnose problems with your configuration or environment.

## Keymaps 

Leader key is comma(`,`) key.

| Plugin          | Mode             | Key               | Description                                |
| --------------- | ---------------- | ----------------- | ------------------------------------------ |
| Vim-builtin     | normal           | `<C-h>`           | move left window                           |
| Vim-builtin     | normal           | `<C-l>`           | move right window                          |
| Vim-builtin     | normal           | `<C-k>`           | move up window                             |
| Vim-builtin     | normal           | `<C-j>`           | move down window                           |
| Vim-builtin     | normal           | `<C-n>`           | next buffer                                |
| Vim-builtin     | normal           | `<C-p>`           | prev buffer                                |
| Vim-builtin     | normal           | `gt`              | next tab                                   |
| Vim-builtin     | normal           | `gT`              | prev tab                                   |
| Vim-builtin     | normal           | `jk`              | same as `<esc>`                            |
| Vim-builtin     | normal           | `gj`              | move text down                             |
| Vim-builtin     | normal           | `jk`              | move text up                               |
| Vim-builtin     | visual           | `gT`              | prev tab                                   |
| Vim-builtin     | visual           | `J`               | move text down                             |
| Vim-builtin     | visual           | `K`               | move text up                               |
| Vim-builtin     | visual           | `p`               | paste and replace                          |
| Vim-builtin     | visual-block     | `J`               | move text down                             |
| Vim-builtin     | visual-block     | `K`               | move text up                               |
| LSP             | normal           | `gD`              | goto declaration                           |
| LSP             | normal           | `gd`              | goto definition                            |
| LSP             | normal           | `K`               | hover                                      |
| LSP             | normal           | `gi`              | goto implementation                        |
| LSP             | normal           | `<C-k>`           | signature help                             |
| LSP             | normal           | `gr`              | references                                 |
| LSP             | normal           | `[d`              | goto prev                                  |
| LSP             | normal           | `]d`              | goto declaration                           |
| LSP             | normal           | `gl`              | show current diagnostic                    |
| LSP             | normal           | `<leader>q`       | show diagnostic list                       |
| which-key       | normal           | `<leader>`        | show shortcut binding to `<leader>`        |
| which-key       | normal           | `'`               | show marks                                 |
| which-key       | normal           | `"`               | show Registers                             |
| which-key       | insert           | `<C-r>`           | show Registers                             |
| which-key       | map-view         | `<C-u>`           | scroll up                                  |
| which-key       | map-view         | `<C-d>`           | scroll down                                |
| which-key       | map-view         | `<bs>`            | go up one level                            |
| which-key       | map-view         | `<esc>`           | cancel and close                           |
| nvim-cmp        | cmp-view         | `<C-k>`/`<S-Tab>` | select_prev_item                           |
| nvim-cmp        | cmp-view         | `<C-j>`/`<Tab>`   | select_next_item                           |
| nvim-cmp        | cmp-view         | `<C-b>`           | scroll docs up                             |
| nvim-cmp        | cmp-view         | `<C-f>`           | scroll docs down                           |
| nvim-cmp        | cmp-view         | `<C-space>`       | invoke complete                            |
| nvim-cmp        | cmp-view         | `<C-y>`           | disable                                    |
| nvim-cmp        | cmp-view         | `<C-e>`           | close                                      |
| nvim-cmp        | cmp-view         | `<CR>`            | comfirm                                    |
| luasnip         | snip             | `<Tab>`           | expand or jump next                        |
| luasnip         | snip             | `<S-Tab>`         | jump prev                                  |
| Comment.nvim    | normal           | `gcc`             | line comment                               |
| Comment.nvim    | normal           | `gbc`             | block comment                              |
| Comment.nvim    | visual           | `gc`              | line comment                               |
| Comment.nvim    | visual           | `gb`              | line comment                               |
| nvim-tree       | tree-view        | `?`               | show help                                  |
| Project.nvim    | telescope-normal | `f`               | find_project_files                         |
| Project.nvim    | telescope-normal | `b`               | browse_project_files                       |
| Project.nvim    | telescope-normal | `d`               | delete_project                             |
| Project.nvim    | telescope-normal | `s`               | search_in_project_files                    |
| Project.nvim    | telescope-normal | `r`               | recent_project_files                       |
| Project.nvim    | telescope-normal | `w`               | change_working_directory                   |
| Project.nvim    | telescope-insert | `<C-f>`           | find_project_files                         |
| Project.nvim    | telescope-insert | `<C-b>`           | browse_project_files                       |
| Project.nvim    | telescope-insert | `<C-d>`           | delete_project                             |
| Project.nvim    | telescope-insert | `<C-s>`           | search_in_project_files                    |
| Project.nvim    | telescope-insert | `<C-r>`           | recent_project_files                       |
| Project.nvim    | telescope-insert | `<C-w>`           | change_working_directory                   |
| Telescope       | telescope-normal | `?`               | which key                                  |
| Telescope       | telescope-insert | `<C-_>`           | which key                                  |
| undotree        | undotree-view    | `?`               | show help                                  |
| vim-surround    | normal           | `cs<old><new>`    | change old surround char to new            |
| vim-surround    | normal           | `cst<new>`        | change full circle to new                  |
| vim-surround    | normal           | `ds<chr>`         | delete surround char                       |
| vim-surround    | normal           | `ys<motion><chr>` | add surround to a motion                   |
| vim-surround    | visual           | `S<chr>`          | add surround char to visual selection      |
| vim-startuptime | startup-view     | `K`               | get additional information                 |
| vim-startuptime | startup-view     | `gf`              | load the corresponding file in a new split |

## Plugins

**Colorschemes**

| Plugin | Description |
| ------ | ----------- |
| [catppuccin/nvim](https://github.com/catppuccin/nvim) |  |

**Cmp plugins**

| Plugin | Description |
| ------ | ----------- |
| [hrsh7th/nvim-cmp](https://github.com/hrsh7th/nvim-cmp) | The completion plugin |
| [hrsh7th/cmp-buffer](https://github.com/hrsh7th/cmp-buffer) | buffer completions |
| [hrsh7th/cmp-path](https://github.com/hrsh7th/cmp-path) | path completions |
| [hrsh7th/cmp-cmdline](https://github.com/hrsh7th/cmp-cmdline) | cmdline completions |
| [hrsh7th/cmp-nvim-lsp](https://github.com/hrsh7th/cmp-nvim-lsp) | lsp completions |
| [saadparwaiz1/cmp_luasnip](https://github.com/saadparwaiz1/cmp_luasnip) | snippet completions |
| [hrsh7th/cmp-nvim-lua](https://github.com/hrsh7th/cmp-nvim-lua) | neovim's lua api completions |

**Git**

| Plugin | Description |
| ------ | ----------- |
| [lewis6991/gitsigns.nvim](https://github.com/lewis6991/gitsigns.nvim) | show git info in buffer |

**LSP**

| Plugin | Description |
| ------ | ----------- |
| [neovim/nvim-lspconfig](https://github.com/neovim/nvim-lspconfig) | enable LSP |
| [williamboman/nvim-lsp-installer](https://github.com/williamboman/nvim-lsp-installer) | simple to use language server installer |
| [tamago324/nlsp-settings.nvim](https://github.com/tamago324/nlsp-settings.nvim) | language server settings defined in json for |
| [jose-elias-alvarez/null-ls.nvim](https://github.com/jose-elias-alvarez/null-ls.nvim) | for formatters and linters |
| [antoinemadec/FixCursorHold.nvim](https://github.com/antoinemadec/FixCursorHold.nvim) | This is needed to fix lsp doc highlight |
| [ray-x/lsp_signature.nvim](https://github.com/ray-x/lsp_signature.nvim) |  |
| [kosayoda/nvim-lightbulb](https://github.com/kosayoda/nvim-lightbulb) | show lightbulb when code action is available |

**Project**

| Plugin | Description |
| ------ | ----------- |
| [ahmedkhalf/project.nvim](https://github.com/ahmedkhalf/project.nvim) | superior project management |
| [Shatur/neovim-session-manager](https://github.com/Shatur/neovim-session-manager) | A simple wrapper around :mksession |

**Snippets**

| Plugin | Description |
| ------ | ----------- |
| [L3MON4D3/LuaSnip](https://github.com/L3MON4D3/LuaSnip) |  |
| [rafamadriz/friendly-snippets](https://github.com/rafamadriz/friendly-snippets) | a bunch of snippets to use |

**Telescope**

| Plugin | Description |
| ------ | ----------- |
| [nvim-telescope/telescope.nvim](https://github.com/nvim-telescope/telescope.nvim) | Find, Filter, Preview, Pick. |
| [nvim-telescope/telescope-fzf-native.nvim](https://github.com/nvim-telescope/telescope-fzf-native.nvim) | FZF sorter for telescope |
| [nvim-telescope/telescope-ui-select.nvim](https://github.com/nvim-telescope/telescope-ui-select.nvim) | It sets vim.ui.select to telescope |
| [nvim-telescope/telescope-frecency.nvim](https://github.com/nvim-telescope/telescope-frecency.nvim) | offers intelligent prioritization |

**Terminal**

| Plugin | Description |
| ------ | ----------- |
| [akinsho/toggleterm.nvim](https://github.com/akinsho/toggleterm.nvim) | easily manage multiple terminal windows |

**Tools**

| Plugin | Description |
| ------ | ----------- |
| [wbthomason/packer.nvim](https://github.com/wbthomason/packer.nvim) | Have packer manage itself |
| [nvim-lua/popup.nvim](https://github.com/nvim-lua/popup.nvim) | An implementation of the Popup API from vim in Neovim |
| [nvim-lua/plenary.nvim](https://github.com/nvim-lua/plenary.nvim) | Useful lua functions used ny lots of plugins |
| [windwp/nvim-autopairs](https://github.com/windwp/nvim-autopairs) | Autopairs, integrates with both cmp and treesitter |
| [numToStr/Comment.nvim](https://github.com/numToStr/Comment.nvim) | Easily comment stuff |
| [moll/vim-bbye](https://github.com/moll/vim-bbye) | delete buffers (close files) without closing your windows or messing up your layout |
| [lewis6991/impatient.nvim](https://github.com/lewis6991/impatient.nvim) | Improve startup time for Neovim |
| [folke/which-key.nvim](https://github.com/folke/which-key.nvim) | Create key bindings that stick. |
| [tpope/vim-repeat](https://github.com/tpope/vim-repeat) | enable repeating supported plugin maps with "." |
| [tpope/vim-surround](https://github.com/tpope/vim-surround) | all about "surroundings": parentheses, brackets, quotes, XML tags, and more |
| [michaelb/sniprun](https://github.com/michaelb/sniprun) | run lines/blocs of code |
| [nathom/filetype.nvim](https://github.com/nathom/filetype.nvim) | A faster version of filetype.vim |
| [dstein64/vim-startuptime](https://github.com/dstein64/vim-startuptime) | A Vim plugin for profiling Vim's startup time |
| [Pocco81/AutoSave.nvim](https://github.com/Pocco81/AutoSave.nvim) | enable autosave. |

**Important**: Undo/Redo can cause autosave. Sometimes these will move cursor and then do action, but move cursor will cause autosave too. So I set autosave delay time big enough.

**Treesitter**

| Plugin | Description |
| ------ | ----------- |
| [nvim-treesitter/nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter) |  |
| [JoosepAlviste/nvim-ts-context-commentstring](https://github.com/JoosepAlviste/nvim-ts-context-commentstring) |  |
| [romgrk/nvim-treesitter-context](https://github.com/romgrk/nvim-treesitter-context) | show code context |
| [nvim-treesitter/playground](https://github.com/nvim-treesitter/playground) | View treesitter information directly in Neovim |
| [stevearc/aerial.nvim](https://github.com/stevearc/aerial.nvim) | code outline window |

**UI**

| Plugin | Description |
| ------ | ----------- |
| [psliwka/vim-smoothie](https://github.com/psliwka/vim-smoothie) | page scroll smoothly |
| [kyazdani42/nvim-web-devicons](https://github.com/kyazdani42/nvim-web-devicons) | a lua fork from vim-devicons |
| [kyazdani42/nvim-tree.lua](https://github.com/kyazdani42/nvim-tree.lua) | file explorer |
| [akinsho/bufferline.nvim](https://github.com/akinsho/bufferline.nvim) | buffer line plugin |
| [nvim-lualine/lualine.nvim](https://github.com/nvim-lualine/lualine.nvim) | statusline plugin |
| [goolord/alpha-nvim](https://github.com/goolord/alpha-nvim) | a lua powered greeter |
| [SmiteshP/nvim-gps](https://github.com/SmiteshP/nvim-gps) | Simple statusline component that show code context |
| [mbbill/undotree](https://github.com/mbbill/undotree) | undo history visualizer |
| [norcalli/nvim-colorizer.lua](https://github.com/norcalli/nvim-colorizer.lua) | The fastest Neovim colorizer. |

## Test Startup



```shell
# in neovim command line
:StartupTime
# or in normal mode
<leader><leader>s
```



## Something Useful

* [Everything you need to know to configure neovim using lua](https://vonheikemen.github.io/devlog/tools/configuring-neovim-using-lua/)

* [Getting started using Lua in Neovim](https://github.com/nanotee/nvim-lua-guide)
