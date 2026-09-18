#!/bin/sh
# 1Retro Sync — NextUI Tool Pak
# Syncs game saves with the 1Retro cloud service.
#
# On first launch the device shows a QR code, a device ID and a pairing code.
# Scan the code, or open 1retro.com/device and enter the device ID, to pair.

PAK_DIR="$(dirname "$0")"
PAK_NAME="$(basename "$PAK_DIR")"
PAK_NAME="${PAK_NAME%.*}"
[ -f "$USERDATA_PATH/$PAK_NAME/debug" ] && set -x

rm -f "$LOGS_PATH/$PAK_NAME.txt"
exec >>"$LOGS_PATH/$PAK_NAME.txt"
exec 2>&1

echo "$0" "$@"
cd "$PAK_DIR" || exit 1
mkdir -p "$USERDATA_PATH/$PAK_NAME"

# NextUI platforms (tg5040 / tg5050 / my355) are 64-bit; MinUI's rg35xxplus
# family (RG35XX Plus/H, RG40XX H/V, CubeXX) runs a 32-bit userland.
architecture=arm
if uname -m | grep -q '64'; then
    architecture=arm64
fi

export HOME="$USERDATA_PATH/$PAK_NAME"
# minui-presenter and minui-list are bundled per platform.
export PATH="$PAK_DIR/bin/$PLATFORM:$PAK_DIR:$PATH"

# Keep the device awake while pairing/syncing; presenter screens are managed
# by the binary itself.
cleanup() {
    rm -f /tmp/stay_awake
    killall minui-presenter >/dev/null 2>&1 || true
    killall minui-list >/dev/null 2>&1 || true
    # Both of those stop keymon while they own the screen and resume it on the
    # way out. If one of them died without getting that far, the device would
    # be left with no volume or brightness keys until a reboot.
    killall -CONT keymon.elf >/dev/null 2>&1 || true
}
trap cleanup EXIT INT TERM
touch /tmp/stay_awake

# All UI (menu, auth QR, progress, results) is handled by the binary via the
# bundled minui-list and minui-presenter. State lives under
# $USERDATA_PATH/$PAK_NAME.
# NextUI/MinUI export SDCARD_PATH; not every platform mounts at /mnt/SDCARD.
"$PAK_DIR/bin/$architecture/1retro-nextui" --root "${SDCARD_PATH:-/mnt/SDCARD}" --state-dir "$USERDATA_PATH/$PAK_NAME"
