# Nvim

My neovim config is inspired by [LunarVim/Neovim-from-scratch](https://github.com/LunarVim/Neovim-from-scratch) repository.

- ## [Nvim](#nvim)
  - [Quick start](#quick-start)
  - [Install](#install)
  - [Check Health](#check-health)
  - [Keymaps](#keymaps)
  - [Plugins](#plugins)
  - [Test Startup](#test-startup)
  - [Screenshot](#screenshot)
  - [Something Useful](#something-useful)

Configuration tree:

```shell
.
├── init.lua
├── lua
│   ├── core
│   │   ├── autocommands.lua    # autocommands configuration
│   │   ├── gvariable.lua       # global variable set(the last one be called)
│   │   ├── gfunc.lua           # global function definition
│   │   ├── keymaps.lua         # vim-builtin keymap set
│   │   └── options.lua         # vim option set
│   ├── modules                 # plugins configuration
│   │   └── configs.lua         # expose setup function
│   └── plugin                  # plugin manager
├── my-snippets                 # customizer snippets
├── plugin                      # compiled plugin file location
├── spell                       # customizer dictionary
└── templates                   # store some template file
```

This configuration mainly focus on programming with `C/Cpp`, `Golang`, `Rust` and `Python`.

## Quick Start

**WARNING**: This installation script may cause some problems, so please read it carefully before running it.

```shell
$ git clone https://github.com/Rlyown/nvim.git ~/.config/nvim
$ cd ~/.config/nvim
$ ./install.sh -i
```

## Install

Make sure to remove or move your current `nvim` directory.

**IMPORTANT** Configuration based on neovim v0.8.1.

```shell
$ git clone https://github.com/Rlyown/nvim.git ~/.config/nvim
```

**Requirements**

- [Rust](https://www.rust-lang.org/tools/install) (for some installations of dependencies)
- [Python3](https://www.python.org/downloads/) with [pip](https://pip.pypa.io/en/stable/installation/) and `venv` (for some plugins)
- [Nodejs](https://github.com/nodesource/distributions) 16 (for copilot.vim and some installations of dependencies)
- [Golang](https://go.dev/doc/install) 1.18 or higher (for some installations of dependencies and developments)
- [lldb_vscode](https://github.com/llvm/llvm-project) (for debug)
- [Yarn](https://classic.yarnpkg.com/lang/en/docs/install) (for markdown preview plugin)

**Install the follow dependencies**:

- <details><summary>On MacOS</summary>
    <p>

  ```shell
  $ brew install neovim ripgrep fd fortune lua sqlite

  # Tools for language support
  $ brew install llvm bear cmake lazygit golang rustup-init node@16 yarn gnu-sed boost exa bat

  $ npm install -g neovim
  $ go install github.com/klauspost/asmfmt/cmd/asmfmt@latest
  $ rustup-init

  # Install neovim python support, and python debugger used by dap
  # If want to deal with multi-version conflicts, you can set
  # the virtualenv python path is set in the lua/core/gvariable.lua
  $ pip3 install pynvim

  # llvm should add to path manually
  # On Apple Sillcon
  $ echo 'export PATH="/opt/homebrew/opt/llvm/bin:$PATH"' >> ~/.zshrc

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

  (Optional) If you want to search program language api from [Dash](https://kapeli.com/dash), you can download it and set the application path in `lua/core/gvariable.lua`.

    </p>
    </details>

- <details><summary>On Ubuntu 20.04</summary>
  <p>

  ```shell
  # Install System denpendence
  $ sudo apt-get install curl git openssl libssl-dev

  # Install Golang
  $ wget https://go.dev/dl/go1.18.linux-amd64.tar.gz
  $ sudo rm -rf /usr/local/go && sudo tar -C /usr/local -xzf go1.18.linux-amd64.tar.gz
  # If you want to make go-bin-path persistent, write it to your ~/.bashrc
  $ export PATH=/usr/local/go/bin:$HOME/go/bin:$PATH

  # Install Rust
  $ curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
  $ source $HOME/.cargo/env

  # add Node source (node version >= 14)
  $ curl -fsSL https://deb.nodesource.com/setup_16.x | sudo -E bash - && sudo apt-get install -y nodejs

  # Install llvm
  $ sudo bash -c "$(wget -O - https://apt.llvm.org/llvm.sh)"

  # Install neovim
  $ cargo install --git https://github.com/MordechaiHadad/bob.git
  $ bob use v0.8.1
  $ echo 'export PATH=$HOME/.local/share/nvim/bin:$PATH' >> ~/.bashrc
  $ source ~/.bashrc

  # Install main packages
  $ sudo apt update
  $ sudo apt install -y neovim ripgrep fd-find fortune-mod lua5.4 exa bat

  # Note that the binary is called fdfind as the binary name fd is already used by another package.
  # Make sure that $HOME/.local/bin is in your $PATH
  $ mkdir -p ~/.local/bin
  $ ln -s $(which fdfind) ~/.local/bin/fd
  $ ln -s /usr/bin/batcat ~/.local/bin/bat

  # Tools for language support
  $ sudo apt-get update
  $ sudo apt install -y bear cmake gdb yarn python3-pip libsqlite3-dev sqlite3 libboost-all-dev python3-dev
  $ sudo npm install -g neovim
  $ go install github.com/jesseduffield/lazygit@latest
  $ go install github.com/klauspost/asmfmt/cmd/asmfmt@latest

  # Mason plugin need venv support
  # change the python version to your default version
  $ PYTHON_VERSION=3.8
  $ sudo apt install python${PYTHON_VERSION}-venv

  # Install neovim python support, and python debugger used by dap
  # If want to deal with multi-version conflicts, you can set
  # the virtualenv python path is set in the lua/core/gvariable.lua
  $ pip3 install pynvim

  # If you want delete file to trash bin directory by nvim-tree
  $ npm install --global trash-cli
  ```

  _Nerd Fonts_ is needed to show icons. You can choose your favorite font or find icons in the [https://www.nerdfonts.com](https://www.nerdfonts.com).

  ```shell
  # Other nice fonts: Hack, Fira Code, Meslo
  $ mkdir -p ~/.local/share/fonts
  $ cd ~/.local/share/fonts && curl -fLo "JetBrains Mono NL Regular Nerd Font Complete.ttf" https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/JetBrainsMono/NoLigatures/Regular/complete/JetBrains%20Mono%20NL%20Regular%20Nerd%20Font%20Complete.ttf
  ```

  _Note_: Don't forget to change your terminal fonts.

  (Optional) If you want to search program language api from [Zeal](https://zealdocs.org/), you can download it and set the binary path in `lua/core/gvariable.lua`.

  ```sh
  # Get zeal, an offline documentation browser
  sudo apt-get install zeal
  ```

  </p>
  </details>

- <details><summary>On CentOS 8</summary>
  <p>

  ```sh
  # Install Golang
  $ wget https://go.dev/dl/go1.18.linux-amd64.tar.gz
  $ sudo rm -rf /usr/local/go && sudo tar -C /usr/local -xzf go1.18.linux-amd64.tar.gz
  # If you want to make go-bin-path persistent, write it to your ~/.bashrc
  $ export PATH=/usr/local/go/bin:$HOME/go/bin:$PATH

  # Install Rust
  $ curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
  $ source $HOME/.cargo/env

  # Add Node source (node version >= 14)
  $ curl -fsSL https://rpm.nodesource.com/setup_16.x | sudo bash -

  # Compile and install llvm
  git clone https://github.com/llvm/llvm-project.git /tmp/llvm-project
  pushd /tmp/llvm-project
  cmake -S llvm -B build -G Ninja \
      -DLLVM_ENABLE_PROJECTS="clang;lldb" \
      -DCMAKE_BUILD_TYPE=Release \
      -DLLVM_ENABLE_RUNTIMES="libcxx;libcxxabi" \
      -DLLVM_TARGETS_TO_BUILD=X86 \
  cmake --build build --target install
  popd

  # Install yarn
  $ curl --silent --location https://dl.yarnpkg.com/rpm/yarn.repo | sudo tee /etc/yum.repos.d/yarn.repo
  $ sudo rpm --import https://dl.yarnpkg.com/rpm/pubkey.gpg
  $ sudo yum install yarn

  # Install Openssl
  $ sudo yum install -y openssl openssl-devel

  # Install neovim
  $ cargo install --git https://github.com/MordechaiHadad/bob.git
  $ bob use v0.8.1
  $ echo 'export PATH=$HOME/.local/share/nvim/bin:$PATH' >> ~/.bashrc
  $ source ~/.bashrc

  # Install ripgrep and fd
  $ cargo install ripgrep fd-find

  # Install fortune-mod
  $ sudo dnf install -y fortune-mod

  # Install compiledb to replace bear
  $ pip3 install compiledb

  # Install Package
  $ sudo dnf install -y sqlite-devel sqlite boost-devel python3-devel bat exa
  $ sudo npm install -g neovim
  $ go install github.com/jesseduffield/lazygit@latest
  $ go install github.com/klauspost/asmfmt/cmd/asmfmt@latest

  # Install neovim python support, and python debugger used by dap
  # If want to deal with multi-version conflicts, you can set
  # the virtualenv python path is set in the lua/core/gvariable.lua
  $ pip3 install pynvim

  # If you want delete file to trash bin directory by nvim-tree
  $ npm install --global trash-cli
  ```

  _Nerd Fonts_ is needed to show icons. You can choose your favorite font or find icons in the [https://www.nerdfonts.com](https://www.nerdfonts.com).

  ```shell
  # Other nice fonts: Hack, Fira Code, Meslo
  $ mkdir -p ~/.local/share/fonts
  $ cd ~/.local/share/fonts && curl -fLo "JetBrains Mono NL Regular Nerd Font Complete.ttf" https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/JetBrainsMono/NoLigatures/Regular/complete/JetBrains%20Mono%20NL%20Regular%20Nerd%20Font%20Complete.ttf
  ```

  _Note_: Don't forget to change your terminal fonts.

  (Optional) If you want to search program language api from [Zeal](https://zealdocs.org/), you can download it and set the binary path in `lua/core/gvariable.lua`.

  ```sh
  # Get zeal, an offline documentation browser
  sudo dnf install zeal
  ```

   </p>
    </details>

**Final Step（Necessary）**. To set neovim as default editor, you can add these to `~/.bashrc` or `~/.zshrc`:

```shell
export VISUAL="nvim"
export EDITOR="nvim"
```

Finally, run `nvim` and wait for the plugins to be installed.

```shell
# First time to run nvim
$ nvim
# Or Synchronize all plugins manually
$ nvim +PackerSync

# cpsm plugin require manual compilation at first time
# cpsm plugin is used for wilder.nvim plugin
$ cd ~/.local/share/nvim/site/pack/packer/start/cpsm && ./install.sh

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

| Plugin          | Mode             | Key                   | Description                                                                                  |
| --------------- | ---------------- | --------------------- | -------------------------------------------------------------------------------------------- |
| Vim-builtin     | normal           | `<C-h>`               | move left window                                                                             |
| Vim-builtin     | normal           | `<C-l>`               | move right window                                                                            |
| Vim-builtin     | normal           | `<C-k>`               | move up window                                                                               |
| Vim-builtin     | normal           | `<C-j>`               | move down window                                                                             |
| Vim-builtin     | normal           | `<C-n>`/`L`           | next buffer                                                                                  |
| Vim-builtin     | normal           | `<C-p>`/`H`           | prev buffer                                                                                  |
| Vim-builtin     | normal           | `<leader><leader>lt`  | copy `.clang-tidy` from template directory to your current location                          |
| Vim-builtin     | normal           | `<leader><leader>lf`  | copy `.clang-format` from template directory to your current location                        |
| Vim-builtin     | normal           | `gt`                  | next tab                                                                                     |
| Vim-builtin     | normal           | `gT`                  | prev tab                                                                                     |
| Vim-builtin     | normal           | `jk`                  | same as `<esc>`                                                                              |
| Vim-builtin     | normal           | `gj`                  | move text down                                                                               |
| Vim-builtin     | normal           | `gk`                  | move text up                                                                                 |
| Vim-builtin     | visual           | `gT`                  | prev tab                                                                                     |
| Vim-builtin     | visual           | `J`                   | move text down                                                                               |
| Vim-builtin     | visual           | `K`                   | move text up                                                                                 |
| Vim-builtin     | visual           | `p`                   | paste and replace                                                                            |
| Vim-builtin     | visual-block     | `J`                   | move text down                                                                               |
| Vim-builtin     | visual-block     | `K`                   | move text up                                                                                 |
| LSP             | normal           | `ga`                  | code action                                                                                  |
| LSP             | normal           | `gD`                  | goto declaration                                                                             |
| LSP             | normal           | `gd`                  | goto definition                                                                              |
| LSP             | normal           | `K`                   | hover                                                                                        |
| LSP             | normal           | `gi`                  | goto implementation                                                                          |
| LSP             | normal           | `gh`                  | signature help                                                                               |
| LSP             | normal           | `gr`                  | references                                                                                   |
| LSP             | normal           | `[d`                  | goto prev                                                                                    |
| LSP             | normal           | `]d`                  | goto declaration                                                                             |
| LSP             | normal           | `gl`                  | show current diagnostic                                                                      |
| LSP             | normal           | `gq`                  | show diagnostic list                                                                         |
| which-key       | normal           | `'`                   | show marks                                                                                   |
| which-key       | normal           | `"`                   | show Registers                                                                               |
| which-key       | insert           | `<C-r>`               | show Registers                                                                               |
| which-key       | map-view         | `<C-u>`               | scroll up                                                                                    |
| which-key       | map-view         | `<C-d>`               | scroll down                                                                                  |
| which-key       | map-view         | `<bs>`                | go up one level                                                                              |
| which-key       | map-view         | `<esc>`               | cancel and close                                                                             |
| nvim-cmp        | cmp-view         | `<C-k>`/`<S-Tab>`     | select prev item                                                                             |
| nvim-cmp        | cmp-view         | `<C-j>`/`<Tab>`       | select next item                                                                             |
| nvim-cmp        | cmp-view         | `<C-b>`               | scroll docs up                                                                               |
| nvim-cmp        | cmp-view         | `<C-f>`               | scroll docs down                                                                             |
| nvim-cmp        | cmp-view         | `<C-space>`           | invoke complete                                                                              |
| nvim-cmp        | cmp-view         | `<C-y>`               | disable                                                                                      |
| nvim-cmp        | cmp-view         | `<C-e>`               | close                                                                                        |
| nvim-cmp        | cmp-view         | `<CR>`                | comfirm                                                                                      |
| luasnip         | snip             | `<Tab>`               | expand or jump next                                                                          |
| luasnip         | snip             | `<S-Tab>`             | jump prev                                                                                    |
| Comment.nvim    | normal           | `gcc`                 | line comment                                                                                 |
| Comment.nvim    | normal           | `gbc`                 | block comment                                                                                |
| Comment.nvim    | visual           | `gc`                  | line comment                                                                                 |
| Comment.nvim    | visual           | `gb`                  | block comment                                                                                |
| nvim-tree       | tree-view        | `?`                   | show help                                                                                    |
| Telescope       | telescope-normal | `?`                   | which key                                                                                    |
| Telescope       | telescope-insert | `<C-_>`               | which key                                                                                    |
| undotree        | undotree-view    | `?`                   | show help                                                                                    |
| vim-surround    | normal           | `cs<old><new>`        | change old surround char to new                                                              |
| vim-surround    | normal           | `cst<new>`            | change full circle to new                                                                    |
| vim-surround    | normal           | `ds<chr>`             | delete surround char                                                                         |
| vim-surround    | normal           | `ys<motion><chr>`     | add surround to a motion                                                                     |
| vim-surround    | visual           | `S<chr>`              | add surround char to visual selection                                                        |
| vim-startuptime | startup-view     | `K`                   | get additional information                                                                   |
| vim-startuptime | startup-view     | `gf`                  | load the corresponding file in a new split                                                   |
| splitjoin       | normal           | `gS`                  | split a one-liner into multiple lines                                                        |
| splitjoin       | normal           | `gJ`                  | (with the cursor on the first line of a block) to join a block into a single-line statement. |
| terminal        | terminal-insert  | `jk`                  | escape terminal insert mode                                                                  |
| terminal        | normal           | `i`                   | go back to terminal insert mode                                                              |
| terminal        | terminal-insert  | `<C-h>`               | move to left window                                                                          |
| terminal        | terminal-insert  | `<C-j>`               | move to down window                                                                          |
| terminal        | terminal-insert  | `<C-k>`               | move to up window                                                                            |
| terminal        | terminal-insert  | `<C-l>`               | move to right window                                                                         |
| trouble.nvim    | quickfix-view    | `q`                   | close the list                                                                               |
| trouble.nvim    | quickfix-view    | `<esc>`               | cancel the preview and get back to your last window / buffer / cursor                        |
| trouble.nvim    | quickfix-view    | `<cr>`/`<tab>`        | jump to the diagnostic or open / close folds                                                 |
| trouble.nvim    | quickfix-view    | `<c-x>`               | open buffer in new split                                                                     |
| trouble.nvim    | quickfix-view    | `<c-v>`               | open buffer in new vsplit                                                                    |
| trouble.nvim    | quickfix-view    | `<c-t>`               | open buffer in new tab                                                                       |
| trouble.nvim    | quickfix-view    | `o`                   | jump to the diagnostic and close the list                                                    |
| trouble.nvim    | quickfix-view    | `m`                   | toggle between "workspace" and "document" diagnostics mode                                   |
| trouble.nvim    | quickfix-view    | `P`                   | toggle auto_preview                                                                          |
| trouble.nvim    | quickfix-view    | `K`                   | opens a small popup with the full multiline message                                          |
| trouble.nvim    | quickfix-view    | `p`                   | preview the diagnostic location                                                              |
| trouble.nvim    | quickfix-view    | `zM`/`zm`             | close all folds                                                                              |
| trouble.nvim    | quickfix-view    | `zR`/`zr`             | open all folds                                                                               |
| trouble.nvim    | quickfix-view    | `zA`/`za`             | toggle fold of current file                                                                  |
| trouble.nvim    | quickfix-view    | `k`                   | preview item                                                                                 |
| trouble.nvim    | quickfix-view    | `j`                   | next item                                                                                    |
| nvim-dap        | Normal           | `<leader>d`           | see all the keybindings about debugger                                                       |
| nvim-dap-ui     | dapui-view       | `<cr>`/`<2-LeftMouse` | expand children                                                                              |
| nvim-dap-ui     | dapui-view       | `o`                   | jump to the location                                                                         |
| nvim-dap-ui     | dapui-view       | `e`                   | edit the value of a variable                                                                 |
| nvim-dap-ui     | dapui-view       | `d`                   | remove the watched expression.                                                               |
| nvim-dap-ui     | dapui-view       | `r`                   | send to REPL                                                                                 |
| nvim-dap-ui     | dapui-view       | `<space>`             | enable/disable the selected breakpoint, or toggle displaying subtle frames                   |
| Nvim-gdb        | buf-normal       | `<space>`             | set/unset breakpoint                                                                         |

If you want to enter a new expression at `DAP Watches`, just enter insert mode and you will see a prompt appear, and press enter to submit. For more details about `dap-ui`, you can click [https://github.com/rcarriga/nvim-dap-ui](https://github.com/rcarriga/nvim-dap-ui).

## Plugins

See details in `lua/plugin/plugins.lua`

## Test Startup

```shell
# in neovim command line
:StartupTime
# or in normal mode
<leader><leader>s
# or just use vim builtin argument on terminal
$ nvim --startuptime startup.log
```

![image-20221020020635341](README/image-20221020020635341.png)

Alternatively, you can use a Go program to measure startup time of vim. [https://github.com/rhysd/vim-startuptime](https://github.com/rhysd/vim-startuptime).

```sh
# Installation
$ go install github.com/rhysd/vim-startuptime@latest
# Usage
$ vim-startuptime -vimpath nvim
```

![image-20221020020927955](README/image-20221020020927955.png)

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
