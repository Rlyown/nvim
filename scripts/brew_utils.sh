#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib.sh"

brew_install_formula() {
  local name="$1"
  if brew list --formula "$name" >/dev/null 2>&1; then
    log_ok "已安装: $name"
    return 0
  fi
  brew install "$name"
  log_ok "已安装: $name"
}

brew_install_cask() {
  local name="$1"
  if brew list --cask "$name" >/dev/null 2>&1; then
    log_ok "已安装: $name (cask)"
    return 0
  fi
  brew install --cask "$name"
  log_ok "已安装: $name (cask)"
}

