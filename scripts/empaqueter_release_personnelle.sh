#!/bin/sh
set -eu

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
VERSION="$(cat "${ROOT_DIR}/VERSION" | tr -d '[:space:]')"
NOM_ARCHIVE="amipc-personnel-v${VERSION}.tar.gz"
DEST_DIR="${ROOT_DIR}/build/release-personnelle"
IMAGE_TROUVEE="$(find "${ROOT_DIR}/build" -maxdepth 3 -name amipc.img 2>/dev/null | head -n1 || true)"

echo "Preparation de la release personnelle AmiPC v${VERSION}."
echo "ATTENTION : cette archive contient les BIOS et les jeux presents dans bios/ et roms/."
echo "Elle est strictement destinee a un usage prive et NE DOIT JAMAIS etre publiee sur GitHub"
echo "ni sur tout depot ou service public, en raison des droits d'auteur associes aux BIOS Kickstart"
echo "et aux jeux commerciaux Amiga."
echo ""

mkdir -p "$DEST_DIR"

if [ -z "$IMAGE_TROUVEE" ]; then
    echo "Aucune image amipc.img trouvee dans build/. Compilez d'abord l'image (scripts/construire_image.sh)." >&2
    exit 1
fi

TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

mkdir -p "${TMP_DIR}/amipc-personnel"
cp "$IMAGE_TROUVEE" "${TMP_DIR}/amipc-personnel/amipc.img"
cp -r "${ROOT_DIR}/bios" "${TMP_DIR}/amipc-personnel/bios"
cp -r "${ROOT_DIR}/roms" "${TMP_DIR}/amipc-personnel/roms"
cp "${ROOT_DIR}/VERSION" "${TMP_DIR}/amipc-personnel/VERSION"
cp "${ROOT_DIR}/CHANGELOG.md" "${TMP_DIR}/amipc-personnel/CHANGELOG.md"

tar -czf "${DEST_DIR}/${NOM_ARCHIVE}" -C "$TMP_DIR" amipc-personnel

echo "Archive personnelle generee : ${DEST_DIR}/${NOM_ARCHIVE}"
echo "Ce fichier est ignore par Git (cf. .gitignore) et doit rester hors de toute plateforme publique."
