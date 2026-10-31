#!/bin/bash
#
# Build MogLens and run it, on a simulator or on the connected iPhone.
#
#   scripts/run.sh                  # booted simulator, or iPhone 17 Pro if none
#   scripts/run.sh "iPhone 16"      # named simulator, booting it if needed
#   scripts/run.sh --device         # connected iPhone (Vision needs real hardware)
#   scripts/run.sh --device "Umar"  # name-matched, when several are connected
#   scripts/run.sh --list           # list run targets and exit
#   scripts/run.sh --clean          # wipe DerivedData first
#
# Installs are always fresh: the old copy is uninstalled before the new one goes
# on, so a stale binary or a stale provisioning profile can never be what runs.
#
# Build products go to .build/derived, which .gitignore already covers.

set -euo pipefail
cd "$(dirname "$0")/.."

SCHEME=MogLens
PROJECT=MogLens.xcodeproj
BUNDLE_ID=com.moglens.app
DERIVED=.build/derived
DEFAULT_SIMULATOR="iPhone 17 Pro"

clean=false
physical=false
list=false
wanted=""

for arg in "$@"; do
    case "$arg" in
        --clean) clean=true ;;
        --device|-d) physical=true ;;
        --list|-l) list=true ;;
        -*) echo "unknown flag: $arg" >&2; exit 1 ;;
        *) wanted="$arg" ;;
    esac
done

die() { echo "$@" >&2; exit 1; }

# ---------------------------------------------------------------- target lookup

# Connected iPhones as "identifier<TAB>name". Newer Xcode lists simulators here
# too, hence the Reality column filter — without it a plain --device run picked
# whichever simulator sorted first and failed on "Install Application is not
# supported by this device". "unavailable" rows are remembered-but-unplugged
# devices, which cannot be installed to either.
list_devices() {
    xcrun devicectl list devices 2>/dev/null | awk '
        /unavailable/ { next }
        !/physical/ { next }
        {
            # Two identifier shapes: a UUID for a device paired over the
            # network, and the 8-16 hex UDID an iPhone plugged in over USB
            # reports — the one in this phone\x27s provisioning profile.
            match($0, /[0-9A-Fa-f]{8}-([0-9A-Fa-f]{4}-){3}[0-9A-Fa-f]{12}|[0-9A-Fa-f]{8}-[0-9A-Fa-f]{16}/)
            if (RSTART == 0) next          # header and blank lines carry neither
            ident = substr($0, RSTART, RLENGTH)
            name = $0
            sub(/[[:space:]][[:space:]]+.*/, "", name)
            print ident "\t" name
        }'
}

# Simulators as "udid<TAB>name", booted ones first so a plain run reuses whatever
# is already on screen.
list_simulators() {
    xcrun simctl list devices available 2>/dev/null | awk '
        /^-- / { ios = /^-- iOS/; next }
        !ios { next }
        {
            match($0, /\(([0-9A-F]{8}-([0-9A-F]{4}-){3}[0-9A-F]{12})\)/)
            if (RSTART == 0) next
            udid = substr($0, RSTART + 1, RLENGTH - 2)
            name = $0
            sub(/^[[:space:]]+/, "", name)
            sub(/[[:space:]]+\(.*/, "", name)
            print (/Booted/ ? 0 : 1) "\t" udid "\t" name
        }' | sort -s -k1,1n | cut -f2,3
}

# One row from a "id<TAB>name" list: name match if asked for, else the first row.
# An exact name wins over a substring, so "iPhone 17 Pro" never lands on the Max.
pick() {
    local rows=$1 label=$2 exact
    if [ -n "$wanted" ]; then
        exact=$(printf '%s\n' "$rows" | awk -F'\t' -v w="$wanted" 'tolower($2) == tolower(w)')
        rows=${exact:-$(printf '%s\n' "$rows" | grep -i -F "$wanted" || true)}
    fi
    [ -n "$rows" ] || die "no $label${wanted:+ matching '$wanted'}"
    printf '%s\n' "$rows" | head -1
}

if [ "$list" = true ]; then
    echo "devices:"
    list_devices | cut -f2 | sed 's/^/  /' || true
    echo "simulators:"
    list_simulators | cut -f2 | sed 's/^/  /'
    exit 0
fi

if [ "$physical" = true ]; then
    devices=$(list_devices)
    [ -n "$devices" ] || die "no connected iPhone — unlock it, trust this Mac, then: scripts/run.sh --list"
    row=$(pick "$devices" "connected iPhone")
    sdk=iphoneos
else
    # Booted simulators sort first, so a plain run reuses what is already open;
    # with nothing booted and no name given, fall back to the default device.
    if [ -z "$wanted" ] && [ -z "$(xcrun simctl list devices booted | grep -F Booted || true)" ]; then
        wanted=$DEFAULT_SIMULATOR
    fi
    row=$(pick "$(list_simulators)" "simulator")
    sdk=iphonesimulator
fi

target_id=${row%%$'\t'*}
target_name=${row#*$'\t'}
echo "==> $target_name ($target_id)"

# ---------------------------------------------------------------------- build

if [ "$clean" = true ]; then
    echo "==> cleaning $DERIVED"
    rm -rf "$DERIVED"
fi

# Devices go by name, not id: xcodebuild wants the hardware UDID, which is not
# the CoreDevice identifier devicectl reports. Simulator UDIDs match either way.
if [ "$physical" = true ]; then
    destination="platform=iOS,name=$target_name"
else
    destination="id=$target_id"
fi

echo "==> building"
xcodebuild -project "$PROJECT" -scheme "$SCHEME" \
    -destination "$destination" -derivedDataPath "$DERIVED" build |
    grep -E "error:|warning:|BUILD" || true

app="$DERIVED/Build/Products/Debug-$sdk/$SCHEME.app"
[ -d "$app" ] || die "build produced no app at $app"

# ------------------------------------------------------------ install and launch

if [ "$physical" = true ]; then
    echo "==> installing (fresh)"
    xcrun devicectl device uninstall app --device "$target_id" "$BUNDLE_ID" >/dev/null 2>&1 || true
    xcrun devicectl device install app --device "$target_id" "$app" >/dev/null
    xcrun devicectl device process launch \
        --device "$target_id" --terminate-existing "$BUNDLE_ID" >/dev/null
    echo "==> launched on $target_name"
else
    xcrun simctl boot "$target_id" 2>/dev/null || true
    open -a Simulator

    echo "==> installing (fresh)"
    xcrun simctl terminate "$target_id" "$BUNDLE_ID" 2>/dev/null || true
    xcrun simctl uninstall "$target_id" "$BUNDLE_ID" 2>/dev/null || true
    xcrun simctl install "$target_id" "$app"
    xcrun simctl launch "$target_id" "$BUNDLE_ID"
fi
