#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib.sh"

usage() {
  cat <<'EOF'
用法:
  scripts/link_nvim_config.sh --root <repo_root>
EOF
}

ROOT=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    --root) ROOT="$2"; shift 2 ;;
    -h|--help) usage; exit 0 ;;
    *) die "未知参数: $1" ;;
  esac
done
[[ -n "$ROOT" ]] || { usage; exit 2; }

ROOT="$(realpath_fallback "$ROOT")"
local_config_root="${XDG_CONFIG_HOME:-$HOME/.config}"
target="${local_config_root}/nvim"

if [[ "$(realpath_fallback "$ROOT")" == "$(realpath_fallback "$target" 2>/dev/null || true)" ]]; then
  log_ok "当前仓库已位于目标目录: $target"
  exit 0
fi

ensure_dir "$local_config_root"

if [[ -L "$target" ]]; then
  local link_to
  link_to="$(readlink "$target")"
  if [[ "$(realpath_fallback "$link_to")" == "$ROOT" ]]; then
    log_ok "已存在正确的符号链接: $target -> $ROOT"
    exit 0
  fi
fi

backup_path "$target"
ln -s "$ROOT" "$target"
log_ok "已创建符号链接: $target -> $ROOT"

