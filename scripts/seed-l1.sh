#!/usr/bin/env bash
# Prepara el sandbox de L1: estructura trunk/branches/tags y HEAD=3.
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
LAB="L1"
SANDBOX_ROOT="/tmp/svn-sandboxes/$LAB"
REPO_DIR="$SANDBOX_ROOT/repo"
URL_SANDBOX="file://$REPO_DIR"
PLANTILLA="$REPO_ROOT/plantilla-monitor"
WC_DIR="$REPO_ROOT/practicas-svn/$LAB/monitor-servicios"

rm -rf "$SANDBOX_ROOT" "$REPO_ROOT/practicas-svn/$LAB"
mkdir -p "$SANDBOX_ROOT"
svnadmin create "$REPO_DIR"

TMP_DIR="$(mktemp -d "$SANDBOX_ROOT/build.XXXXXX")"
trap 'rm -rf "$TMP_DIR"' EXIT
IMPORT_DIR="$TMP_DIR/import"
BUILD_WC="$TMP_DIR/wc"

mkdir -p "$IMPORT_DIR/trunk/config" "$IMPORT_DIR/trunk/docs" \
         "$IMPORT_DIR/trunk/examples" "$IMPORT_DIR/trunk/src" \
         "$IMPORT_DIR/branches" "$IMPORT_DIR/tags"
cp "$PLANTILLA/README.md" "$IMPORT_DIR/trunk/README.md"
cp "$PLANTILLA/config/servicios.conf" "$IMPORT_DIR/trunk/config/servicios.conf"
cp "$PLANTILLA/docs/notas_umbrales.md" "$IMPORT_DIR/trunk/docs/notas_umbrales.md"
cp "$PLANTILLA/examples/caso_legacy.json" "$IMPORT_DIR/trunk/examples/caso_legacy.json"
cp "$PLANTILLA/src/evaluador.py" "$IMPORT_DIR/trunk/src/evaluador.py"

# r1: carga inicial (timeout_ms de pagos todavía en 1000).
sed -i 's/^timeout_ms=2000$/timeout_ms=1000/' "$IMPORT_DIR/trunk/config/servicios.conf"
svn import -q "$IMPORT_DIR" "$URL_SANDBOX" -m "Carga inicial del Monitor de servicios"

svn checkout -q "$URL_SANDBOX/trunk" "$BUILD_WC"

# r2: ajuste del timeout de pagos.
sed -i 's/^timeout_ms=1000$/timeout_ms=2000/' "$BUILD_WC/config/servicios.conf"
svn commit -q -m "Ajusta timeout_ms de pagos a 2000" "$BUILD_WC"

# r3: incorporación del ejemplo normal.
cp "$PLANTILLA/examples/caso_normal.json" "$BUILD_WC/examples/caso_normal.json"
svn add -q "$BUILD_WC/examples/caso_normal.json"
svn commit -q -m "Incorpora examples/caso_normal.json" "$BUILD_WC"

cat > "$SANDBOX_ROOT/lab.env" <<EOF
export URL_SANDBOX_ALUMNO="file://$REPO_DIR"
export REV_INICIAL=1
export REV_CONFIG=2
export REV_EJEMPLO=3
EOF

mkdir -p "$(dirname "$WC_DIR")"
svn checkout -q "$URL_SANDBOX/trunk" "$WC_DIR"

printf 'L1 listo: %s/trunk (HEAD=3); copia de trabajo en %s\n' "$URL_SANDBOX" "$WC_DIR"
