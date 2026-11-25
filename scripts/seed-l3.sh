#!/usr/bin/env bash
# Prepara el sandbox de L3: estado válido, defecto en r2 y cambio válido en r3.
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
LAB="L3"
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
cp "$PLANTILLA/docs/notas_umbrales.md" "$IMPORT_DIR/trunk/docs/reglas_umbrales.md"
cp "$PLANTILLA/examples/caso_normal.json" "$IMPORT_DIR/trunk/examples/caso_normal.json"
cp "$PLANTILLA/src/evaluador.py" "$IMPORT_DIR/trunk/src/evaluador.py"
cat > "$IMPORT_DIR/trunk/examples/caso_aviso_pagos.json" <<'JSON'
{
  "servicio": "pagos",
  "latencia_ms": 450,
  "estado_esperado": "AVISO"
}
JSON

# r1: umbrales coherentes en pagos (aviso=400, crítico=1200).
sed -i 's/^umbral_aviso_ms=500$/umbral_aviso_ms=400/' "$IMPORT_DIR/trunk/config/servicios.conf"
svn import -q "$IMPORT_DIR" "$URL_SANDBOX" \
  -m "Carga inicial del Monitor de servicios (L3: umbrales validos)"

svn checkout -q "$URL_SANDBOX/trunk" "$BUILD_WC"

# r2: defecto preparado, umbral_aviso_ms >= umbral_critico_ms en pagos.
sed -i 's/^umbral_critico_ms=1200$/umbral_critico_ms=200/' "$BUILD_WC/config/servicios.conf"
svn commit -q -m "Defecto: umbral_critico_ms=200 en pagos rompe la regla de umbrales" "$BUILD_WC"

# r3: cambio válido posterior que debe conservarse.
cat >> "$BUILD_WC/docs/reglas_umbrales.md" <<'MD'
## Escalado ante estado CRÍTICO
- Si el servicio `pagos` registra estado CRÍTICO durante dos comprobaciones consecutivas, avisar al equipo de guardia.
MD
svn commit -q -m "Anade bloque de escalado ante estado CRITICO en docs/reglas_umbrales.md" "$BUILD_WC"

cat > "$SANDBOX_ROOT/lab.env" <<EOF
export URL_SANDBOX_ALUMNO="file://$REPO_DIR"
export REV_BASE_VALIDA=1
export REV_DEFECTO=2
export REV_CAMBIO_VALIDO=3
EOF

mkdir -p "$(dirname "$WC_DIR")"
svn checkout -q "$URL_SANDBOX/trunk" "$WC_DIR"

printf 'L3 listo: %s/trunk (HEAD=3, defecto en r2); copia de trabajo en %s\n' "$URL_SANDBOX" "$WC_DIR"
