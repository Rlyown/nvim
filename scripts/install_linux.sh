#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib.sh"
source "$SCRIPT_DIR/apt_utils.sh"

usage() {
  cat <<'EOF'
Usage:
  scripts/install_linux.sh --root <repo_root> [options]

Options:
  --disable <list>      Disable language packs for dependency install (CSV: cpp,go,rust,python,tex,sql)
  --no-plugin-sync      Skip `nvim --headless` plugin sync
  --restore-lock        Use `lazy-lock.json` via `Lazy! restore`
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

ensure_linux
ensure_apt_based_linux

disable_has() {
  local item="$1"
  [[ ",${DISABLE_LANGS}," == *",${item},"* ]]
}

ensure_fd_alias() {
  if command -v fd >/dev/null 2>&1; then
    log_ok "fd command is available"
    return 0
  fi

  if ! command -v fdfind >/dev/null 2>&1; then
    die "fd-find was installed, but command 'fdfind' was not found"
  fi

  local user_bin="${HOME}/.local/bin"
  local fd_target
  local current_target
  fd_target="$(command -v fdfind)"

  ensure_dir "$user_bin"

  if [[ -L "${user_bin}/fd" || -e "${user_bin}/fd" ]]; then
    current_target="$(realpath_fallback "${user_bin}/fd" 2>/dev/null || true)"
    if [[ -n "$current_target" && "$current_target" == "$(realpath_fallback "$fd_target")" ]]; then
      log_ok "fd compatibility symlink already exists"
    else
      backup_path "${user_bin}/fd"
      ln -s "$fd_target" "${user_bin}/fd"
      log_ok "Created fd compatibility symlink: ${user_bin}/fd -> $fd_target"
    fi
  else
    ln -s "$fd_target" "${user_bin}/fd"
    log_ok "Created fd compatibility symlink: ${user_bin}/fd -> $fd_target"
  fi

  if [[ ":$PATH:" != *":${user_bin}:"* ]]; then
    log_warn "${user_bin} is not in PATH."
    log_warn "Add this to your shell rc: export PATH=\"${user_bin}:\$PATH\""
  fi
}

npm_global_install() {
  local package_name="$1"
  run_with_privileges npm install -g "$package_name"
  hash -r
}

ensure_yarn() {
  if command -v yarn >/dev/null 2>&1; then
    log_ok "Already installed: yarn"
    return 0
  fi

  need_cmd npm
  log_step "Installing required npm package: yarn"
  npm_global_install yarn
  need_cmd yarn
  log_ok "Installed: yarn"
}

ensure_tree_sitter_cli() {
  if command -v tree-sitter >/dev/null 2>&1; then
    log_ok "Already installed: tree-sitter-cli"
    return 0
  fi

  need_cmd npm
  log_step "Installing required npm package: tree-sitter-cli"
  npm_global_install tree-sitter-cli
  need_cmd tree-sitter
  log_ok "Installed: tree-sitter-cli"
}

ensure_pylatexenc() {
  log_step "Installing required Python package: pylatexenc (for latex2text)"

  if command -v latex2text >/dev/null 2>&1; then
    log_ok "Already installed: pylatexenc (latex2text found)"
    return 0
  fi

  need_cmd python3

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
    local user_base
    local user_bin
    user_base="$(python3 -c 'import site; print(site.USER_BASE)')"
    user_bin="${user_base}/bin"
    if [[ -x "${user_bin}/latex2text" ]]; then
      log_warn "latex2text was installed to ${user_bin}, but this path is not in PATH."
      log_warn "Add this to your shell rc: export PATH=\"${user_bin}:\$PATH\""
    else
      log_warn "pylatexenc installation finished, but latex2text was not found in PATH."
    fi
  fi
}

install_nerd_font() {
  local font_name="JetBrainsMono Nerd Font"
  local font_dir="${HOME}/.local/share/fonts"
  local font_zip_url="https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip"
  local tmp_dir

  if command -v fc-list >/dev/null 2>&1 && fc-list | grep -qi "$font_name"; then
    log_ok "Already installed: ${font_name}"
    return 0
  fi

  need_cmd curl
  need_cmd unzip
  need_cmd fc-cache

  ensure_dir "$font_dir"
  tmp_dir="$(mktemp -d)"

  log_step "Installing Nerd Font (JetBrainsMono)"
  if ! curl -fL "$font_zip_url" -o "${tmp_dir}/JetBrainsMono.zip"; then
    rm -rf "$tmp_dir"
    die "Failed to download ${font_name}"
  fi
  if ! unzip -oq "${tmp_dir}/JetBrainsMono.zip" "*.ttf" -d "$font_dir"; then
    rm -rf "$tmp_dir"
    die "Failed to extract ${font_name}"
  fi
  fc-cache -f "$font_dir" >/dev/null 2>&1 || true
  rm -rf "$tmp_dir"
  log_ok "Installed: ${font_name}"
}

distro_name="$(linux_distribution_name)"
if is_kali_linux; then
  log_ok "Detected Linux distribution: ${distro_name}"
else
  log_warn "Detected ${distro_name}. This install flow is validated on Kali Linux and should work on APT-based Debian-family distributions."
fi

log_step "Updating APT package index"
apt_update

log_step "Installing Kitty"
apt_install_packages "kitty:kitty"

log_step "Installing required dependencies"
apt_install_packages \
  "neovim:nvim" \
  "lua5.1:lua5.1|lua" \
  "ripgrep:rg" \
  "fd-find:fd|fdfind" \
  "lazygit:lazygit" \
  "imagemagick:magick|convert" \
  "ghostscript:gs" \
  "python3:python3" \
  "python3-pip:pip3" \
  "xclip:xclip" \
  "libglib2.0-bin:gio"

log_step "Installing extra dependencies (installed by default)"
apt_install_packages \
  "bear:bear" \
  "nodejs:node" \
  "npm:npm" \
  "curl:curl" \
  "unzip:unzip" \
  "fontconfig:fc-cache|fc-list" \
  ca-certificates

ensure_fd_alias
ensure_pylatexenc
ensure_yarn
ensure_tree_sitter_cli

if ! disable_has "go"; then
  log_step "Installing Go toolchain"
  apt_install_packages "golang-go:go"
else
  log_warn "Go disabled: skipping APT package 'golang-go'"
fi

if ! disable_has "rust"; then
  log_step "Installing Rust toolchain"
  apt_install_packages "rustc:rustc" "cargo:cargo"
else
  log_warn "Rust disabled: skipping APT packages 'rustc' and 'cargo'"
fi

install_nerd_font

log_step "Linking nvim config"
"$SCRIPT_DIR/link_nvim_config.sh" --root "$ROOT"

if [[ "$NO_PLUGIN_SYNC" -eq 1 ]]; then
  log_warn "Skipped plugin sync (rerun without --no-plugin-sync to enable)"
else
  log_step "Running headless plugin sync"
  "$SCRIPT_DIR/sync_plugins.sh" --restore-lock="$RESTORE_LOCK"
fi

log_ok "Linux install flow finished"
