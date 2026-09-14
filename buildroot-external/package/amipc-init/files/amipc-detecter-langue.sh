#!/bin/sh
set -eu

CONF_FILE="/etc/amipc/amipc.conf"
MARQUEUR="/data/.amipc-langue-initialisee"

[ -f "$MARQUEUR" ] && exit 0

LOCALE_SYSTEME="${LANG:-}"

case "$LOCALE_SYSTEME" in
    en*)
        sed -i "s/^AMIPC_DEFAULT_LANG=.*/AMIPC_DEFAULT_LANG=en/" "$CONF_FILE"
        ;;
    *)
        sed -i "s/^AMIPC_DEFAULT_LANG=.*/AMIPC_DEFAULT_LANG=fr/" "$CONF_FILE"
        ;;
esac

mkdir -p /data
touch "$MARQUEUR"
