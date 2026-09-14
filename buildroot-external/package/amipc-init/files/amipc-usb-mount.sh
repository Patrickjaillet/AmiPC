#!/bin/sh
set -eu

ACTION="$1"
DEVNAME="$2"
MOUNT_BASE="/media"
MOUNT_POINT="${MOUNT_BASE}/${DEVNAME}"

case "$ACTION" in
    add)
        mkdir -p "$MOUNT_POINT"
        mount "/dev/${DEVNAME}" "$MOUNT_POINT" || rmdir "$MOUNT_POINT"
        if [ -d "${MOUNT_POINT}/amipc/roms" ]; then
            mkdir -p /data/roms
            cp -rn "${MOUNT_POINT}/amipc/roms/." /data/roms/
        fi
        if [ -d "${MOUNT_POINT}/amipc/bios" ]; then
            mkdir -p /data/bios
            cp -rn "${MOUNT_POINT}/amipc/bios/." /data/bios/
        fi
        ;;
    remove)
        umount "$MOUNT_POINT" 2>/dev/null || true
        rmdir "$MOUNT_POINT" 2>/dev/null || true
        ;;
esac
