#!/bin/bash
git pull origin main:main
if [[ $? -ne 0 ]]; then
	echo -e "\033[31mPull remote main error\!\033[0m"
	while true; do
		read -r -p "Do you want to force pull, and discard local changes? [Y/n] " input

		case $input in
		[yY][eE][sS] | [yY])
			git checkout main
			git reset --hard
			git fetch origin main
			git merge
			if [[ $? -ne 0 ]]; then
				exit 1
			fi
			break
			;;

		[nN][oO] | [nN])
			exit 0
			;;

		*)
			echo "Invalid input..."
			;;
		esac
	done
fi

nvim +PackerSync
