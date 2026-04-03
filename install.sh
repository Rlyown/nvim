#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

preflight_check() {
  local os_name
  os_name="$(uname -s 2>/dev/null || echo unknown)"
  case "$os_name" in
    Darwin|Linux) ;;
    *)
      echo "Error: unsupported system '$os_name'. This installer supports macOS and Kali/Debian-family Linux." >&2
      exit 1
      ;;
  esac
}

usage() {
  cat <<'EOF'
Usage:
  ./install.sh [options]

Options:
  --disable <list>    Disable language packs for dependency install (CSV: cpp,go,rust,python,tex,sql)
  --disable-cpp       Same as: --disable cpp
  --disable-go        Same as: --disable go
  --disable-rust      Same as: --disable rust
  --disable-python    Same as: --disable python
  --disable-tex       Same as: --disable tex
  --disable-sql       Same as: --disable sql
  --no-plugin-sync   Skip `nvim --headless` plugin sync
  --restore-lock     Use `lazy-lock.json` via `Lazy! restore` (otherwise `Lazy! sync`)
  -h, --help         Show help

Notes:
  - macOS: installs dependencies via Homebrew
  - Linux: validated on Kali Linux and uses APT for dependencies
  - Installs required Python package `pylatexenc` (provides `latex2text`)
  - Installs required tree-sitter-cli via npm
  - Installs Rust by default (unless `--disable-rust`)
  - Installs Kitty by default (skips if already installed)
  - Installs Nerd Font by default (JetBrainsMono Nerd Font)
EOF
}

NO_PLUGIN_SYNC=0
RESTORE_LOCK=0
DISABLE_LANGS=""

preflight_check

append_disable() {
  local v="$1"
  if [[ -z "$DISABLE_LANGS" ]]; then
    DISABLE_LANGS="$v"
  else
    DISABLE_LANGS="${DISABLE_LANGS},$v"
  fi
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --disable)
      [[ $# -ge 2 ]] || { echo "Error: --disable requires a value" >&2; exit 2; }
      append_disable "$2"
      shift 2
      ;;
    --disable-cpp) append_disable "cpp"; shift ;;
    --disable-go) append_disable "go"; shift ;;
    --disable-rust) append_disable "rust"; shift ;;
    --disable-python) append_disable "python"; shift ;;
    --disable-tex) append_disable "tex"; shift ;;
    --disable-sql) append_disable "sql"; shift ;;
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

args=(--root "$ROOT_DIR")
if [[ -n "$DISABLE_LANGS" ]]; then
  args+=(--disable "$DISABLE_LANGS")
fi
if [[ "$NO_PLUGIN_SYNC" -eq 1 ]]; then
  args+=(--no-plugin-sync)
fi
if [[ "$RESTORE_LOCK" -eq 1 ]]; then
  args+=(--restore-lock)
fi

case "$(uname -s 2>/dev/null || echo unknown)" in
  Darwin)
    ensure_macos
    log_step "Starting macOS install flow"
    bash "$ROOT_DIR/scripts/install_macos.sh" "${args[@]}"
    ;;
  Linux)
    ensure_linux
    ensure_apt_based_linux
    if is_kali_linux; then
      log_step "Starting Kali Linux install flow"
    else
      log_warn "Detected $(linux_distribution_name). Proceeding with the APT-based Linux install flow."
    fi
    bash "$ROOT_DIR/scripts/install_linux.sh" "${args[@]}"
    ;;
  *)
    die "Unsupported system"
    ;;
esac

log_ok "Done"
