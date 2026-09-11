#!/usr/bin/env bash
set -euo pipefail

ARCHIVE="${1:?Usage: tests/test_offline_bundle.sh /path/to/nvim-offline-*.tar.zst}"
[[ -f "$ARCHIVE" ]] || { echo "Archive not found: $ARCHIVE" >&2; exit 1; }
command -v docker >/dev/null 2>&1 || { echo "docker is required" >&2; exit 1; }
command -v zstd >/dev/null 2>&1 || { echo "zstd is required" >&2; exit 1; }

TEMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TEMP_DIR"' EXIT

zstd -dc "$ARCHIVE" | tar -xf - -C "$TEMP_DIR"

docker run --platform linux/amd64 --rm --network none -v "$TEMP_DIR:/bundle" ubuntu:24.04 bash -ceu '
  /bundle/bin/nvim-offline --headless "+lua assert(vim.version().major == 0 and vim.version().minor == 12 and vim.version().patch == 4)" +qa
  test -f /bundle/manifest.json
  test "$(grep -c "linux-x86_64-ubuntu-24.04" /bundle/manifest.json)" -eq 1
'

echo "offline bundle smoke test passed"
