#!/usr/bin/env bash
set -euo pipefail
MAGISKBOOT="$(dirname "$0")/magiskboot"
IMG="recovery.img"

# Unpack image
"$MAGISKBOOT" --unpack "$IMG"

# Add fastbootd binary (copy magiskboot & strip symbols to save space)
mkdir -p ramdisk/sbin
cp "$MAGISKBOOT" ramdisk/sbin/fastbootd
strip --strip-all ramdisk/sbin/fastbootd 2>/dev/null || true

# Ensure property so TWRP shows fastbootd
grep -q "ro.fastbootd.available" ramdisk/default.prop ||   echo "ro.fastbootd.available=1" >> ramdisk/default.prop

# Add init service if missing
if ! grep -q "service fastbootd" ramdisk/init.rc; then
cat >> ramdisk/init.rc <<'EOF'
service fastbootd /sbin/fastbootd
    class main
    disabled
    seclabel u:r:fastbootd:s0
EOF
fi

# Repack
"$MAGISKBOOT" --repack "$IMG"
mv new-"$IMG" "$IMG"
echo "✓ fastbootd patch applied"
