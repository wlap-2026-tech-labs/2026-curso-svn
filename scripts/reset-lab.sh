#!/usr/bin/env bash
# Reinicia L1, L2 o L3 desde cualquier directorio de trabajo.
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

case "${1:-}" in
  L1) LAB="L1"; SEED="seed-l1.sh" ;;
  L2) LAB="L2"; SEED="seed-l2.sh" ;;
  L3) LAB="L3"; SEED="seed-l3.sh" ;;
  *)
    printf 'Uso: bash scripts/reset-lab.sh <L1|L2|L3>\n' >&2
    exit 2
    ;;
esac

rm -rf "/tmp/svn-sandboxes/$LAB" "$REPO_ROOT/practicas-svn/$LAB"
bash "$REPO_ROOT/scripts/$SEED"
