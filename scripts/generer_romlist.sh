#!/bin/sh
set -eu

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
SYSTEME="${1:-amiga500}"
ROMS_DIR="${ROOT_DIR}/roms/${SYSTEME}"
OUTPUT_FILE="${ROOT_DIR}/config/attract/romlists/${SYSTEME}.txt"

if [ ! -d "$ROMS_DIR" ]; then
    echo "Repertoire introuvable : $ROMS_DIR" >&2
    exit 1
fi

mkdir -p "$(dirname "$OUTPUT_FILE")"

echo "#Name;Title;Emulator;CloneOf;Year;Manufacturer;Category;Players;Rotation;Control;Status;DisplayCount;DisplayType;AltRomname;AltTitle;Extra;Buttons;Favourite;Tags;PlayedCount;PlayedTime;FileIsAvailable" > "$OUTPUT_FILE"

find "$ROMS_DIR" -type f -name "*.zip" | sort | while IFS= read -r FICHIER; do
    NOM_BASE="$(basename "$FICHIER" .zip)"
    TITRE="$(printf '%s' "$NOM_BASE" | sed -E 's/\s*\([0-9]{4}[^)]*\).*//' | sed 's/[[:space:]]*$//')"
    ANNEE="$(printf '%s' "$NOM_BASE" | grep -oE '\(([0-9]{4})' | head -n1 | tr -d '(' || true)"
    printf '%s;%s;%s;;%s;;;1;0;joy1way;good;1;;;;;;0;;0;0;1\n' "$NOM_BASE" "$TITRE" "$SYSTEME" "$ANNEE" >> "$OUTPUT_FILE"
done

TOTAL=$(($(wc -l < "$OUTPUT_FILE") - 1))
echo "Romlist genere pour ${SYSTEME} : ${TOTAL} jeux dans ${OUTPUT_FILE}"
