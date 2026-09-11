#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
OUTPUT_DIR="$ROOT_DIR/dist"
NVIM_VERSION="v0.12.4"
BUNDLE_VERSION="$(git -C "$ROOT_DIR" describe --always --dirty)"

usage() {
  cat <<'EOF'
Usage: scripts/build-offline-bundle.sh [options]

Builds a Linux x86_64 Ubuntu 24.04 offline package with Neovim v0.12.4.

Options:
  --output DIR       Write the archive and checksum to DIR (default: dist)
  --version VERSION  Bundle version in the archive name (default: git describe)
  -h, --help         Show this help
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --output) OUTPUT_DIR="$2"; shift 2 ;;
    --version) BUNDLE_VERSION="$2"; shift 2 ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown option: $1" >&2; usage >&2; exit 2 ;;
  esac
done

command -v docker >/dev/null 2>&1 || { echo "docker is required" >&2; exit 1; }
mkdir -p "$OUTPUT_DIR"

docker buildx build \
  --platform linux/amd64 \
  --target bundle \
  --build-arg "NVIM_VERSION=$NVIM_VERSION" \
  --build-arg "BUNDLE_VERSION=$BUNDLE_VERSION" \
  --output "type=local,dest=$OUTPUT_DIR" \
  -f "$ROOT_DIR/docker/offline-builder.Dockerfile" \
  "$ROOT_DIR"

echo "Offline package created in: $OUTPUT_DIR"
