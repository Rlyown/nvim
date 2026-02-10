#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

_is_tty() { [[ -t 1 ]]; }

_c() {
  local code="$1"
  shift
  if _is_tty; then
    printf "\033[%sm%s\033[0m" "$code" "$*"
  else
    printf "%s" "$*"
  fi
}

log_step() { echo "$(_c '1;34' '==>') $*"; }
log_ok() { echo "$(_c '1;32' '✓') $*"; }
log_warn() { echo "$(_c '1;33' '⚠') $*" >&2; }
log_err() { echo "$(_c '1;31' '✗') $*" >&2; }

die() { log_err "$*"; exit 1; }

need_cmd() { command -v "$1" >/dev/null 2>&1 || die "缺少命令: $1"; }

ensure_macos() {
  if [[ "${OSTYPE:-}" != darwin* ]]; then
    die "仅支持 macOS (当前 OSTYPE=${OSTYPE:-unknown})"
  fi
}

realpath_fallback() {
  local p="$1"
  if command -v realpath >/dev/null 2>&1; then
    realpath "$p"
  else
    if command -v python3 >/dev/null 2>&1; then
      python3 -c 'import os,sys; print(os.path.realpath(sys.argv[1]))' "$p"
    else
      perl -MCwd -e 'print Cwd::realpath($ARGV[0])' "$p"
    fi
  fi
}

ensure_dir() { mkdir -p "$1"; }

backup_path() {
  local target="$1"
  if [[ -e "$target" || -L "$target" ]]; then
    local ts
    ts="$(date +%Y%m%d-%H%M%S)"
    mv "$target" "${target}.bak.${ts}"
    log_warn "已备份: $target -> ${target}.bak.${ts}"
  fi
}
