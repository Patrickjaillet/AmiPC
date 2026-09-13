#!/bin/sh
set -eu

IMAGE_SOURCE="${1:?Usage: amipc-update <fichier_image.img|url>}"
TARGET_DEVICE="${AMIPC_UPDATE_DEVICE:-/dev/sda}"
TMP_IMAGE="/data/amipc-update.img"

echo "Mise a jour AmiPC vers ${TARGET_DEVICE} depuis ${IMAGE_SOURCE}"

case "$IMAGE_SOURCE" in
    http://*|https://*)
        curl -L "$IMAGE_SOURCE" -o "$TMP_IMAGE"
        ;;
    *)
        TMP_IMAGE="$IMAGE_SOURCE"
        ;;
esac

sync
dd if="$TMP_IMAGE" of="$TARGET_DEVICE" bs=4M conv=fsync status=progress
sync

echo "Mise a jour terminee. Redemarrage requis."
