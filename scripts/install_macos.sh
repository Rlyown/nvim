#!/usr/bin/env bash
set -euo pipefail
PACKAGE_FILE="${1:?缺少包列表}"
while IFS= read -r package; do
  case "$package" in
    kitty|font-*) brew install --cask "$package" ;;
    *) brew install "$package" ;;
  esac
done < "$PACKAGE_FILE"
if rg -qx pipx "$PACKAGE_FILE" && ! command -v latex2text >/dev/null; then
  pipx install pylatexenc
fi
