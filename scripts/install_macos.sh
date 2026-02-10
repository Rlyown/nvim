#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib.sh"
source "$SCRIPT_DIR/brew_utils.sh"

usage() {
  cat <<'EOF'
用法:
  scripts/install_macos.sh --root <repo_root> [选项]

选项:
  --no-plugin-sync   不执行 nvim headless 同步插件
  --restore-lock     使用 lazy-lock.json 进行 Lazy! restore
EOF
}

ROOT=""
NO_PLUGIN_SYNC=0
RESTORE_LOCK=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --root) ROOT="$2"; shift 2 ;;
    --no-plugin-sync) NO_PLUGIN_SYNC=1; shift ;;
    --restore-lock) RESTORE_LOCK=1; shift ;;
    -h|--help) usage; exit 0 ;;
    --with-optional|--with-fonts)
      log_warn "参数 $1 已不再需要（现在会默认安装全部依赖/字体）"
      shift
      ;;
    *) die "未知参数: $1" ;;
  esac
done

[[ -n "$ROOT" ]] || { usage; exit 2; }
ROOT="$(realpath_fallback "$ROOT")"

ensure_macos

log_step "检查/安装 Homebrew"
"$SCRIPT_DIR/install_homebrew.sh"

need_cmd brew

log_step "更新 Homebrew"
brew update

log_step "安装 Kitty"
brew_install_cask kitty

log_step "安装必需依赖"
brew_install_formula neovim
brew_install_formula lua@5.1
brew_install_formula ripgrep
brew_install_formula fd
brew_install_formula lazygit
brew_install_formula gnu-sed

log_step "安装附加依赖(默认安装，避免缺失导致功能异常)"
brew_install_formula bear
brew_install_formula pngpaste
brew_install_formula node
brew_install_formula yarn
brew_install_formula trash

log_step "安装 Nerd Font (JetBrainsMono，默认安装避免图标显示异常)"
brew tap homebrew/cask-fonts >/dev/null 2>&1 || true
brew_install_cask font-jetbrains-mono-nerd-font

log_step "配置 nvim 配置目录"
"$SCRIPT_DIR/link_nvim_config.sh" --root "$ROOT"

if [[ "$NO_PLUGIN_SYNC" -eq 1 ]]; then
  log_warn "已跳过插件同步：可用 ./install.sh 去执行"
else
  log_step "执行 nvim headless 同步插件"
  "$SCRIPT_DIR/sync_plugins.sh" --restore-lock="$RESTORE_LOCK"
fi

log_ok "macOS 安装流程完成"
