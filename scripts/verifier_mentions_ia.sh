#!/bin/sh
set -eu

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"

MOTIFS='claude|anthropic|chatgpt|openai|copilot|gpt-[0-9]'

RESULTATS="$(grep -rEil --exclude-dir=.git --exclude-dir=build --exclude-dir=.claude \
    --exclude="verifier_mentions_ia.sh" \
    --exclude="verifier-conformite.yml" \
    --exclude="ROADMAP.md" \
    --exclude="CHANGELOG.md" \
    --exclude="PUBLICATION.md" \
    --exclude=".gitignore" \
    -- "$MOTIFS" "$ROOT_DIR" || true)"

if [ -n "$RESULTATS" ]; then
    echo "Mentions d'IA generative detectees dans :" >&2
    echo "$RESULTATS" >&2
    exit 1
fi

echo "Aucune mention d'IA generative detectee dans le depot."
