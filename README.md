# Nvim

My neovim config is inspired by [LunarVim/Neovim-from-scratch](https://github.com/LunarVim/Neovim-from-scratch) repository.

- ## [Nvim](#nvim)
  - [Install](#install)
  - [Check Health](#check-health)
  - [Keymaps](#keymaps)
  - [Tmux Integration](#tmux-integration)
  - [Latex Integration](#latex-integration)
  - [Test Startup](#test-startup)
  - [Screenshot](#screenshot)
  - [Something Useful](#something-useful)

Configuration tree:

```
.
├── init.lua
├── lua
│   ├── core
│   │   ├── autocommands.lua        # autocommands configuration
│   │   ├── gvariable.lua           # global variable set(the last one be called)
│   │   ├── gfunc.lua               # global function definition
│   │   ├── keymaps.lua             # vim-builtin keymap set
│   │   ├── lazy.lua                # plugin manager
│   │   └── options.lua             # vim option set
│   └── plugins                     # plugins' configuration
├── snippets                        # customizer snippets
├── lazy-lock.json                  # plugins' version control file
├── spell                           # customizer dictionary
└── templates                       # store some template file
```

This configuration mainly focus on programming with `C/Cpp`, `Golang`, `Rust` and `Python`.

## Install

Make sure to remove or move your current `nvim` directory.

**IMPORTANT** Configuration based on neovim v0.11.0.

```bash
$ git clone https://github.com/Rlyown/nvim.git ~/.config/nvim
```

**Requirements**

- [Neovim](https://neovim.io/)
- [Lua](https://www.lua.org/) (for neovim runtime)
- [Node](https://nodejs.org/en/download) (It's optional, if no needs to use mcphub)
- [Yarn](https://classic.yarnpkg.com/lang/en/docs/install) (It's optional, if no needs to preview markdown (in browser))

**Install with following Steps**:

**First Step**. Install the necessary packages, including environments in requirements.

- <details><summary>On MacOS</summary>
  <p>

  **NOTE**: `Homebrew` is not necessary, you can install these packages through the tools provided by your current package-manager manually.

  ```bash
  # Runtime
  $ brew install neovim lua@5.1

  # Packages
  $ brew install ripgrep fd lazygit gnu-sed

  # Optional Packages
  $ brew install bear pngpaste node yarn

  # If you want delete file to trash bin directory by nvim-tree
  $ brew install trash

  ```

  _Nerd Fonts_ is needed to show icons. You can choose your favorite font or find icons in the [https://www.nerdfonts.com](https://www.nerdfonts.com).

  ```bash
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

  ```bash
  $ sudo snap install --classic nvim
  $ sudo apt install lua5.1 ripgrep fd-find lazygit

  $ mkdir -p ~/.local/bin
  $ ln -s $(which fdfind) ~/.local/bin/fd
  $ export PATH=$HOME/.local/bin:$PATH

  # Optional Packages
  $ npm install --global yarn
  $ sudo apt install bear xclip nodejs
  ```

  _Nerd Fonts_ is needed to show icons. You can choose your favorite font or find icons in the [https://www.nerdfonts.com](https://www.nerdfonts.com).

  ```bash
  # Other nice fonts: Hack, Fira Code, Meslo
  $ mkdir -p ~/.local/share/fonts
  $ cd ~/.local/share/fonts && curl -fLo "JetBrains Mono NL Regular Nerd Font Complete.ttf" https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/JetBrainsMono/Ligatures/Regular/JetBrainsMonoNerdFontMono-Regular.ttf
  ```

  _Note_: Don't forget to change your terminal fonts.

  </p>
  </details>

**Optional Step**. To set neovim as default editor, you can add these to `~/.bashrc` or `~/.zshrc`:

```bash
export VISUAL="nvim"
export EDITOR="nvim"
```

**Final Step**. Run `nvim` and wait for the plugins to be installed.

```bash
# First time to run nvim
$ nvim
# Or Synchronize all plugins manually
$ nvim --headless "+Lazy! sync"
# Or Synchronize all plugins with specific version
$ nvim --headless "+Lazy! restore"
```

Congratulations, now start enjoying the powerful neovim!

## Check Health

Run `nvim` and type the following:

```
:checkhealth
```

You can see plugins' diagnose problems with your configuration or environment. Some optional features may not work if you don't install the required packages. But you can still use neovim without these features.

## Keymaps

Leader key is comma(`,`) key. You can just press `<leader>` or `<leader><leader>` to see most keybindings.

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

If you want to use latex, you can install [texshop](https://pages.uoregon.edu/koch/texshop/) and [VimTeX](https://github.com/lervag/vimtex).
VimTex has been installed by default. It only will be activated when executable `latexmk` be detected.
You can install Tex Live with `brew install --cask mactex-no-gui` in MacOS.

For more detail refer to [Setting Up a PDF Reader for Writing LaTeX with Vim](https://www.ejmastnak.com/tutorials/vim-latex/pdf-reader/).

## Test Startup

```bash
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
