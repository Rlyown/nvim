#!/usr/bin/env bash
set -euo pipefail
ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
export NVIM_CONFIG_ROOT="$ROOT_DIR"
DRY_RUN=0
NO_PLUGIN_SYNC=0
SELECTION_PROVIDED=0
while [[ $# -gt 0 ]]; do
  case "$1" in
    --full)
      SELECTION_PROVIDED=1
      export NVIM_PROFILE=developer
      export NVIM_LANGUAGES=cpp,go,rust,python,lua,shell,web,data,docker,asm,csv,sql,markdown,tex
      export NVIM_FEATURES=dap,ai,remote,images,fonts,kitty,-formulas
      shift ;;
    --profile|--languages|--features)
      SELECTION_PROVIDED=1
      [[ $# -ge 2 ]] || { echo "$1 requires a value" >&2; exit 2; }
      case "$1" in
        --profile) export NVIM_PROFILE="$2" ;;
        --languages) export NVIM_LANGUAGES="$2" ;;
        --features) export NVIM_FEATURES="$2" ;;
      esac
      shift 2 ;;
    --disable)
      SELECTION_PROVIDED=1
      export NVIM_DISABLE_LANGS="${NVIM_DISABLE_LANGS:+$NVIM_DISABLE_LANGS,}$2"; shift 2 ;;
    --disable-*)
      SELECTION_PROVIDED=1
      export NVIM_DISABLE_LANGS="${NVIM_DISABLE_LANGS:+$NVIM_DISABLE_LANGS,}${1#--disable-}"; shift ;;
    --dry-run) DRY_RUN=1; shift ;;
    --no-plugin-sync) NO_PLUGIN_SYNC=1; shift ;;
    --with-fonts) SELECTION_PROVIDED=1; export NVIM_FEATURES="${NVIM_FEATURES:+$NVIM_FEATURES,}fonts"; shift ;;
    --with-optional) SELECTION_PROVIDED=1; export NVIM_FEATURES="${NVIM_FEATURES:+$NVIM_FEATURES,}fonts,kitty"; shift ;;
    -h|--help)
      cat <<'HELP'
Install this Neovim configuration.

  ./install.sh --full       Install all languages and features
  ./install.sh              Install the saved selection, or start the setup
                            wizard when no selection has been saved
  ./install.sh --dry-run    Preview packages and tools without installing
  ./install.sh --help       Show this help

Full setup includes C/C++, Go, Rust, Python, Lua, Shell, Web, data formats,
Docker, Assembly, CSV, SQL, Markdown, LaTeX/VimTeX, debugging, AI, remote
tools and images. VimTeX is installed without TeX Live/MacTeX or latexmk;
compilation requires an existing TeX toolchain on PATH. Requires Neovim 0.12.4+,
internet, and Homebrew on macOS. Add --no-plugin-sync to install system packages
without syncing plugins.

With no saved selection or explicit options, the interactive wizard lets you
choose Full, Developer, Minimal, or a custom setup.

Advanced selection: --profile minimal|developer, --languages LIST,
--features LIST, --disable LIST, or --disable-NAME. The selected setup is saved.
HELP
      exit 0 ;;
    *) echo "Unknown option: $1" >&2; exit 2 ;;
  esac
done
command -v nvim >/dev/null || { echo 'Install Neovim 0.12.4 first to use the shared Lua configuration resolver.' >&2; exit 1; }
if [[ "$SELECTION_PROVIDED" -eq 0 && ! -f "$ROOT_DIR/lua/config/local.lua" && -z "${NVIM_PROFILE:-}${NVIM_LANGUAGES+x}${NVIM_FEATURES+x}${NVIM_DISABLE_LANGS+x}${NVIM_ENABLE_LANGS+x}" ]]; then
  source "$ROOT_DIR/scripts/config-wizard.sh"
  nvim_config_wizard
fi
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
# Save selected capabilities so installation and the next startup use the same configuration.
nvim --headless -u NONE -i NONE -l "$ROOT_DIR/scripts/save-config.lua"
if [[ "$NO_PLUGIN_SYNC" -eq 0 ]]; then
  NVIM_MAINTENANCE=1 nvim --headless -u "$ROOT_DIR/init.lua" -i NONE '+lua dofile(vim.env.NVIM_CONFIG_ROOT .. "/scripts/install-runtime.lua")'
fi
