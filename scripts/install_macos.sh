#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib.sh"
source "$SCRIPT_DIR/brew_utils.sh"

usage() {
  cat <<'EOF'
Usage:
  scripts/install_macos.sh --root <repo_root> [options]

Options:
  --disable <list>      Disable language packs for dependency install (CSV: cpp,go,rust,python,tex,sql)
  --no-plugin-sync   Skip `nvim --headless` plugin sync
  --restore-lock     Use `lazy-lock.json` via `Lazy! restore`
EOF
}

ROOT=""
NO_PLUGIN_SYNC=0
RESTORE_LOCK=0
DISABLE_LANGS=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --root) ROOT="$2"; shift 2 ;;
    --disable) DISABLE_LANGS="$2"; shift 2 ;;
    --no-plugin-sync) NO_PLUGIN_SYNC=1; shift ;;
    --restore-lock) RESTORE_LOCK=1; shift ;;
    -h|--help) usage; exit 0 ;;
    --with-optional|--with-fonts)
      log_warn "Note: $1 is no longer needed (all deps/fonts are installed by default)."
      shift
      ;;
    *) die "Unknown argument: $1" ;;
  esac
done

[[ -n "$ROOT" ]] || { usage; exit 2; }
ROOT="$(realpath_fallback "$ROOT")"

ensure_macos

log_step "Checking/installing Homebrew"
"$SCRIPT_DIR/install_homebrew.sh"

need_cmd brew

log_step "Updating Homebrew"
brew update

log_step "Installing Kitty"
brew_install_cask kitty

log_step "Installing required dependencies"
brew_install_formula neovim
brew_install_formula lua
brew_install_formula ripgrep
brew_install_formula fd
brew_install_formula lazygit
brew_install_formula gnu-sed
brew_install_formula imagemagick
brew_install_formula ghostscript

log_step "Installing extra dependencies (installed by default)"
brew_install_formula bear
brew_install_formula node
brew_install_formula yarn
brew_install_formula trash

log_step "Installing required Python package: pylatexenc (for latex2text)"
if command -v latex2text >/dev/null 2>&1; then
  log_ok "Already installed: pylatexenc (latex2text found)"
else
  if ! command -v python3 >/dev/null 2>&1; then
    log_step "python3 not found, installing via Homebrew"
    brew_install_formula python
  fi

  if ! python3 -m pip --version >/dev/null 2>&1; then
    log_warn "python3 pip is unavailable, trying ensurepip"
    python3 -m ensurepip --upgrade >/dev/null 2>&1 || true
  fi
  python3 -m pip --version >/dev/null 2>&1 || die "python3 pip is unavailable; cannot install pylatexenc"

  if python3 -m pip show pylatexenc >/dev/null 2>&1; then
    log_ok "Already installed: pylatexenc"
  else
    python3 -m pip install --user --upgrade pylatexenc
    log_ok "Installed: pylatexenc"
  fi

  if command -v latex2text >/dev/null 2>&1; then
    log_ok "latex2text command is available"
  else
    USER_BASE="$(python3 -c 'import site; print(site.USER_BASE)')"
    USER_BIN="${USER_BASE}/bin"
    if [[ -x "${USER_BIN}/latex2text" ]]; then
      log_warn "latex2text was installed to ${USER_BIN}, but this path is not in PATH."
      log_warn "Add this to your shell rc: export PATH=\"${USER_BIN}:\$PATH\""
    else
      log_warn "pylatexenc installation finished, but latex2text was not found in PATH."
    fi
  fi
fi

log_step "Installing required npm package: tree-sitter-cli"
if command -v tree-sitter >/dev/null 2>&1; then
  log_ok "Already installed: tree-sitter-cli"
else
  need_cmd npm
  npm install -g tree-sitter-cli
  need_cmd tree-sitter
  log_ok "Installed: tree-sitter-cli"
fi

disable_has() {
  local item="$1"
  [[ ",${DISABLE_LANGS}," == *",${item},"* ]]
}

if ! disable_has "go"; then
  log_step "Installing Go toolchain"
  brew_install_formula go
else
  log_warn "Go disabled: skipping Homebrew formula 'go'"
fi

if ! disable_has "rust"; then
  log_step "Installing Rust toolchain via Homebrew"
  brew_install_formula rust
else
  log_warn "Rust disabled: skipping Homebrew formula 'rust'"
fi

log_step "Installing Nerd Font (JetBrainsMono)"
brew tap homebrew/cask-fonts >/dev/null 2>&1 || true
brew_install_cask font-jetbrains-mono-nerd-font

log_step "Linking nvim config"
"$SCRIPT_DIR/link_nvim_config.sh" --root "$ROOT"

if [[ "$NO_PLUGIN_SYNC" -eq 1 ]]; then
  log_warn "Skipped plugin sync (rerun without --no-plugin-sync to enable)"
else
  log_step "Running headless plugin sync"
  "$SCRIPT_DIR/sync_plugins.sh" --restore-lock="$RESTORE_LOCK"
fi

log_ok "macOS install flow finished"
