#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib.sh"

source "$SCRIPT_DIR/brew_utils.sh"

RESTORE_LOCK=0
while [[ $# -gt 0 ]]; do
  case "$1" in
    --restore-lock=1|--restore-lock=true) RESTORE_LOCK=1; shift ;;
    --restore-lock=0|--restore-lock=false) RESTORE_LOCK=0; shift ;;
    -h|--help)
      cat <<'EOF'
用法:
  scripts/sync_plugins.sh [--restore-lock=0|1]
EOF
      exit 0
      ;;
    *) die "未知参数: $1" ;;
  esac
done

need_cmd nvim

if [[ "$RESTORE_LOCK" -eq 1 ]]; then
  nvim --headless "+Lazy! restore" +qa
  log_ok "Lazy restore 完成"
else
  nvim --headless "+Lazy! sync" +qa
  log_ok "Lazy sync 完成"
fi

