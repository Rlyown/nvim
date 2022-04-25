#!/bin/bash
set -e
# set -x

PLAT=$(uname -s | tr A-Z a-z)
ARCH=$(uname -m | tr A-Z a-z)
if [[ $ARCH == "arm64" ]]; then
	ARCH="aarch64"
fi
PKG="codelldb-$ARCH-$PLAT.vsix"

function get_latest_release() {
	curl --silent "https://api.github.com/repos/$1/releases/latest" | # Get latest release from GitHub api
		grep '"tag_name":' |                                             # Get tag line
		sed -E 's/.*"([^"]+)".*/\1/'                                     # Pluck JSON value
}
LATEST=$(get_latest_release "vadimcn/vscode-lldb")

BASE=$(nvim --headless --noplugin -c "lua print(require'core.gvariable'.debuggers.dapinstall_dir)" -c "quit" 2>&1)
TARGET_DIR=$BASE"/codelldb"

echo -e "Platform: $PLAT $ARCH"
echo -e "Codelldb Version: $LATEST"
echo -e "Package: $PKG"
echo -e "Install Directory: $TARGET_DIR\n"

if [[ ! -d $TARGET_DIR ]]; then
	mkdir -p $TARGET_DIR
fi

(cd $TARGET_DIR && curl -OL "https://github.com/vadimcn/vscode-lldb/releases/download/$LATEST/$PKG")

echo -e "\nUnpacking $PKG"
unzip -d $TARGET_DIR "$TARGET_DIR/$PKG"

echo -e "\nSuccessful!"
