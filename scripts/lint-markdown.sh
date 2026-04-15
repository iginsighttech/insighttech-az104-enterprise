#!/usr/bin/env bash
# lint-markdown.sh — Run markdownlint locally, mirroring the CI markdown-lint workflow.
#
# Tool priority:
#   1. npx           → markdownlint-cli (no global install required; mirrors CI exactly)
#   2. pymarkdownlnt → pip-installable Python equivalent
#
# Usage:
#   ./scripts/lint-markdown.sh            # lint all *.md files in the repo
#   ./scripts/lint-markdown.sh --fix      # auto-fix where possible (npx only)

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
FIX_FLAG=""
[[ "${1:-}" == "--fix" ]] && FIX_FLAG="--fix"

cd "$REPO_ROOT"

# ── 1. npx (no global install — Node must be available) ──────────────────────
if command -v npx &>/dev/null; then
  echo "[lint-markdown] Using npx markdownlint-cli"
  npx --yes markdownlint-cli ${FIX_FLAG} "**/*.md"
  exit $?
fi

# ── 2. pymarkdownlnt (Python equivalent — pip install pymarkdownlnt) ─────────
if command -v pymarkdown &>/dev/null; then
  echo "[lint-markdown] Using pymarkdownlnt (Python)"
  if [[ -n "$FIX_FLAG" ]]; then
    echo "[lint-markdown] WARNING: --fix is not supported by pymarkdownlnt; running in scan mode"
  fi
  pymarkdown scan --recurse "$REPO_ROOT"
  exit $?
fi

# Try to install pymarkdownlnt automatically if pip3 is present
if command -v pip3 &>/dev/null; then
  echo "[lint-markdown] Installing pymarkdownlnt via pip3..."
  pip3 install --quiet --user pymarkdownlnt
  if command -v pymarkdown &>/dev/null; then
    pymarkdown scan --recurse "$REPO_ROOT"
    exit $?
  fi
fi

echo "[lint-markdown] ERROR: No supported markdown linter found."
echo "  Install one of:"
echo "    node/npx  (exact CI match)"
echo "    pip3 install pymarkdownlnt"
exit 1
