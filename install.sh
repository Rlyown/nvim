#!/usr/bin/env bash
set -euo pipefail
ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
export NVIM_CONFIG_ROOT="$ROOT_DIR"
DRY_RUN=0
NO_PLUGIN_SYNC=0
while [[ $# -gt 0 ]]; do
  case "$1" in
    --profile|--languages|--features)
      [[ $# -ge 2 ]] || { echo "$1 requires a value" >&2; exit 2; }
      case "$1" in
        --profile) export NVIM_PROFILE="$2" ;;
        --languages) export NVIM_LANGUAGES="$2" ;;
        --features) export NVIM_FEATURES="$2" ;;
      esac
      shift 2 ;;
    --disable)
      export NVIM_DISABLE_LANGS="${NVIM_DISABLE_LANGS:+$NVIM_DISABLE_LANGS,}$2"; shift 2 ;;
    --disable-*)
      export NVIM_DISABLE_LANGS="${NVIM_DISABLE_LANGS:+$NVIM_DISABLE_LANGS,}${1#--disable-}"; shift ;;
    --dry-run) DRY_RUN=1; shift ;;
    --no-plugin-sync) NO_PLUGIN_SYNC=1; shift ;;
    --restore-lock) shift ;;
    --with-fonts) export NVIM_FEATURES="${NVIM_FEATURES:+$NVIM_FEATURES,}fonts"; shift ;;
    --with-optional) export NVIM_FEATURES="${NVIM_FEATURES:+$NVIM_FEATURES,}fonts,kitty"; shift ;;
    -h|--help)
      cat <<'HELP'
Usage: ./install.sh [--profile minimal|developer] [--languages cpp,go,rust,python]
                    [--features dap,ai,-images] [--dry-run] [--no-plugin-sync]
Compatibility: --disable LIST, --disable-LANG, --restore-lock, --with-fonts.
Locked versions are restored by default; explicitly run scripts/sync_plugins.sh --restore-lock=0 to update.
Requires Neovim 0.12.4. dry-run makes no changes. The selection is saved to the local override file.
HELP
      exit 0 ;;
    *) echo "Unknown option: $1" >&2; exit 2 ;;
  esac
done
command -v nvim >/dev/null || { echo 'Install Neovim 0.12.4 first to use the shared Lua configuration resolver.' >&2; exit 1; }
TASK_DIR="$(mktemp -d)"
export NVIM_PLAN_OUTPUT="$TASK_DIR/plan.json"
export NVIM_PACKAGES_OUTPUT="$TASK_DIR/packages"
export NVIM_INSTALL_OS="$(uname -s)"
export NVIM_LOG_FILE="$TASK_DIR/nvim.log"
nvim --headless -u NONE -i NONE -l "$ROOT_DIR/scripts/config-plan.lua"
cat "$NVIM_PLAN_OUTPUT"
[[ "$DRY_RUN" -eq 0 ]] || exit 0
[[ "${NVIM_OFFLINE:-0}" != 1 ]] || { echo 'Installation is unavailable in offline mode' >&2; exit 1; }
nvim --headless -u NONE -i NONE -l "$ROOT_DIR/scripts/system-packages.lua"
packages=()
while IFS= read -r package; do packages+=("$package"); done < "$NVIM_PACKAGES_OUTPUT"
case "$NVIM_INSTALL_OS" in
  Darwin) bash "$ROOT_DIR/scripts/install_macos.sh" "$NVIM_PACKAGES_OUTPUT" ;;
  Linux) bash "$ROOT_DIR/scripts/install_linux.sh" "$NVIM_PACKAGES_OUTPUT" ;;
  *) echo 'Only macOS and APT-based Linux are supported' >&2; exit 1 ;;
esac
bash "$ROOT_DIR/scripts/link_nvim_config.sh" --root "$ROOT_DIR"
# 保存所选能力，确保安装结果和下一次启动一致。
nvim --headless -u NONE -i NONE -l "$ROOT_DIR/scripts/save-config.lua"
if [[ "$NO_PLUGIN_SYNC" -eq 0 ]]; then
  NVIM_MAINTENANCE=1 nvim --headless -u "$ROOT_DIR/init.lua" -i NONE '+lua dofile(vim.env.NVIM_CONFIG_ROOT .. "/scripts/install-runtime.lua")'
fi
