#!/bin/sh
set -eu

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
BUILDROOT_VERSION="2024.02.6"
BUILDROOT_DIR="${PROJECT_ROOT}/build/buildroot-${BUILDROOT_VERSION}"
EXTERNAL_DIR="${PROJECT_ROOT}/buildroot-external"

if [ "$(uname -s)" != "Linux" ]; then
    echo "Ce script doit etre execute sous Linux (natif, WSL2 ou conteneur)." >&2
    exit 1
fi

mkdir -p "${PROJECT_ROOT}/build"

if [ ! -d "${BUILDROOT_DIR}" ]; then
    echo "Telechargement de Buildroot ${BUILDROOT_VERSION}..."
    curl -L "https://buildroot.org/downloads/buildroot-${BUILDROOT_VERSION}.tar.gz" \
        -o "${PROJECT_ROOT}/build/buildroot-${BUILDROOT_VERSION}.tar.gz"
    tar -xzf "${PROJECT_ROOT}/build/buildroot-${BUILDROOT_VERSION}.tar.gz" -C "${PROJECT_ROOT}/build"
fi

cd "${BUILDROOT_DIR}"

make BR2_EXTERNAL="${EXTERNAL_DIR}" amipc_x86_64_defconfig
make BR2_EXTERNAL="${EXTERNAL_DIR}" -j"$(nproc)"

echo "Build termine. Image disponible dans ${BUILDROOT_DIR}/output/images/"
