#!/bin/sh

/usr/bin/amipc-detecter-langue
/usr/bin/amipc-verifier-bios

CONF_FILE="/etc/amipc/amipc.conf"
[ -f "$CONF_FILE" ] && . "$CONF_FILE"

export SDL_VIDEODRIVER="${AMIPC_VIDEODRIVER:-kmsdrm}"

while true; do
    attract --loglevel info
    STATUS=$?
    if [ "$STATUS" -ne 0 ]; then
        sleep 2
    fi
done
