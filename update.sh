#!/bin/bash
git pull origin main:main
if [[ $? -ne 0 ]]; then
	echo -e "\033[31mPull remote main error\!\033[0m"
	while true; do
		read -r -p "Do you want to force pull, and discard local changes? [Y/n] " input

		case $input in
		[yY][eE][sS] | [yY])
			git reset --hard
			git pull origin main:main
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
