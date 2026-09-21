#!/bin/sh
#
# Pin the minui-presenter and minui-list builds this pak bundles.
#
# Writes pak/minui.lock: the versions to fetch, and the SHA-256 of every file
# fetched, so the release workflow can verify what it downloads instead of
# trusting whatever a tag points at on the day. A GitHub release asset can be
# deleted and re-uploaded and a tag can be moved, so without the lock the bytes
# that reach someone's handheld are not decided by anything we reviewed.
#
# Upgrade to new upstream versions:
#
#   ./scripts/pin-minui.sh 0.14.0 0.16.0
#
# Re-pin the versions already in the lock (which is how you find out whether
# upstream moved them under you):
#
#   ./scripts/pin-minui.sh
#
# The diff is the review: two version numbers and ten hashes.

set -eu

LOCK="$(dirname "$0")/../pak/minui.lock"

# platform:flavour, and the only place this mapping lives. The "-nextui" builds
# draw in the user's NextUI theme instead of white-on-black, and go only to the
# platforms NextUI runs on (h700 is the community NextUI port for Anbernic's
# H700 handhelds). Everything else runs MinUI and takes the MinUI build, which
# renders unthemed there, where a NextUI build might not load at all.
TARGETS="tg5040:tg5040-nextui tg5050:tg5050-nextui h700:h700-nextui my355:my355 rg35xxplus:rg35xxplus"

# Linux has sha256sum; macOS has shasum. This script runs on whichever laptop
# is doing the upgrade.
sha256() {
    if command -v sha256sum >/dev/null 2>&1; then
        sha256sum "$1" | cut -d' ' -f1
    else
        shasum -a 256 "$1" | cut -d' ' -f1
    fi
}

lock_value() {
    [ -f "$LOCK" ] || return 0
    awk -v key="$1" '$1 == key { print $2 }' "$LOCK"
}

presenter_version="${1:-$(lock_value presenter_version)}"
list_version="${2:-$(lock_value list_version)}"

if [ -z "$presenter_version" ] || [ -z "$list_version" ]; then
    echo "usage: $0 <minui-presenter version> <minui-list version>" >&2
    echo "(no lock to read current versions from)" >&2
    exit 2
fi

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

echo "pinning minui-presenter $presenter_version and minui-list $list_version" >&2

{
    echo "# The SHA-256 of every minui-presenter and minui-list build this pak"
    echo "# bundles, and the versions they come from."
    echo "#"
    echo "# Written by ./scripts/pin-minui.sh, so do not edit it by hand. The"
    echo "# release workflow fetches exactly these files and refuses any that do"
    echo "# not match, because a moved tag or a re-uploaded asset would otherwise"
    echo "# change what ships to a device without changing anything here."
    echo "#"
    echo "# Both tools are MIT, and their LICENSE files ship inside the pak."
    echo "presenter_version $presenter_version"
    echo "list_version $list_version"

    for target in $TARGETS; do
        platform="${target%%:*}"
        flavour="${target#*:}"
        for tool in minui-presenter minui-list; do
            case "$tool" in
                minui-presenter) version="$presenter_version" ;;
                *) version="$list_version" ;;
            esac
            url="https://github.com/josegonzalez/$tool/releases/download/$version/$tool-$flavour"
            echo "  fetching $tool-$flavour" >&2
            curl -fsSL -o "$tmp/asset" "$url"
            echo "sha256 $tool $platform $flavour $(sha256 "$tmp/asset")"
        done
    done
} >"$LOCK.new"

mv "$LOCK.new" "$LOCK"
echo "wrote $LOCK" >&2
