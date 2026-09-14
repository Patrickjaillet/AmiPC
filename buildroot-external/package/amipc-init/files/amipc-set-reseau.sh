#!/bin/sh
set -eu

ETAT="${1:?Usage: amipc-set-reseau <on|off>}"

case "$ETAT" in
    on)
        ifup wlan0 2>/dev/null || true
        ;;
    off)
        ifdown wlan0 2>/dev/null || true
        ;;
    *)
        echo "Valeur invalide : $ETAT (attendu on|off)" >&2
        exit 1
        ;;
esac
