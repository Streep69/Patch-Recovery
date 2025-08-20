#!/usr/bin/env bash
set -euo pipefail
MAGISKBOOT="$(dirname "$0")/magiskboot"
IMG="recovery.img"
"$MAGISKBOOT" --unpack "$IMG"
for f in $(grep -alR "fstab" ramdisk 2>/dev/null || true); do
  sed -Ei 's/,?(avb|verify|support_scfs|overlayfs)[^, ]*//g' "$f"
done
"$MAGISKBOOT" --repack "$IMG"
mv new-"$IMG" "$IMG"
echo "✓ fstab cleaned"
