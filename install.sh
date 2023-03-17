#!/bin/bash

set -e

##############################
# Variables
##############################
PLATFORM=$(uname -s | tr '[:upper:]' '[:lower:]')
ARCH=$(uname -m)
OS=
HOMEBREW=
CUR_SHELL=
CUR_SHELL_CONFIG=
NPM_MIRROR=https://registry.npmmirror.com
PYTHON_MIRROR=https://pypi.tuna.tsinghua.edu.cn/simple
##############################
# Utils
##############################
function echo_green() {
	echo -e "\033[32m$1\033[0m"
}

function errcho() {
	echo >&2 -e "\033[31m$1\033[0m"
}

function read_input() {
	local input
	read -p "$(echo -n -e "\033[33m$1\033[0m")" -r input
	input=${input:-$2}
	echo "$input"
}

function nvim_plugins_sync() {
	nvim --headless "+Lazy! restore | MasonToolsUpdate" +qa
}

##############################
# Check
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
			errcho "Your OS (${OS}) is not test."
			while true; do
				local input=$(read_input "Do you want to continue? [y/n]: " "n")

				case $input in
				[yY][eE][sS] | [yY])
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
			;;
		esac
	else
		errcho "Your platform (${PLATFORM}) is not test."
		while true; do
			local input=$(read_input "Do you want to continue? [y/n]: " "n")

			case $input in
			[yY][eE][sS] | [yY])
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
}

function check_shell() {
	CUR_SHELL=$(echo $SHELL | xargs basename)
	CUR_SHELL_CONFIG="$HOME/.${CUR_SHELL}rc"
}

function check_homebrew() {
	if ! command -v brew >/dev/null 2>&1; then
		errcho "Homebrew is not installed! Please install homebrew first."

		if [[ $ACCEPT -eq 1 ]]; then
			install_homebrew
		else
			while true; do
				local input=$(read_input "Do you want to install homebrew now? [y/n]: " "n")

				case $input in
				[yY][eE][sS] | [yY])
					if [[ $CHINESE_MIRROR == 1 ]]; then
						install_homebrew_chinese_mirror
					else
						install_homebrew
					fi
					HOMEBREW=$(which brew)
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
}

function show_info() {
	echo_green "OS: ${OS}"
	echo_green "Platform: ${PLATFORM}"
	echo_green "Architecture: ${ARCH}"
	echo_green "Shell: ${CUR_SHELL}"
	echo_green "Shell config: ${CUR_SHELL_CONFIG}"
	echo_green "Homebrew: ${HOMEBREW}"
	echo
}

function check() {
	check_os
	check_shell
	check_homebrew

	show_info
}

##############################
# Install
##############################
function install_homebrew_chinese_mirror() {
	echo "Installing Homebrew..."

	export HOMEBREW_INSTALL_FROM_API=1
	export HOMEBREW_API_DOMAIN="https://mirrors.tuna.tsinghua.edu.cn/homebrew-bottles/api"
	export HOMEBREW_BOTTLE_DOMAIN="https://mirrors.tuna.tsinghua.edu.cn/homebrew-bottles"
	export HOMEBREW_BREW_GIT_REMOTE="https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/brew.git"
	export HOMEBREW_CORE_GIT_REMOTE="https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/homebrew-core.git"

	git clone --depth=1 https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/install.git brew-install

	if [ "${OS}" == "mac" ]; then
		if [[ $ACCEPT -eq 1 ]]; then
			NONINTERACTIVE=1 /bin/bash brew-install/install.sh
		else
			/bin/bash brew-install/install.sh
		fi
		test -r ~/.bash_profile && echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >>~/.bash_profile
		test -r ~/.zprofile && echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >>~/.zprofile

		if [[ $ARCH == "arm64" ]]; then
			HOMEBREW=/usr/local/bin/brew
		else
			HOMEBREW=/opt/homebrew/bin/brew
		fi
	elif [ "${OS}" == "ubuntu" ]; then
		if [[ $ACCEPT -eq 1 ]]; then
			NONINTERACTIVE=1 /bin/bash brew-install/install.sh
		else
			/bin/bash brew-install/install.sh
		fi

		# shellcheck disable=2046
		test -d ~/.linuxbrew && eval $(~/.linuxbrew/bin/brew shellenv)
		# shellcheck disable=2046
		test -d /home/linuxbrew/.linuxbrew && eval $(/home/linuxbrew/.linuxbrew/bin/brew shellenv)
		test -r ~/.bash_profile && echo "eval \$($(brew --prefix)/bin/brew shellenv)" >>~/.bash_profile
		echo "eval \$($(brew --prefix)/bin/brew shellenv)" >>~/.profile
		test -r ~/.zprofile && echo "eval \"\$($(brew --prefix)/bin/brew shellenv)\"" >>~/.zprofile
		HOMEBREW=/home/linuxbrew/.liinuxbrew/bin/brew
	elif [ "${OS}" == "rhel" ]; then
		sudo yum groupinstall 'Development Tools'
		sudo yum install curl file git

		if [[ $ACCEPT -eq 1 ]]; then
			NONINTERACTIVE=1 /bin/bash brew-install/install.sh
		else
			/bin/bash brew-install/install.sh
		fi

		test -d ~/.linuxbrew && eval $(~/.linuxbrew/bin/brew shellenv)
		test -d /home/linuxbrew/.linuxbrew && eval $(/home/linuxbrew/.linuxbrew/bin/brew shellenv)
		test -r ~/.bash_profile && echo "eval \$($(brew --prefix)/bin/brew shellenv)" >>~/.bash_profile
		echo "eval \$($(brew --prefix)/bin/brew shellenv)" >>~/.profile
		test -r ~/.zprofile && echo "eval \"\$($(brew --prefix)/bin/brew shellenv)\"" >>~/.zprofile
		HOMEBREW=/home/linuxbrew/.liinuxbrew/bin/brew
	fi

	rm -rf brew-install
	echo_green "Homebrew installed successfully"
}

function install_homebrew() {
	echo "Installing Homebrew..."
	if [ "${OS}" == "mac" ]; then
		if [[ $ACCEPT -eq 1 ]]; then
			NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
		else
			/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
		fi
		if [[ $ARCH == "arm64" ]]; then
			HOMEBREW=/usr/local/bin/brew
		else
			HOMEBREW=/opt/homebrew/bin/brew
		fi
	elif [ "${OS}" == "ubuntu" ]; then
		if [[ $ACCEPT -eq 1 ]]; then
			NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
		else
			/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
		fi

		test -d ~/.linuxbrew && eval $(~/.linuxbrew/bin/brew shellenv)
		test -d /home/linuxbrew/.linuxbrew && eval $(/home/linuxbrew/.linuxbrew/bin/brew shellenv)
		test -r ~/.bash_profile && echo "eval \$($(brew --prefix)/bin/brew shellenv)" >>~/.bash_profile
		echo "eval \$($(brew --prefix)/bin/brew shellenv)" >>~/.profile
		test -r ~/.zprofile && echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >>~/.zprofile
		HOMEBREW=/home/linuxbrew/.liinuxbrew/bin/brew
	elif [ "${OS}" == "rhel" ]; then
		sudo yum groupinstall 'Development Tools'
		sudo yum install curl file git

		if [[ $ACCEPT -eq 1 ]]; then
			NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
		else
			/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
		fi

		test -d ~/.linuxbrew && eval $(~/.linuxbrew/bin/brew shellenv)
		test -d /home/linuxbrew/.linuxbrew && eval $(/home/linuxbrew/.linuxbrew/bin/brew shellenv)
		test -r ~/.bash_profile && echo "eval \$($(brew --prefix)/bin/brew shellenv)" >>~/.bash_profile
		echo "eval \$($(brew --prefix)/bin/brew shellenv)" >>~/.profile
		test -r ~/.zprofile && echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >>~/.zprofile
		HOMEBREW=/home/linuxbrew/.liinuxbrew/bin/brew
	fi
	echo_green "Homebrew installed successfully"
}

##############################
# Installation
##############################
function install_fonts() {
	echo_green "Installing fonts..."

	if [ "$OS" == "mac" ]; then
		brew tap homebrew/cask-fonts
		brew install --cask font-jetbrains-mono-nerd-font

		echo_green "JetBrains Mono Nerd Font is installed successfully"
	else
		mkdir -p ~/.local/share/fonts

		pushd ~/.local/share/fonts
		curl -fLo "JetBrains Mono NL Regular Nerd Font Complete.ttf" https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/JetBrainsMono/NoLigatures/Regular/complete/JetBrains%20Mono%20NL%20Regular%20Nerd%20Font%20Complete.ttf
		popd

		echo_green "JetBrains Mono Nerd Font is installed successfully in ~/.local/share/fonts"
	fi
}

function install() {
	check

	echo_green "Installing..."

	# export GO111MODULE=on
	# export GOPROXY=https://goproxy.cn

	if [ $CHINESE_MIRROR == 1 ]; then
		export HOMEBREW_API_DOMAIN="https://mirrors.tuna.tsinghua.edu.cn/homebrew-bottles/api"
		export HOMEBREW_BOTTLE_DOMAIN="https://mirrors.tuna.tsinghua.edu.cn/homebrew-bottles"
		export HOMEBREW_BREW_GIT_REMOTE="https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/brew.git"
		export HOMEBREW_CORE_GIT_REMOTE="https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/homebrew-core.git"
		export HOMEBREW_PIP_INDEX_URL="https://pypi.tuna.tsinghua.edu.cn/simple"
	fi

	# install tools
	brew install ripgrep fd fortune lua sqlite \
		cmake lazygit yarn gnu-sed boost exa bat \
		go python3 node@16 rust llvm neovim npm bear

	HOMEBREW_BIN_PATH=$(dirname ${HOMEBREW})
	# trash in homebrew is macos only
	if [[ $PLATFORM == "darwin" ]]; then
		brew install trash
	else
		if [ $CHINESE_MIRROR == 1 ]; then
			"${HOMEBREW_BIN_PATH}/npm" install --global trash-cli --registry $NPM_MIRROR
		else
			"${HOMEBREW_BIN_PATH}/npm" install --global trash-cli
		fi
	fi

	if [ $CHINESE_MIRROR == 1 ]; then
		"${HOMEBREW_BIN_PATH}/npm" install -g neovim --registry $NPM_MIRROR
		"${HOMEBREW_BIN_PATH}/pip3" install pynvim -i $PYTHON_MIRROR
	else
		"${HOMEBREW_BIN_PATH}/npm" install -g neovim
		"${HOMEBREW_BIN_PATH}/pip3" install pynvim
	fi

	export VISUAL="nvim"
	export EDITOR="nvim"
	echo 'export VISUAL="nvim"' >>$CUR_SHELL_CONFIG
	echo 'export EDITOR="nvim"' >>$CUR_SHELL_CONFIG

	# Sync neovim remote package version
	nvim_plugins_sync

	mkdir -p ~/.local/state/nvim/neorg-notes/work

	echo_green "Installation complete!!!"
	echo_green "Follow steps to finish installation: "
	echo_green "  1. Don't forget to change your terminal fonts."
	echo_green "  2. Don't forget to check all paths in 'lua/core/gvariable.lua'."
	echo_green "  3. Placces restart your terminal."
	echo_green "  4. Run 'nvim +checkhealth' to see plugins' diagnose problems."
	echo_green "  5. (Optical) If you want to search program language api from 'Zeal' in Linux or 'Dash' in MacOS, you can download it and set the binary path in 'lua/core/gvariable.lua'."
	echo_green "  6. (Optical) If you want to have a better experience with 'tmux', you can refer to [Tmux Integration] in README."
}

##############################
# Update
##############################
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

			# Sync neovim remote package version
			nvim_plugins_sync
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
					# Sync neovim remote package version
					nvim_plugins_sync
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
	else
		nvim_plugins_sync
	fi

}

##############################
# Helper
##############################
function help() {
	echo "Usage: $0 [options]"
	echo "    -h     Show this help"
	echo "    -i     Install"
	echo "    -u     Update configuration files"
	echo "    -U     Update configuration files and dependencies application"
	echo "    -c     Container mode"
	echo "    -m     Use Chinese mirror"
	echo "    -y     Assume yes to all prompts"
}

##############################
# Main
##############################
CONTAINER=0
INSTALL=0
UPDATE=0
ACCEPT=0
CHINESE_MIRROR=0
while getopts "hibucym" opt; do
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
	U)
		UPDATE=1
		INSTALL=1
		;;
	c)
		CONTAINER=1
		;;
	y)
		ACCEPT=1
		;;
	m)
		CHINESE_MIRROR=1
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
