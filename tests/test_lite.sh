#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
TEMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TEMP_DIR"' EXIT

XDG_CONFIG_HOME="$TEMP_DIR/config" \
XDG_DATA_HOME="$TEMP_DIR/data" \
XDG_STATE_HOME="$TEMP_DIR/state" \
XDG_CACHE_HOME="$TEMP_DIR/cache" \
nvim --clean -u "$ROOT_DIR/lite.lua" --headless \
  '+lua assert(vim.fn.has("nvim-0.12.4") == 1)' \
  '+lua assert(vim.fn.exists(":LiteFiles") == 2)' \
  '+lua assert(vim.fn.exists(":LiteGrep") == 2)' \
  +qa

if rg -n 'lazy|mason|https?://' "$ROOT_DIR/lite.lua" >/dev/null; then
  echo "lite.lua must not load plugins, Mason, or network URLs" >&2
  exit 1
fi

echo "lite configuration checks passed"
