#!/bin/sh
set -eu

LANGUE="${1:?Usage: amipc-set-langue <fr|en>}"
CONF_FILE="/etc/amipc/amipc.conf"

sed -i "s/^AMIPC_DEFAULT_LANG=.*/AMIPC_DEFAULT_LANG=${LANGUE}/" "$CONF_FILE"
