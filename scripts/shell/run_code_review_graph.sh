#!/usr/bin/env bash
set -euo pipefail

echo "[code-review-graph] project root:"
pwd

if ! command -v code-review-graph >/dev/null 2>&1; then
  echo "[ERROR] code-review-graph command not found."
  echo "Install with: pipx install code-review-graph"
  exit 1
fi

echo "[code-review-graph] status"
code-review-graph status || true

echo "[code-review-graph] detect changes"
code-review-graph detect-changes --brief || true

echo "[code-review-graph] done."
