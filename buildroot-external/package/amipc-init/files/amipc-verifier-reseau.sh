#!/bin/sh
set -eu

CIBLE="${1:-thegamesdb.net}"

if ping -c 1 -W 3 "$CIBLE" >/dev/null 2>&1; then
    echo "Reseau disponible : $CIBLE joignable."
    exit 0
fi

echo "Reseau indisponible : $CIBLE injoignable." >&2
echo "Activez le Wi-Fi depuis le menu Parametres avant de lancer le scraping." >&2
exit 1
