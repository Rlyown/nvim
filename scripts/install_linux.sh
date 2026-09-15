#!/usr/bin/env bash
set -euo pipefail
# The shared Lua capability resolver generates the package list.
PACKAGE_FILE="${1:?missing package list}"
packages=()
while IFS= read -r package; do packages+=("$package"); done < "$PACKAGE_FILE"
sudo apt-get update
sudo apt-get install -y "${packages[@]}"
if [[ " ${packages[*]} " == *' npm '* ]] && ! command -v tree-sitter >/dev/null; then
  sudo npm install -g tree-sitter-cli
fi
