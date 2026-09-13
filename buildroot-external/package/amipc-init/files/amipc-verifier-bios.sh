#!/bin/sh
set -eu

BIOS_DIR="/data/retroarch/system/amiga"
REFERENCE_FILE="/etc/amipc/bios-reference.txt"
RAPPORT_FILE="/data/amipc-bios-etat.txt"

MANQUANTS=0
INCORRECTS=0

: > "$RAPPORT_FILE"

while IFS=';' read -r NOM TAILLE_ATTENDUE; do
    [ -z "$NOM" ] && continue
    CHEMIN="${BIOS_DIR}/${NOM}"
    if [ ! -f "$CHEMIN" ]; then
        echo "MANQUANT ${NOM}" >> "$RAPPORT_FILE"
        MANQUANTS=$((MANQUANTS + 1))
        continue
    fi
    TAILLE_REELLE=$(wc -c < "$CHEMIN" | tr -d ' ')
    if [ "$TAILLE_REELLE" != "$TAILLE_ATTENDUE" ]; then
        echo "TAILLE_INVALIDE ${NOM} attendu=${TAILLE_ATTENDUE} reel=${TAILLE_REELLE}" >> "$RAPPORT_FILE"
        INCORRECTS=$((INCORRECTS + 1))
    fi
done < "$REFERENCE_FILE"

TOTAL_PROBLEMES=$((MANQUANTS + INCORRECTS))

if [ "$TOTAL_PROBLEMES" -gt 0 ]; then
    echo "AVERTISSEMENT" > /data/.amipc-bios-avertissement
    echo "${MANQUANTS} BIOS manquant(s), ${INCORRECTS} BIOS de taille invalide. Voir ${RAPPORT_FILE}" >> /data/.amipc-bios-avertissement
else
    rm -f /data/.amipc-bios-avertissement
fi

exit 0
