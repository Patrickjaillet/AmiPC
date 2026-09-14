#!/bin/sh
set -e

BOARD_DIR="$(dirname "$0")"
BINARIES_DIR="$1"

EFI_PART_SRC_DIR="${BINARIES_DIR}/efi-part"
EFI_PART_IMAGE="${BINARIES_DIR}/efi-part.vfat"

if [ ! -d "${EFI_PART_SRC_DIR}" ]; then
    echo "Repertoire EFI introuvable : ${EFI_PART_SRC_DIR}" >&2
    echo "Verifiez que BR2_TARGET_GRUB2_X86_64_EFI est active." >&2
    exit 1
fi

rm -f "${EFI_PART_IMAGE}"
dd if=/dev/zero of="${EFI_PART_IMAGE}" bs=1M count=64
"${HOST_DIR}/sbin/mkfs.vfat" "${EFI_PART_IMAGE}"
"${HOST_DIR}/bin/mcopy" -i "${EFI_PART_IMAGE}" -s "${EFI_PART_SRC_DIR}"/* ::/

support/scripts/genimage.sh -c "${BOARD_DIR}/genimage.cfg"

echo "Image AmiPC generee dans ${BINARIES_DIR}"
