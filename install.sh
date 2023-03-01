#!/bin/bash

set -e

# TODO: use homebrew to install dependencies in all platform

##############################
# Variables
##############################
PLATFORM=$(uname -s | tr '[:upper:]' '[:lower:]')
ARCH=$(uname -m)
OS=
HOMEBREW=
CUR_SHELL=$(echo $SHELL | xargs basename)
CUR_SHELL_CONFIG="$HOME/.${CUR_SHELL}rc"

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
					install_homebrew
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
	check_homebrew

	show_info
}

##############################
# Install
##############################
function install_homebrew() {
	echo "Installing Homebrew..."
	if [ "${OS}" == "mac" ]; then
		if [[ $ACCEPT -eq 1 ]]; then
			NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
		else
			/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
		fi
		HOMEBREW=/opt/homebrew/bin/brew
	elif ["${OS}" == "ubuntu"]; then
		if [[ $ACCEPT -eq 1 ]]; then
			NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
		else
			/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
		fi

		test -d ~/.linuxbrew && eval $(~/.linuxbrew/bin/brew shellenv)
		test -d /home/linuxbrew/.linuxbrew && eval $(/home/linuxbrew/.linuxbrew/bin/brew shellenv)
		test -r ~/.bash_profile && echo "eval \$($(brew --prefix)/bin/brew shellenv)" >>~/.bash_profile
		echo "eval \$($(brew --prefix)/bin/brew shellenv)" >>~/.profile
		HOMEBREW=/home/linuxbrew/.liinuxbrew/bin/brew
	elif ["${OS}" == "rhel"]; then
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
	install_neovim

	export GO111MODULE=on
	export GOPROXY=https://goproxy.cn

	# install tools
	brew install ripgrep fd fortune lua sqlite \
		cmake lazygit yarn gnu-sed boost trash exa bat \
		go python3 node@16 rust llvm neovim
	go install github.com/klauspost/asmfmt/cmd/asmfmt@latest

	# install language server
	npm install -g neovim
	pip3 install pynvim

	install_fonts

	export VISUAL="nvim"
	export EDITOR="nvim"
	echo 'export VISUAL="nvim"' >>$CUR_SHELL_CONFIG
	echo 'export EDITOR="nvim"' >>$CUR_SHELL_CONFIG

	# Sync neovim remote package version
	nvim --headless "+Lazy! restore" +qa

	mkdir -p ~/.local/state/nvim/neorg-notes/work

	echo_green "Installation complete!!!"
	echo_green "Follow steps to finish installation: "
	echo_green "  1. Don't forget to change your terminal fonts."
	echo_green "  2. Don't forget to check all paths in 'lua/core/gvariable.lua'."
	echo_green "  3. Placces restart your terminal."
	echo_green "  4. Run 'nvim +checkhealth' to see plugins' diagnose problems."
	echo_green "  5. (Optical) If you want to search program language api from 'Zeal' in Linux or 'Dash' in MacOS, you can download it and set the binary path in 'lua/core/gvariable.lua'."
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
			nvim --headless "+Lazy! restore" +qa
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
					nvim --headless "+Lazy! restore" +qa
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
# Helper
##############################
function help() {
	echo "Usage: $0 [options]"
	echo "    -h     Show this help"
	echo "    -i     Install"
	echo "    -u     Update configuration files"
	echo "    -U     Update configuration files and dependencies application"
	echo "    -c     Container mode"
	echo "    -y     Assume yes to all prompts"
}

##############################
# Main
##############################
CONTAINER=0
INSTALL=0
UPDATE=0
ACCEPT=0
while getopts "hibucy" opt; do
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
