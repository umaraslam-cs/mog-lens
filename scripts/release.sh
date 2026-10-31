#!/usr/bin/env bash
#
# Archives Mogscan and exports a distribution IPA for TestFlight.
#
#   scripts/release.sh              # archive + export, auto-bumps the build number
#   scripts/release.sh --build 42   # pin an explicit build number
#   scripts/release.sh --no-bump    # reuse the current build number
#   scripts/release.sh --upload     # also upload via the App Store Connect API
#
# The IPA lands in build/release/ and the path is printed at the end. Without
# --upload, open Transporter and drag it in.
#
# Signing comes from the project, not from this script. Passing
# PROVISIONING_PROFILE_SPECIFIER on the xcodebuild command line applies it to
# every target in the build, including RevenueCat's SPM target, which rejects
# it outright: "RevenueCat_RevenueCat does not support provisioning profiles".
# Both configurations already pin `Mogscan Distribution` for sdk=iphoneos*, so
# the override bought nothing anyway. The export plist below still names the
# profile — that step is app-target-only.
#
# Xcode's own Organizer upload is broken for this team — it shows the team as
# "Unknown Name (QVA3ZF63S6)" and fails. That is a known dead end, already
# investigated; use Transporter or --upload instead. See CLAUDE.md.

set -euo pipefail

cd "$(dirname "$0")/.."

SCHEME="Mogscan"
PROJECT="Mogscan.xcodeproj"
BUNDLE_ID="com.mogscan.app"
TEAM_ID="QVA3ZF63S6"
DIST_PROFILE="Mogscan Distribution"

OUT_DIR="build/release"
ARCHIVE="$OUT_DIR/$SCHEME.xcarchive"
EXPORT_PLIST="$OUT_DIR/ExportOptions.plist"

# App Store Connect API key, for --upload. The .p8 lives outside the repo, in
# ~/.appstoreconnect/private_keys/AuthKey_<KEY_ID>.p8 — never commit it.
API_KEY_ID="3Q2Q478U4X"
API_ISSUER_ID="ba780232-3edb-4f6b-93f1-3960436bb333"

BUMP=1
UPLOAD=0
EXPLICIT_BUILD=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --build)   EXPLICIT_BUILD="$2"; BUMP=0; shift 2 ;;
    --no-bump) BUMP=0; shift ;;
    --upload)  UPLOAD=1; shift ;;
    -h|--help) sed -n '2,20p' "$0"; exit 0 ;;
    *) echo "unknown option: $1" >&2; exit 1 ;;
  esac
done

current_build() {
  xcodebuild -project "$PROJECT" -scheme "$SCHEME" -showBuildSettings -configuration Release 2>/dev/null \
    | awk -F' = ' '/ CURRENT_PROJECT_VERSION =/ {print $2; exit}'
}

VERSION=$(xcodebuild -project "$PROJECT" -scheme "$SCHEME" -showBuildSettings -configuration Release 2>/dev/null \
  | awk -F' = ' '/ MARKETING_VERSION =/ {print $2; exit}')

if [[ -n "$EXPLICIT_BUILD" ]]; then
  BUILD="$EXPLICIT_BUILD"
elif [[ $BUMP -eq 1 ]]; then
  # App Store Connect rejects a build number it has already seen, so every
  # upload needs a new one.
  BUILD=$(( $(current_build) + 1 ))
  agvtool new-version -all "$BUILD" >/dev/null
  echo "==> build number $(( BUILD - 1 )) -> $BUILD"
else
  BUILD=$(current_build)
fi

echo "==> Mogscan $VERSION ($BUILD)"

rm -rf "$ARCHIVE"
mkdir -p "$OUT_DIR"

echo "==> archiving"
xcodebuild archive \
  -project "$PROJECT" \
  -scheme "$SCHEME" \
  -configuration Release \
  -destination 'generic/platform=iOS' \
  -archivePath "$ARCHIVE" \
  | grep -E '^\*\*|error:|warning: (Provisioning|Signing)' || true

[[ -d "$ARCHIVE" ]] || { echo "archive failed" >&2; exit 1; }

cat > "$EXPORT_PLIST" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>method</key>
    <string>app-store-connect</string>
    <key>teamID</key>
    <string>$TEAM_ID</string>
    <key>signingStyle</key>
    <string>manual</string>
    <key>provisioningProfiles</key>
    <dict>
        <key>$BUNDLE_ID</key>
        <string>$DIST_PROFILE</string>
    </dict>
    <key>uploadSymbols</key>
    <true/>
    <key>destination</key>
    <string>export</string>
</dict>
</plist>
PLIST

echo "==> exporting ipa"
xcodebuild -exportArchive \
  -archivePath "$ARCHIVE" \
  -exportPath "$OUT_DIR" \
  -exportOptionsPlist "$EXPORT_PLIST" \
  | grep -E '^\*\*|error:' || true

IPA=$(ls -t "$OUT_DIR"/*.ipa 2>/dev/null | head -1)
[[ -n "$IPA" ]] || { echo "export failed — no ipa produced" >&2; exit 1; }

echo
echo "==> $IPA  ($(du -h "$IPA" | cut -f1))"

if [[ $UPLOAD -eq 0 ]]; then
  echo "==> open Transporter and drag in the file above, or re-run with --upload"
  open -a Transporter "$IPA" 2>/dev/null || true
  exit 0
fi

# Two ways to authenticate, in order of preference.
#
# 1. App Store Connect API key — the .p8 at the path below. Apple only lets a key
#    be downloaded once, so if it is missing it has to be re-downloaded by the
#    account holder or a new key generated.
# 2. Apple ID plus an app-specific password (appleid.apple.com -> Sign-In and
#    Security -> App-Specific Passwords), passed in the environment:
#
#       APPLE_ID=you@example.com APP_PASSWORD=abcd-efgh-ijkl-mnop scripts/release.sh --upload
KEY_PATH="$HOME/.appstoreconnect/private_keys/AuthKey_$API_KEY_ID.p8"

if [[ -f "$KEY_PATH" ]]; then
  AUTH=(--apiKey "$API_KEY_ID" --apiIssuer "$API_ISSUER_ID")
  echo "==> authenticating with API key $API_KEY_ID"
elif [[ -n "${APPLE_ID:-}" && -n "${APP_PASSWORD:-}" ]]; then
  AUTH=(-u "$APPLE_ID" -p "@env:APP_PASSWORD")
  echo "==> authenticating as $APPLE_ID"
else
  cat >&2 <<MSG

Cannot upload — no credentials.

  Either put the API key at:
    $KEY_PATH

  Or pass an Apple ID and app-specific password:
    APPLE_ID=you@example.com APP_PASSWORD=xxxx-xxxx-xxxx-xxxx scripts/release.sh --upload --no-bump

The IPA is built and ready either way:
  $IPA
Drag it into Transporter to upload by hand.
MSG
  exit 1
fi

echo "==> validating"
xcrun altool --validate-app -f "$IPA" -t ios "${AUTH[@]}"

echo "==> uploading to App Store Connect"
xcrun altool --upload-app -f "$IPA" -t ios "${AUTH[@]}"

echo "==> uploaded. Processing takes a few minutes before it appears in TestFlight."
