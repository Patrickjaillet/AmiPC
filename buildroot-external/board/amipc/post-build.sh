#!/bin/sh
set -e

BOARD_DIR="$(dirname "$0")"
TARGET_DIR="$1"

mkdir -p "${TARGET_DIR}/etc/systemd/system/getty@tty1.service.d"
cat > "${TARGET_DIR}/etc/systemd/system/getty@tty1.service.d/autologin.conf" <<EOF
[Service]
ExecStart=
ExecStart=-/sbin/agetty --autologin root --noclear %I \$TERM
EOF

if [ -e "${TARGET_DIR}/etc/inittab" ]; then
    grep -q amipc-start "${TARGET_DIR}/etc/inittab" || \
        sed -i '/::sysinit:/a ::respawn:/usr/bin/amipc-start' "${TARGET_DIR}/etc/inittab"
fi

mkdir -p "${TARGET_DIR}/opt/amipc"
