#!/bin/bash

set -e

##############################
# Variables
##############################
PLATFORM=$(uname -s | tr '[:upper:]' '[:lower:]')
ARCH=$(uname -m)
OS=
HOMEBREW=
CARGO=
GOLANG=
NODE=
PYTHON=
PIP=
LLVM=
CUR_SHELL_CONFIG=
NEOVIM_VERSION=0.8.0

##############################
# Utils
##############################
function echo_green() {
	echo -e "\033[32m$1\033[0m"
}

function errcho() {
	>&2 echo -e "\033[31m$1\033[0m"
}

function read_input() {
	local input
	read -p "$(echo -n -e "\033[33m$1\033[0m")" -r input
	input=${input:-$2}
	echo "$input"
}

##############################
# Helper
##############################
function help() {
	echo "Usage: $0 [options]"
	echo "    -h     Show this help"
	echo "    -i     Install. "
    echo "             Linux: Language dependencies will try to be installed in \$HOME/.local, if not found in \$PATH"
    echo "             MacOS: Homebrew will be used to install dependencies"
	echo "    -u     Update configuration files"
	echo "    -c     Container mode."
    echo "    -y     Assume yes to all prompts"
}

##############################
# Checks
##############################
function check_os() {
	if [ "${PLATFORM}" == "darwin" ]; then
		OS="mac"
	elif [ "${PLATFORM}" == "linux" ]; then
        if [[ $CONTAINER == 1 ]]; then
            local version_file=/etc/issue
        else
            local version_file=/proc/version
        fi

        local result=$(grep -o -E 'Red Hat|Ubuntu' ${version_file} | uniq | head -n 1)
        case $result in
            "Red Hat")
                OS="rhel"
                ;;
            "Ubuntu")
                OS="ubuntu"
                ;;
            *)
                errcho "Unsupported OS"
                exit 1
                ;;
        esac
	else
		errcho "Your platform (${PLATFORM}) is not supported."
        exit 1
	fi
}

function check_shell() {
    local CUR_SHELL=$(echo $SHELL | xargs basename)
    CUR_SHELL_CONFIG="$HOME/.${CUR_SHELL}rc"
}

function check_homebrew() {
    if [ "$OS" == "mac" ]; then
        if ! command -v brew >/dev/null 2>&1; then
            errcho "Homebrew is not installed"

            if [[ $ACCEPT -eq 1 ]]; then
                install_homebrew
            else
                while true; do
                    local input=$(read_input "Do you want to local install homebrew now? [y/n]: " "n")

                    case $input in
                    [yY][eE][sS] | [yY])
                        install_homebrew
                        HOMEBREW=$(command -v brew)
                        break
                        ;;

                    [nN][oO] | [nN])
                        exit 1
                        ;;
                    *)
                        errcho "Invalid input..."
                        ;;
                    esac
                done
            fi
        else
            HOMEBREW=$(command -v brew)
        fi
    fi
}

function check_cargo() {
    if ! command -v cargo &> /dev/null; then
        errcho "cargo is not installed! Please install rust first."

        if [[ $ACCEPT -eq 1 ]]; then
            install_rust
        else
            while true; do
                local input=$(read_input "Do you want to local install rust now? [y/n]: " "n")

                case $input in
                [yY][eE][sS] | [yY])
                    install_rust
                    CARGO=$(command -v cargo)
                    break
                    ;;

                [nN][oO] | [nN])
                    exit 1
                    ;;
                *)
                    errcho "Invalid input..."
                    ;;
                esac
            done
        fi
    else
        CARGO=$(command -v cargo)
    fi
}

function check_go() {
    if ! command -v go &> /dev/null; then
        errcho "go is not installed! Please install go first."

        if [[ $ACCEPT -eq 1 ]]; then
            install_go
        else
            while true; do
                local input=$(read_input "Do you want to local install go now? [y/n]: " "n")

                case $input in
                [yY][eE][sS] | [yY])
                    install_go
                    GOLANG=$(command -v go)
                    break
                    ;;

                [nN][oO] | [nN])
                    exit 1
                    ;;
                *)
                    errcho "Invalid input..."
                    ;;
                esac
            done
        fi
    else
        GOLANG=$(command -v go)
    fi
}

function check_node() {
    if ! command -v node &> /dev/null; then
        errcho "node is not installed! Please install node first."

        if [[ $ACCEPT -eq 1 ]];then
            install_node
        else
            while true; do
                local input=$(read_input "Do you want to local install node now? [y/n]: " "n")

                case $input in
                [yY][eE][sS] | [yY])
                    install_node
                    NODE=$(command -v node)
                    break
                    ;;

                [nN][oO] | [nN])
                    exit 1
                    ;;
                *)
                    errcho "Invalid input..."
                    ;;
                esac
            done
        fi
    elif [[ ${$(node -v)%%.*} -gt 16 ]]; then
        errcho "node version is too high! Node 16.x is required for copilot!"
        
        if [[ $ACCEPT -eq 1 ]]; then
            install_node16 0
        else
            while true; do
                local input=$(read_input "Do you want to install node 16.x now? [y/n]: " "n")

                case $input in
                [yY][eE][sS] | [yY])
                    install_node16 0
                    NODE=$(command -v node)
                    break
                    ;;

                [nN][oO] | [nN])
                    exit 1
                    ;;
                *)
                    errcho "Invalid input..."
                    ;;
                esac
            done
        fi
    else
        NODE=$(command -v node)
    fi
}

function check_python() {
    if ! command -v python3 &> /dev/null; then
        errcho "python is not installed! Please install python first."

        if [[ $ACCEPT -eq 1 ]]; then
            install_python
        else
            while true; do
                local input=$(read_input "Do you want to local install python now? [y/n]: " "n")

                case $input in
                [yY][eE][sS] | [yY])
                    install_python
                    PYTHON=$(command -v python3)
                    break
                    ;;

                [nN][oO] | [nN])
                    exit 1
                    ;;
                *)
                    errcho "Invalid input..."
                    ;;
                esac
            done
        fi
    else
        PYTHON=$(command -v python3)
    fi
}

function check_pip() {
    if ! command -v pip3 &> /dev/null; then
        errcho "pip is not installed! Please install pip first."

        if [[ $ACCEPT -eq 1 ]]; then
            install_pip
        else
            while true; do
                local input=$(read_input "Do you want to local install pip now? [y/n]: " "n")

                case $input in
                [yY][eE][sS] | [yY])
                    install_pip
                    PIP=$(command -v pip3)
                    break
                    ;;

                [nN][oO] | [nN])
                    exit 1
                    ;;
                *)
                    errcho "Invalid input..."
                    ;;
                esac
            done
        fi
    else
        PIP=$(command -v pip3)
    fi
}

function check_llvm() {
    if ! command -v llvm-config &> /dev/null; then
        errcho "llvm is not installed! Please install llvm first."

        if [[ $ACCEPT -eq 1 ]]; then
            install_llvm
        else
            while true; do
                local input=$(read_input "Do you want to local install llvm now? [y/n]: " "n")

                case $input in
                [yY][eE][sS] | [yY])
                    install_llvm
                    LLVM=$(command -v llvm-config)
                    break
                    ;;

                [nN][oO] | [nN])
                    exit 1
                    ;;
                *)
                    errcho "Invalid input..."
                    ;;
                esac
            done
        fi
    else
        LLVM=$(command -v llvm-config)
    fi
}

function show_info() {
    echo_green "Current configuration:"
    echo_green "* OS: $OS"
    echo_green "* Shell: $CUR_SHELL"
    echo_green "* Homebrew: $HOMEBREW"
    echo_green "* Cargo: $CARGO"
    echo_green "* Golang: $GOLANG"
    echo_green "* Node: $NODE"
    echo_green "* Python3: $PYTHON"
    echo_green "* Shell config: $CUR_SHELL_CONFIG"
    echo_green "* Pip3: $PIP"
    echo_green "* LLVM: $LLVM"
}

function check_all() {
    check_os
    check_shell
    check_homebrew
    check_cargo
    check_go
    check_node
    check_python
    show_info

}

##############################
# Update
##############################
function neovim_package_update() {
	echo_green "Synchronise all the plugins..."
    nvim --headless -c 'autocmd User PackerComplete quitall' -c 'PackerSync'
}

function update() {
	echo_green "Updating..."
	git pull origin main:main
	if [[ $? -ne 0 ]]; then
		errcho "Pull remote main error\!"

        if [[ $ACCEPT -eq 1 ]]; then
            echo_green "Force update..."
            errcho "Warning: Force update will discard all local changes!"
            git checkout main
            git reset --hard
            git fetch origin main
            git merge
        else
            while true; do
                local input=$(read_input "Do you want to force pull, and discard local changes? [Y/n]: ")

                case $input in
                [yY][eE][sS] | [yY])
                    git checkout main
                    git reset --hard
                    git fetch origin main
                    git merge
                    if [[ $? -ne 0 ]]; then
                        errcho "git merge remote main failed\!"
                        exit 1
                    fi
                    break
                    ;;

                [nN][oO] | [nN])
                    exit 0
                    ;;

                *)
                    errcho "Invalid input..."
                    ;;
                esac
            done
        fi
	fi

}

##############################
# Installation Common
##############################
function install_homebrew() {
    echo_green "Installing homebrew..."

    export HOMEBREW_BREW_GIT_REMOTE="https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/brew.git"
    export HOMEBREW_CORE_GIT_REMOTE="https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/homebrew-core.git"
    export HOMEBREW_BOTTLE_DOMAIN="https://mirrors.tuna.tsinghua.edu.cn/homebrew-bottles"
    echo "export HOMEBREW_BREW_GIT_REMOTE=\"https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/brew.git\"" >> $CUR_SHELL_CONFIG
    echo "export HOMEBREW_CORE_GIT_REMOTE=\"https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/homebrew-core.git\"" >> $CUR_SHELL_CONFIG
    echo "export HOMEBREW_BOTTLE_DOMAIN=\"https://mirrors.tuna.tsinghua.edu.cn/homebrew-bottles\"" >> $CUR_SHELL_CONFIG

    git clone --depth=1 https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/install.git brew-install
    /bin/bash brew-install/install.sh
    rm -rf brew-install

    if [[ $ARCH == "arm64" ]]; then
        echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> $CUR_SHELL_CONFIG
    fi
}

function install_rust() {
    echo_green "Installing rust..."
    if [[ $ACCEPT -eq 1 ]]; then
        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    else
        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
    fi
    source $HOME/.cargo/env

    echo_green "Successfully installed rust to $HOME/.cargo !"
}

function install_go() {
    echo_green "Installing golang..."

    if [[ "$OS" == "mac" ]]; then
        brew install go
    else
        if [[ $ARCH == "x86_64" ]]; then
            local arch="amd64"
        elif [[ $ARCH == "aarch64" ]]; then
            local arch="arm64"
        fi

        local GO_VERSION="1.19.3"
        local GO_TAR="go${GO_VERSION}.${PLATFORM}-${arch}.tar.gz"
        local GO_URL="https://golang.org/dl/$GO_TAR"
        local GO_DIR="go"

        wget -O $GO_TAR $GO_URL
        tar -C $HOME/.local -xzf $GO_TAR
        rm -rf $GO_TAR

        mkdir -p $HOME/go/bin
        echo_green "Set GOPATH to $HOME/go in $CUR_SHELL_CONFIG"
        echo 'export GOPATH=$HOME/go' >> $CUR_SHELL_CONFIG
        echo 'export PATH=$HOME/.local/'$GO_DIR'/bin:$GOPATH/bin:$PATH' >> $CUR_SHELL_CONFIG

        export GOPATH=$HOME/go
        export PATH=$HOME/.local/$GO_DIR/bin:$GOPATH/bin:$PATH

        echo_green "Successfully installed golang to $HOME/.local/$GO_DIR !"
    fi
}

function install_node16() {
    echo_green "Installing node 16 for copilot..."
    # https://github.com/nodesource/distributions

    local VERSION="v16.13.0"

    if [[ $ARCH == "x86_64" ]]; then
        local arch="x64"
    elif [[ $ARCH == "aarch64" ]]; then
        local arch="arm64"
    fi
    local DISTRO="$PLATFORM-$arch"

    mkdir -p $HOME/.local/node
    wget -O $HOME/.local/node/node.tar.gz https://nodejs.org/dist/$VERSION/node-$VERSION-$DISTRO.tar.gz
    tar -C $HOME/.local/node -xzf $HOME/.local/node/node.tar.gz
    rm -rf $HOME/.local/node/node.tar.gz

    if [[ $1 -eq 1 ]]; then
        echo_green "Set node path to $HOME/.local/node/node-$VERSION-$DISTRO in $CUR_SHELL_CONFIG"
        echo 'export PATH=$HOME/.local/node/node-$VERSION-$DISTRO/bin:$PATH' >> $CUR_SHELL_CONFIG
        export PATH=$HOME/.local/node/node-$VERSION-$DISTRO/bin:$PATH
    fi
    echo_green "Successfully installed node to $HOME/.local/node/node-$VERSION-$DISTRO !"
}

function install_python() {
    echo_green "Installing python3..."

    if [[ "$OS" == "mac" ]]; then
        brew install python3
    else
        if [[ $ARCH == "x86_64" ]]; then
            local arch="amd64"
        elif [[ $ARCH == "aarch64" ]]; then
            local arch="arm64"
        fi

        local PYTHON_VERSION="3.10.0"
        local PYTHON_TAR="Python-$PYTHON_VERSION.tgz"
        local PYTHON_URL="https://www.python.org/ftp/python/$PYTHON_VERSION/$PYTHON_TAR"
        local PYTHON_DIR="Python-$PYTHON_VERSION"

        wget -O $PYTHON_TAR $PYTHON_URL
        tar -C $HOME/.local -xzf $PYTHON_TAR
        rm -rf $PYTHON_TAR

        cd $HOME/.local/$PYTHON_DIR
        ./configure --prefix=$HOME/.local/$PYTHON_DIR
        make
        make install
        cd -

        echo_green "Set python path to $HOME/.local/$PYTHON_DIR in $CUR_SHELL_CONFIG"
        echo 'export PATH=$HOME/.local/'$PYTHON_DIR'/bin:$PATH' >> $CUR_SHELL_CONFIG
        export PATH=$HOME/.local/$PYTHON_DIR/bin:$PATH

        echo_green "Successfully installed python to $HOME/.local/$PYTHON_DIR !"
    fi
}

function install_pip() {
    echo_green "Installing pip3..."

    if [[ $ARCH == "x86_64" ]]; then
        local arch="amd64"
    elif [[ $ARCH == "aarch64" ]]; then
        local arch="arm64"
    fi

    local PIP_VERSION="21.3.1"
    local PIP_TAR="get-pip.py"
    local PIP_URL="https://bootstrap.pypa.io/pip/$PIP_VERSION/$PIP_TAR"
    local PIP_DIR="pip"

    wget -O $PIP_TAR $PIP_URL
    python3 $PIP_TAR
    rm -rf $PIP_TAR

    echo_green "Successfully installed pip3 to $HOME/.local/$PIP_DIR !"
}

function install_node() {
    echo_green "Installing node 16..."

    if [[ $OS == "mac" ]]; then
        brew install node@16
    else
        install_node16 1
    fi
}

function install_llvm() {
    echo_green "Installing llvm..."
    local LLVM_DIR="llvm"

    if [[ $ARCH == "x86_64" ]]; then
        local arch="X86"
    elif [[ $ARCH == "arm64" ]]; then
        local arch="AArch64"
    fi

    git clone https://github.com/llvm/llvm-project.git /tmp/llvm-project
    
    pushd /tmp/llvm-project
    cmake -S llvm -B build -G Ninja \
        -DLLVM_ENABLE_PROJECTS="clang;lldb" \
        -DCMAKE_BUILD_TYPE=Release \
        -DLLVM_ENABLE_RUNTIMES="libcxx;libcxxabi" \
        -DLLVM_TARGETS_TO_BUILD=$arch \ 
        -DCMAKE_INSTALL_PREFIX=$HOME/.local/${LLVM_DIR}
    cmake --build build --target install

    echo_green "Set llvm path to $HOME/.local/$LLVM_DIR in $CUR_SHELL_CONFIG"
    echo 'export PATH=$HOME/.local/'$LLVM_DIR'/bin:$PATH' >> $CUR_SHELL_CONFIG
    export PATH=$HOME/.local/$LLVM_DIR/bin:$PATH

    echo_green "Successfully installed llvm to $HOME/.local/$LLVM_DIR !"
}

function install_bob() {
    echo_green "Installing neovim version control bob..."

    cargo install --git https://github.com/MordechaiHadad/bob.git

    echo_green "Set nvim to PATH in $CUR_SHELL_CONFIG"
    echo 'export PATH=$HOME/.local/share/nvim/bin:$PATH' >> $CUR_SHELL_CONFIG
    
    export PATH=$HOME/.local/share/nvim/bin:$PATH

    echo_green "Successfully installed bob to $HOME/.cargo/bin !"
}

function install_neovim() {
    if [ "$OS" == "mac" ]; then
        brew install neovim
    else
        install_bob
        bob use $NEOVIM_VERSION
    fi
}

function install_fonts() {
    echo_green "Installing fonts..."

    if [ "$OS" == "mac" ]; then
        brew tap homebrew/cask-fonts
        brew install --cask font-jetbrains-mono-nerd-font
    else
        mkdir -p ~/.local/share/fonts

        pushd ~/.local/share/fonts 
        curl -fLo "JetBrains Mono NL Regular Nerd Font Complete.ttf" https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/JetBrainsMono/NoLigatures/Regular/complete/JetBrains%20Mono%20NL%20Regular%20Nerd%20Font%20Complete.ttf
        popd
    fi
}

function install_cpsm() {
    echo_green "Compiling cpsm..."
    pushd ~/.local/share/nvim/site/pack/packer/start/cpsm 
    ./install.sh
    popd
}

##############################
# Installation
##############################
function install_mac() {
    # install tools
    brew install ripgrep fd fortune lua sqlite \
        cmake lazygit yarn gnu-sed boost\
        trash
    go install github.com/klauspost/asmfmt/cmd/asmfmt@latest

    # install language server
    npm install -g neovim
    pip3 install pynvim
}

# How to local install...
function install_ubuntu() {
    sudo apt update
    sudo apt install -y ripgrep fd-find fortune-mod lua5.3 bear \
        cmake gdb yarn libsqlite3-dev sqlite3 \
        libboost-all-dev python3-dev python3-venv

    # rename fdfind to fd
    mkdir -p ~/.local/bin
    ln -s $(which fdfind) ~/.local/bin/fd
    export PATH=$HOME/.local/bin:$PATH
    echo 'export PATH=$HOME/.local/bin:$PATH' >> $CUR_SHELL_CONFIG

    sudo npm install -g neovim trash-cli
    go install github.com/jesseduffield/lazygit@latest
    go install github.com/klauspost/asmfmt/cmd/asmfmt@latest
    pip3 install pynvim
}

function install_rhel() {
    sudo dnf install -y fortune-mod sqlite-devel sqlite boost-devel python3-devel

    cargo install ripgrep fd-find
    pip3 install compiledb pynvim --user
    sudo npm install -g neovim trash-cli yarn
    go install github.com/jesseduffield/lazygit@latest
    go install github.com/klauspost/asmfmt/cmd/asmfmt@latest
}

function install() {
    check_all

	echo_green "Installing..."
    install_neovim

    if [ "$OS" == "mac" ]; then
        install_mac
    elif [ "$OS" == "ubuntu" ]; then
        install_ubuntu
    elif [ "$OS" == "rhel" ]; then
        install_rhel
    fi

    install_fonts

    export VISUAL="nvim"
    export EDITOR="nvim"
    echo 'export VISUAL="nvim"' >> $CUR_SHELL_CONFIG
    echo 'export EDITOR="nvim"' >> $CUR_SHELL_CONFIG

    neovim_package_update
    install_cpsm

    mkdir -p ~/.local/state/nvim/neorg-notes/work

    echo_green "Installation complete!"
    echo_green "* NOTE: Don't forget to change your terminal fonts."
}

##############################
# Main
##############################
CONTAINER=0
INSTALL=0
UPDATE=0
ACCEPT=0
while getopts "hibuc" opt; do
	case $opt in
	h)
		help
		exit 0
		;;
	i)
        INSTALL=1
		;;
	u)
        UPDATE=1
		;;
    c)
        CONTAINER=1
    y)
        ACCEPT=1
        ;;
	*)
        errcho "Invalid option: -$OPTARG"
        help
		exit 1
		;;
	esac
done

if [[ $INSTALL == 1 ]]; then
    install
elif [[ $UPDATE == 1 ]]; then
    update
else
    help
fi


