#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib.sh"

APT_GET=()

init_apt_cmd() {
  if [[ "${#APT_GET[@]}" -gt 0 ]]; then
    return 0
  fi

  need_cmd apt-get

  if [[ "${EUID:-$(id -u)}" -eq 0 ]]; then
    APT_GET=(apt-get)
  else
    need_cmd sudo
    APT_GET=(sudo apt-get)
  fi
}

apt_package_installed() {
  dpkg -s "$1" >/dev/null 2>&1
}

apt_update() {
  init_apt_cmd
  "${APT_GET[@]}" update
}

apt_package_satisfied() {
  local package_name="$1"
  local command_spec="$2"
  local command_names=()
  local found_command=""
  local cmd

  if [[ -n "$command_spec" ]]; then
    IFS='|' read -r -a command_names <<< "$command_spec"
    for cmd in "${command_names[@]}"; do
      if [[ -n "$cmd" ]] && command -v "$cmd" >/dev/null 2>&1; then
        found_command="$cmd"
        break
      fi
    done
  fi

  if [[ -n "$found_command" ]]; then
    log_ok "Already available in PATH: $package_name ($found_command)"
    return 0
  fi

  if apt_package_installed "$package_name"; then
    log_ok "Already installed: $package_name"
    return 0
  fi

  return 1
}

apt_install_packages() {
  init_apt_cmd

  local missing=()
  local spec
  local package_name
  local command_spec

  for spec in "$@"; do
    package_name="$spec"
    command_spec=""

    if [[ "$spec" == *":"* ]]; then
      package_name="${spec%%:*}"
      command_spec="${spec#*:}"
    fi

    if ! apt_package_satisfied "$package_name" "$command_spec"; then
      missing+=("$package_name")
    fi
  done

  if [[ "${#missing[@]}" -eq 0 ]]; then
    return 0
  fi

  "${APT_GET[@]}" install -y "${missing[@]}"

  for package_name in "${missing[@]}"; do
    log_ok "Installed: $package_name"
  done
}

run_with_privileges() {
  if [[ "${EUID:-$(id -u)}" -eq 0 ]]; then
    "$@"
  else
    need_cmd sudo
    sudo "$@"
  fi
}
