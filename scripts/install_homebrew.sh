#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib.sh"

if command -v brew >/dev/null 2>&1; then
  log_ok "Homebrew 已存在"
  exit 0
fi

if [[ -x /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -x /usr/local/bin/brew ]]; then
  eval "$(/usr/local/bin/brew shellenv)"
fi

if command -v brew >/dev/null 2>&1; then
  log_ok "Homebrew 已存在(已补齐 PATH)"
  exit 0
fi

need_cmd /bin/bash
need_cmd curl

log_warn "检测到未安装 Homebrew，将使用官方脚本进行安装"
log_warn "如果你不希望脚本安装 Homebrew，请先手动安装后再运行 ./install.sh"

NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

if [[ -x /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -x /usr/local/bin/brew ]]; then
  eval "$(/usr/local/bin/brew shellenv)"
fi

command -v brew >/dev/null 2>&1 || die "Homebrew 安装失败或 brew 不在 PATH 中"
log_ok "Homebrew 安装完成"
