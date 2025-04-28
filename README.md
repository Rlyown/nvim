# Nvim

My neovim config is inspired by [LunarVim/Neovim-from-scratch](https://github.com/LunarVim/Neovim-from-scratch) repository.

- ## [Nvim](#nvim)
  - [Quick start](#quick-start)
  - [Install](#install)
  - [Check Health](#check-health)
  - [Keymaps](#keymaps)
  - [Plugins](#plugins)
  - [Tmux Integration](#tmux-integration)
  - [Latex Integration](#latex-integration)
  - [Different Input Method](#Different-Input-Method)
  - [Test Startup](#test-startup)
  - [Screenshot](#screenshot)
  - [Something Useful](#something-useful)

Configuration tree:

```shell
.
├── init.lua
├── lua
│   ├── core
│   │   ├── autocommands.lua        # autocommands configuration
│   │   ├── gvariable.lua           # global variable set(the last one be called)
│   │   ├── gfunc.lua               # global function definition
│   │   ├── keymaps.lua             # vim-builtin keymap set
│   │   └── options.lua             # vim option set
│   ├── modules                     # plugins configuration
│   │   └── configs.lua             # expose setup function
│   └── plugin                      # plugin manager
├── snippets                        # customizer snippets
├── plugin                          # compiled plugin file location
│   └── lazy-lock.json              # plugins' version control file
├── spell                           # customizer dictionary
└── templates                       # store some template file
```

This configuration mainly focus on programming with `C/Cpp`, `Golang`, `Rust` and `Python`.

## Quick Start

**WARNING**: The script uses the `Homebrew` to install dependencies. Please read it carefully before running it.

```shell
$ git clone https://github.com/Rlyown/nvim.git ~/.config/nvim
$ cd ~/.config/nvim
$ ./install.sh -i
$ nvim
```

## Install

Make sure to remove or move your current `nvim` directory.

**IMPORTANT** Configuration based on neovim v0.11.0.

```shell
$ git clone https://github.com/Rlyown/nvim.git ~/.config/nvim
```

**Requirements**

- [Neovim](https://neovim.io/)
- [Lua](https://www.lua.org/) (for neovim runtime)
- [Rust](https://www.rust-lang.org/tools/install) (for some installations of dependencies)
- [Python3](https://www.python.org/downloads/) with [pip](https://pip.pypa.io/en/stable/installation/) and `venv` (for some plugins)
- [Yarn](https://classic.yarnpkg.com/lang/en/docs/install) (for markdown preview plugin)
- [Golang](https://go.dev/doc/install) 1.18 or higher (for some installations of dependencies and developments)
- [Homebrew](https://brew.sh/) (for packages' installation in MacOS or Linux, **but only for single user**)

**Install with following Steps**:

**First Step**. Install the necessary packages, including environments in requirements.

- <details><summary>On MacOS</summary>
  <p>

  **NOTE**: `Homebrew` is not necessary, you can install these packages through the tools provided by your current package-manager manually.

  ```shell
  # Runtime
  $ brew install neovim go python3 node@16 rust lua yarn npm

  # Packages
  $ brew install ripgrep fd lazygit gnu-sed

  # Optional Packages
  $ brew install fortune bear llvm pngpaste
  $ npm install -g tree-sitter-cli

  # If you want delete file to trash bin directory by nvim-tree
  $ brew install trash

  ```

  _Nerd Fonts_ is needed to show icons. You can choose your favorite font or find icons in the [https://www.nerdfonts.com](https://www.nerdfonts.com).

  ```shell
  # Other nice fonts: Hack, Fira Code, Meslo
  $ brew tap homebrew/cask-fonts
  $ brew install --cask font-jetbrains-mono-nerd-font
  ```

  _Note_: Don't forget to change your terminal fonts.

  </p>
  </details>

- <details><summary>On Ubuntu</summary>
  <p>

  **NOTE**:

  ```shell
  $ sudo snap install --classic nvim go rustup node
  $ sudo apt install lua5.3 ripgrep fd-find

  $ mkdir -p ~/.local/bin
  $ ln -s $(which fdfind) ~/.local/bin/fd
  $ export PATH=$HOME/.local/bin:$PATH

  # Make sure `~/go/bin` in your $PATH
  $ go install github.com/jesseduffield/lazygit@latest

  $ cargo install exa bat tree-sitter-cli

  # Optional Packages
  $ sudo apt install fortune bear xclip
  ```

  _Nerd Fonts_ is needed to show icons. You can choose your favorite font or find icons in the [https://www.nerdfonts.com](https://www.nerdfonts.com).

  ```shell
  # Other nice fonts: Hack, Fira Code, Meslo
  $ mkdir -p ~/.local/share/fonts
  $ cd ~/.local/share/fonts && curl -fLo "JetBrains Mono NL Regular Nerd Font Complete.ttf" https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/JetBrainsMono/Ligatures/Regular/JetBrainsMonoNerdFontMono-Regular.ttf
  ```

  _Note_: Don't forget to change your terminal fonts.

  </p>
  </details>

**Optional Step**. To set neovim as default editor, you can add these to `~/.bashrc` or `~/.zshrc`:

```shell
export VISUAL="nvim"
export EDITOR="nvim"
```

**Final Step**. Run `nvim` and wait for the plugins to be installed.

```shell
# First time to run nvim
$ nvim
# Or Synchronize all plugins manually
$ nvim --headless "+Lazy! sync" +qa
# Or Synchronize all plugins with specific version
$ nvim --headless "+Lazy! restore" +qa

# create neorg default directory
$ mkdir -p ~/.local/state/nvim/neorg-notes/work
```

Congratulations, now start enjoying the powerful neovim!

## Check Health

Run `nvim` and type the following:

```
:checkhealth
```

You can see plugins' diagnose problems with your configuration or environment.

## Keymaps

Leader key is comma(`,`) key. You can just press `<leader>` or `<leader><leader>` to see most keybindings.

## Plugins

See details in `lua/plugin/plugins.lua`

## Tmux Integration

If you want to have a better experience with tmux, you can add the following bindings to your `~/.tmux.conf`.

```
# To enable cycle-free navigation beyond nvim
is_vim="ps -o state= -o comm= -t '#{pane_tty}' | grep -iqE '^[^TXZ ]+ +(\\S+\\/)?g?(view|n?vim?x?)(diff)?$'"

bind-key -n 'C-h' if-shell "$is_vim" 'send-keys C-h' { if -F '#{pane_at_left}' '' 'select-pane -L' }
bind-key -n 'C-j' if-shell "$is_vim" 'send-keys C-j' { if -F '#{pane_at_bottom}' '' 'select-pane -D' }
bind-key -n 'C-k' if-shell "$is_vim" 'send-keys C-k' { if -F '#{pane_at_top}' '' 'select-pane -U' }
bind-key -n 'C-l' if-shell "$is_vim" 'send-keys C-l' { if -F '#{pane_at_right}' '' 'select-pane -R' }

bind-key -T copy-mode-vi 'C-h' if -F '#{pane_at_left}' '' 'select-pane -L'
bind-key -T copy-mode-vi 'C-j' if -F '#{pane_at_bottom}' '' 'select-pane -D'
bind-key -T copy-mode-vi 'C-k' if -F '#{pane_at_top}' '' 'select-pane -U'
bind-key -T copy-mode-vi 'C-l' if -F '#{pane_at_right}' '' 'select-pane -R'

# To resize the window
is_vim="ps -o state= -o comm= -t '#{pane_tty}' | grep -iqE '^[^TXZ ]+ +(\\S+\\/)?g?(view|n?vim?x?)(diff)?$'"

bind -n 'M-h' if-shell "$is_vim" 'send-keys M-h' 'resize-pane -L 1'
bind -n 'M-j' if-shell "$is_vim" 'send-keys M-j' 'resize-pane -D 1'
bind -n 'M-k' if-shell "$is_vim" 'send-keys M-k' 'resize-pane -U 1'
bind -n 'M-l' if-shell "$is_vim" 'send-keys M-l' 'resize-pane -R 1'

bind-key -T copy-mode-vi M-h resize-pane -L 1
bind-key -T copy-mode-vi M-j resize-pane -D 1
bind-key -T copy-mode-vi M-k resize-pane -U 1
bind-key -T copy-mode-vi M-l resize-pane -R 1
```

For more detail refer to [usage of tmux.nvim](https://github.com/aserowy/tmux.nvim#usage).

## Latex Integration

If you want to use latex, you can install [Skim](https://skim-app.sourceforge.io/) and [VimTeX](https://github.com/lervag/vimtex).
VimTex has been installed by default. It only will be activated when executable `latexmk` be detected.
You can install Skim with `brew install --cask skim`, and install Tex Live with `brew install --cask mactex-no-gui` in MacOS.

For more detail refer to [Setting Up a PDF Reader for Writing LaTeX with Vim](https://www.ejmastnak.com/tutorials/vim-latex/pdf-reader/).

## Different Input Method

In my configuration, [ZFVimIM](https://github.com/ZSaberLv0/ZFVimIM) has been installed by default to support Chinese. You can just press `;;` to switch between English and Chinese without changing input method on your computer or remote server.

For more detail or other languages refer to [ZFVimIM](https://github.com/ZSaberLv0/ZFVimIM).

## Test Startup

```shell
# in neovim command line
:StartupTime
# or in normal mode
<leader><leader>s
# or just use vim builtin argument on terminal
$ nvim --startuptime startup.log
```

![image-20230302162309185](README/image-20230302162309185.png)

Alternatively, you can use a Go program to measure startup time of vim. [https://github.com/rhysd/vim-startuptime](https://github.com/rhysd/vim-startuptime).

```sh
# Installation
$ go install github.com/rhysd/vim-startuptime@latest
# Usage
$ vim-startuptime -vimpath nvim
```

![image-20230302162427963](README/image-20230302162427963.png)

## Screenshot

**Keybindings Popup**

![image-20220421232030314](README/image-20220421232030314.png)

**Completion**

![image-20220404010415841](README/image-20220404010415841.png)

**DAP Debugger**

![image-20220424182706493](README/image-20220424182706493.png)

## Something Useful

- [Everything you need to know to configure neovim using lua](https://vonheikemen.github.io/devlog/tools/configuring-neovim-using-lua/)

- [Getting started using Lua in Neovim](https://github.com/nanotee/nvim-lua-guide)

- [Snippets in Visual Studio Code](https://code.visualstudio.com/docs/editor/userdefinedsnippets)
