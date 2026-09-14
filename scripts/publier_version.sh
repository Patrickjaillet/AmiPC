#!/bin/sh
set -eu

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
VERSION_FILE="${ROOT_DIR}/VERSION"
CHANGELOG_FILE="${ROOT_DIR}/CHANGELOG.md"

TYPE="${1:?Usage: publier_version.sh <major|minor|patch>}"

VERSION_ACTUELLE="$(cat "$VERSION_FILE" | tr -d '[:space:]')"
MAJOR="$(echo "$VERSION_ACTUELLE" | cut -d. -f1)"
MINOR="$(echo "$VERSION_ACTUELLE" | cut -d. -f2)"
PATCH="$(echo "$VERSION_ACTUELLE" | cut -d. -f3)"

case "$TYPE" in
    major)
        MAJOR=$((MAJOR + 1)); MINOR=0; PATCH=0
        ;;
    minor)
        MINOR=$((MINOR + 1)); PATCH=0
        ;;
    patch)
        PATCH=$((PATCH + 1))
        ;;
    *)
        echo "Type invalide : $TYPE (attendu major|minor|patch)" >&2
        exit 1
        ;;
esac

NOUVELLE_VERSION="${MAJOR}.${MINOR}.${PATCH}"
DATE_JOUR="$(date +%Y-%m-%d)"

if ! grep -q "^## \[Non publié\]" "$CHANGELOG_FILE"; then
    echo "Aucune section [Non publié] trouvée dans CHANGELOG.md : ajoutez vos modifications avant publication." >&2
    exit 1
fi

sed -i "s/^## \[Non publié\]/## [${NOUVELLE_VERSION}] - ${DATE_JOUR}/" "$CHANGELOG_FILE"
printf '%s\n' "$NOUVELLE_VERSION" > "$VERSION_FILE"

echo "Version publiée : ${NOUVELLE_VERSION}"
echo "Pensez a : git add -A && git commit -m \"Version ${NOUVELLE_VERSION}\" && git tag v${NOUVELLE_VERSION}"
