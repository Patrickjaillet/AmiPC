#!/bin/sh
set -e

BOARD_DIR="$(dirname "$0")"
BINARIES_DIR="$1"

support/scripts/genimage.sh -c "${BOARD_DIR}/genimage.cfg"

echo "Image AmiPC generee dans ${BINARIES_DIR}"
