#!/bin/sh
set -eu

SOURCE_DIR="$(cd "$(dirname "$0")/.." && pwd)/bios/amiga"
TARGET_DIR="$(cd "$(dirname "$0")/.." && pwd)/config/retroarch/system/amiga"

mkdir -p "$TARGET_DIR"

copier() {
    SRC="$1"
    DST="$2"
    if [ -f "${SOURCE_DIR}/${SRC}" ]; then
        cp "${SOURCE_DIR}/${SRC}" "${TARGET_DIR}/${DST}"
        echo "OK   ${SRC} -> ${DST}"
    else
        echo "ABSENT ${SRC}" >&2
    fi
}

copier "kick34005.A500" "kick34005.A500"
copier "kick37175.A500" "kick37175.A500"
copier "kick34005.CDTV" "kick34005.CDTV"
copier "amiga-ext-130-cdtv.rom" "amiga-ext-130-cdtv.rom"
copier "kick37350.A600" "kick37350.A600"
copier "kick40063.A600" "kick40063.A600"
copier "kick39106.A1200" "kick39106.A1200"
copier "kick40068.A1200" "kick40068.A1200"
copier "kick40068.A4000" "kick40068.A4000"
copier "kick40060.CD32" "kick40060.CD32"
copier "kick40060.CD32.ext" "kick40060.CD32.ext"
copier "amiga-ext-310-cd32.rom" "amiga-ext-310-cd32.rom"
copier "aros-rom.bin" "aros-rom.bin"
copier "aros-ext.bin" "aros-ext.bin"

echo "Installation des BIOS terminee dans ${TARGET_DIR}"
