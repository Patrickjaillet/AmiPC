#!/bin/sh
set -eu

FICHIER="${1:?Usage: amipc-set-shader <nom_fichier.glslp>}"
RETROARCH_CONF="/data/retroarch/retroarch.cfg"
SHADER_PATH="/data/retroarch/shaders/amipc/${FICHIER}"

if [ ! -f "$SHADER_PATH" ]; then
    echo "Shader introuvable : $SHADER_PATH" >&2
    exit 1
fi

if grep -q "^video_shader " "$RETROARCH_CONF"; then
    sed -i "s|^video_shader .*|video_shader = \"${SHADER_PATH}\"|" "$RETROARCH_CONF"
else
    echo "video_shader = \"${SHADER_PATH}\"" >> "$RETROARCH_CONF"
fi

if grep -q "^video_shader_enable " "$RETROARCH_CONF"; then
    sed -i "s|^video_shader_enable .*|video_shader_enable = \"true\"|" "$RETROARCH_CONF"
else
    echo 'video_shader_enable = "true"' >> "$RETROARCH_CONF"
fi
