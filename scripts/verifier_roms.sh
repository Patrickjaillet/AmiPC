#!/bin/sh
set -eu

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
SYSTEME="${1:-amiga500}"
ROMS_DIR="${ROOT_DIR}/roms/${SYSTEME}"
OUTPUT_FILE="${ROOT_DIR}/docs/roms-${SYSTEME}.sha256"

if [ ! -d "$ROMS_DIR" ]; then
    echo "Repertoire introuvable : $ROMS_DIR" >&2
    exit 1
fi

find "$ROMS_DIR" -type f -name "*.zip" -print0 | sort -z | xargs -0 -r sha256sum > "$OUTPUT_FILE"

TOTAL=$(wc -l < "$OUTPUT_FILE")
echo "Sommes de controle generees pour $TOTAL fichiers dans $OUTPUT_FILE"
