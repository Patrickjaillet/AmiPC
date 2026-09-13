#!/bin/sh
set -eu

VALEUR="${1:?Usage: amipc-set-luminosite <0-100>}"
BACKLIGHT_DIR="/sys/class/backlight"

if [ -d "$BACKLIGHT_DIR" ]; then
    for PERIPH in "$BACKLIGHT_DIR"/*; do
        [ -d "$PERIPH" ] || continue
        MAX="$(cat "${PERIPH}/max_brightness")"
        CIBLE=$(( MAX * VALEUR / 100 ))
        echo "$CIBLE" > "${PERIPH}/brightness" 2>/dev/null || true
    done
fi
