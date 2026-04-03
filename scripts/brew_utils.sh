#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib.sh"

brew_has_command() {
  local name="$1"
  shift

  if [[ "$#" -gt 0 ]] && command_exists_any "$@"; then
    log_ok "Already available in PATH: $name"
    return 0
  fi

  return 1
}

brew_install_formula() {
  local name="$1"
  shift

  if brew_has_command "$name" "$@"; then
    return 0
  fi

  if brew list --formula "$name" >/dev/null 2>&1; then
    log_ok "Already installed: $name"
    return 0
  fi
  brew install "$name"
  log_ok "Installed: $name"
}

brew_install_cask() {
  local name="$1"
  shift

  if brew_has_command "$name (cask)" "$@"; then
    return 0
  fi

  if brew list --cask "$name" >/dev/null 2>&1; then
    log_ok "Already installed: $name (cask)"
    return 0
  fi
  brew install --cask "$name"
  log_ok "Installed: $name (cask)"
}
