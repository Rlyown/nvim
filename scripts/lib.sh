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

need_cmd() { command -v "$1" >/dev/null 2>&1 || die "Missing command: $1"; }

command_exists_any() {
  local cmd
  for cmd in "$@"; do
    if [[ -n "$cmd" ]] && command -v "$cmd" >/dev/null 2>&1; then
      return 0
    fi
  done
  return 1
}

ensure_macos() {
  if [[ "${OSTYPE:-}" != darwin* ]]; then
    die "Unsupported system (OSTYPE=${OSTYPE:-unknown}). This installer supports macOS only."
  fi
}

ensure_linux() {
  if [[ "${OSTYPE:-}" != linux* ]]; then
    die "Unsupported system (OSTYPE=${OSTYPE:-unknown}). This installer supports Linux only."
  fi
}

read_os_release_value() {
  local key="$1"
  if [[ ! -r /etc/os-release ]]; then
    return 1
  fi

  local value
  value="$(awk -F= -v key="$key" '$1 == key { print $2; exit }' /etc/os-release)"
  value="${value%\"}"
  value="${value#\"}"
  printf "%s" "$value"
}

linux_distribution_id() {
  read_os_release_value ID
}

linux_distribution_like() {
  read_os_release_value ID_LIKE
}

linux_distribution_name() {
  local pretty_name
  pretty_name="$(read_os_release_value PRETTY_NAME || true)"
  if [[ -n "$pretty_name" ]]; then
    printf "%s" "$pretty_name"
    return 0
  fi

  local name
  name="$(read_os_release_value NAME || true)"
  if [[ -n "$name" ]]; then
    printf "%s" "$name"
    return 0
  fi

  printf "Linux"
}

is_kali_linux() {
  local distro_id distro_like
  distro_id="$(linux_distribution_id 2>/dev/null || true)"
  distro_like="$(linux_distribution_like 2>/dev/null || true)"
  [[ "${distro_id,,}" == "kali" || "${distro_like,,}" == *"kali"* ]]
}

ensure_apt_based_linux() {
  ensure_linux

  local distro_id distro_like
  distro_id="$(linux_distribution_id 2>/dev/null || true)"
  distro_like="$(linux_distribution_like 2>/dev/null || true)"

  if ! command -v apt-get >/dev/null 2>&1; then
    die "Missing command: apt-get. This installer currently supports Kali and other APT-based Debian-family distributions."
  fi

  if [[ -z "$distro_id" && -z "$distro_like" ]]; then
    return 0
  fi

  if [[ "${distro_id,,}" == "kali" || "${distro_id,,}" == "debian" || "${distro_id,,}" == "ubuntu" || "${distro_like,,}" == *"kali"* || "${distro_like,,}" == *"debian"* || "${distro_like,,}" == *"ubuntu"* ]]; then
    return 0
  fi

  die "Unsupported Linux distribution: $(linux_distribution_name). This installer currently supports Kali and other APT-based Debian-family distributions."
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
    log_warn "Backed up: $target -> ${target}.bak.${ts}"
  fi
}
