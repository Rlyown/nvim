#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

usage() {
  cat <<'EOF'
用法:
  ./install.sh [选项]

选项:
  --no-plugin-sync   不执行 nvim headless 同步插件
  --restore-lock     使用 lazy-lock.json 进行 Lazy! restore (否则 Lazy! sync)
  -h, --help         显示帮助

说明:
  - 仅支持 macOS
  - 依赖通过 Homebrew 安装
  - 默认会安装 Kitty (若已安装则跳过)
  - 默认会安装 Nerd Font (JetBrainsMono Nerd Font)
EOF
}

NO_PLUGIN_SYNC=0
RESTORE_LOCK=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --no-plugin-sync) NO_PLUGIN_SYNC=1; shift ;;
    --restore-lock) RESTORE_LOCK=1; shift ;;
    -h|--help) usage; exit 0 ;;
    --with-optional|--with-fonts)
      echo "提示：$1 已不再需要（现在会默认安装全部依赖/字体）" >&2
      shift
      ;;
    *)
      echo "未知参数: $1" >&2
      usage
      exit 1
      ;;
  esac
done

mkdir -p "$ROOT_DIR/scripts"

source "$ROOT_DIR/scripts/lib.sh"

ensure_macos

log_step "开始 macOS 安装流程"
"$ROOT_DIR/scripts/install_macos.sh" \
  --root "$ROOT_DIR" \
  $( [[ "$NO_PLUGIN_SYNC" -eq 1 ]] && echo "--no-plugin-sync" ) \
  $( [[ "$RESTORE_LOCK" -eq 1 ]] && echo "--restore-lock" )

log_ok "完成"
