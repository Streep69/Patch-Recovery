#!/usr/bin/env bash
set -euo pipefail
MAGISKBOOT="$(dirname "$0")/magiskboot"
IMG="recovery.img"
"$MAGISKBOOT" --unpack "$IMG"
mkdir -p ramdisk/sbin
cp "$MAGISKBOOT" ramdisk/sbin/fastbootd
strip --strip-all ramdisk/sbin/fastbootd 2>/dev/null || true
grep -q "ro.fastbootd.available" ramdisk/default.prop || echo "ro.fastbootd.available=1" >> ramdisk/default.prop
if ! grep -q "service fastbootd" ramdisk/init.rc; then
cat >> ramdisk/init.rc <<'EOF'
service fastbootd /sbin/fastbootd
    class main
    disabled
    seclabel u:r:fastbootd:s0
EOF
fi
"$MAGISKBOOT" --repack "$IMG"
mv new-"$IMG" "$IMG"
echo "✓ fastbootd patch applied"
