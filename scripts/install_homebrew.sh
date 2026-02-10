#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib.sh"

if command -v brew >/dev/null 2>&1; then
  log_ok "Homebrew already exists"
  exit 0
fi

if [[ -x /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -x /usr/local/bin/brew ]]; then
  eval "$(/usr/local/bin/brew shellenv)"
fi

if command -v brew >/dev/null 2>&1; then
  log_ok "Homebrew already exists (PATH updated)"
  exit 0
fi

need_cmd /bin/bash
need_cmd curl

log_warn "Homebrew not found. Installing via the official script."
log_warn "If you don't want this script to install Homebrew, install it manually first, then rerun ./install.sh."

NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

if [[ -x /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -x /usr/local/bin/brew ]]; then
  eval "$(/usr/local/bin/brew shellenv)"
fi

command -v brew >/dev/null 2>&1 || die "Homebrew install failed or brew is not in PATH"
log_ok "Homebrew installed"
