#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

preflight_check() {
  local os_name
  os_name="$(uname -s 2>/dev/null || echo unknown)"
  if [[ "$os_name" != "Darwin" ]]; then
    echo "Error: unsupported system '$os_name'. This installer supports macOS only." >&2
    exit 1
  fi
}

usage() {
  cat <<'EOF'
Usage:
  ./install.sh [options]

Options:
  --no-plugin-sync   Skip `nvim --headless` plugin sync
  --restore-lock     Use `lazy-lock.json` via `Lazy! restore` (otherwise `Lazy! sync`)
  -h, --help         Show help

Notes:
  - macOS only
  - Installs dependencies via Homebrew
  - Installs Kitty by default (skips if already installed)
  - Installs Nerd Font by default (JetBrainsMono Nerd Font)
EOF
}

NO_PLUGIN_SYNC=0
RESTORE_LOCK=0

preflight_check

while [[ $# -gt 0 ]]; do
  case "$1" in
    --no-plugin-sync) NO_PLUGIN_SYNC=1; shift ;;
    --restore-lock) RESTORE_LOCK=1; shift ;;
    -h|--help) usage; exit 0 ;;
    --with-optional|--with-fonts)
      echo "Note: $1 is no longer needed (all deps/fonts are installed by default)." >&2
      shift
      ;;
    *)
      echo "Unknown argument: $1" >&2
      usage
      exit 1
      ;;
  esac
done

mkdir -p "$ROOT_DIR/scripts"

source "$ROOT_DIR/scripts/lib.sh"

ensure_macos

log_step "Starting macOS install flow"
"$ROOT_DIR/scripts/install_macos.sh" \
  --root "$ROOT_DIR" \
  $( [[ "$NO_PLUGIN_SYNC" -eq 1 ]] && echo "--no-plugin-sync" ) \
  $( [[ "$RESTORE_LOCK" -eq 1 ]] && echo "--restore-lock" )

log_ok "Done"
