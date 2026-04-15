#!/usr/bin/env bash
# scan-secrets.sh — Run secret scanning locally, mirroring the CI secret-scan workflow.
#
# The CI workflow uses gitleaks/gitleaks-action@v2 with fetch-depth: 0 (full history).
#
# Tool priority:
#   1. gitleaks binary → exact CI tool; scans full git history
#   2. detect-secrets  → pip-installable Python alternative (working tree only)
#
# Usage:
#   ./scripts/scan-secrets.sh             # scan full git history (mirrors CI)
#   ./scripts/scan-secrets.sh --staged    # scan only staged files (pre-commit mode)

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
STAGED="${1:-}"

cd "$REPO_ROOT"

# ── Helper: run gitleaks in the correct mode ──────────────────────────────────
run_gitleaks() {
  local gitleaks_cmd="$1"
  if [[ "$STAGED" == "--staged" ]]; then
    echo "[scan-secrets] Scanning staged files with gitleaks..."
    $gitleaks_cmd protect --staged --source "$REPO_ROOT" --verbose
  else
    echo "[scan-secrets] Scanning full git history with gitleaks (mirrors CI)..."
    $gitleaks_cmd detect --source "$REPO_ROOT" --verbose
  fi
}

# ── 1. Local gitleaks binary ──────────────────────────────────────────────────
if command -v gitleaks &>/dev/null; then
  echo "[scan-secrets] Using local gitleaks binary"
  run_gitleaks gitleaks
  exit $?
fi

# ── 2. detect-secrets (Python — pip install detect-secrets) ──────────────────
# Note: detect-secrets scans the working tree only, not full git history.
# It does not replicate gitleaks CI behaviour exactly, but catches secrets in
# current file content and provides a deterministic baseline for review.
if command -v detect-secrets &>/dev/null || (command -v pip3 &>/dev/null && pip3 install --quiet --user detect-secrets 2>/dev/null); then
  echo "[scan-secrets] Using detect-secrets (Python — working tree only, not full history)"
  if [[ "$STAGED" == "--staged" ]]; then
    echo "[scan-secrets] NOTE: detect-secrets does not support --staged; scanning working tree"
  fi
  detect-secrets scan "$REPO_ROOT" --all-files | tee /tmp/detect-secrets-results.json
  python3 - <<'EOF'
import json, sys
with open('/tmp/detect-secrets-results.json') as f:
    results = json.load(f)
total = sum(len(v) for v in results.get('results', {}).values())
if total > 0:
    print(f"\n[scan-secrets] FAILED: {total} potential secret(s) detected. Review /tmp/detect-secrets-results.json")
    sys.exit(1)
else:
    print("\n[scan-secrets] PASSED: No secrets detected.")
EOF
  exit $?
fi

echo "[scan-secrets] ERROR: No supported secret scanner found."
echo "  Install one of:"
echo "    gitleaks binary  https://github.com/gitleaks/gitleaks/releases  (exact CI match)"
echo "    pip3 install detect-secrets"
exit 1
