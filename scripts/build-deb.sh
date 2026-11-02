#!/usr/bin/env bash

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BUILD="$ROOT/build"
DERIVED="$BUILD/DerivedData"
APP="$DERIVED/Build/Products/Release-iphoneos/CarStack.app"
STAGE="$BUILD/package"
DEST="$STAGE/var/jb/Applications/CarStack.app"
VERSION="${VERSION:-0.1.0}"

for tool in xcodebuild ldid dpkg-deb; do
    command -v "$tool" >/dev/null || {
        echo "Missing required tool: $tool" >&2
        exit 1
    }
done

xcodebuild \
    -project "$ROOT/CarStack.xcodeproj" \
    -scheme CarStack \
    -configuration Release \
    -derivedDataPath "$DERIVED" \
    -destination 'generic/platform=iOS' \
    CODE_SIGNING_ALLOWED=NO \
    ONLY_ACTIVE_ARCH=NO \
    build

rm -rf "$STAGE"
mkdir -p "$DEST" "$STAGE/DEBIAN"
cp -a "$APP/." "$DEST/"

# The share extension is not needed for the first CarPlay proof of concept.
rm -rf "$DEST/PlugIns" "$DEST/_CodeSignature" "$DEST/embedded.mobileprovision"

while IFS= read -r binary; do
    ldid -S "$binary"
done < <(find "$DEST/Frameworks" -type f \( -name '*.dylib' -o -perm -111 \) 2>/dev/null || true)

ldid -S"$ROOT/CarStack/CarStack.entitlements" "$DEST/CarStack"

sed "s/@VERSION@/$VERSION/g" "$ROOT/packaging/control" > "$STAGE/DEBIAN/control"
install -m 0755 "$ROOT/packaging/postinst" "$STAGE/DEBIAN/postinst"
install -m 0755 "$ROOT/packaging/prerm" "$STAGE/DEBIAN/prerm"

mkdir -p "$BUILD/packages"
dpkg-deb --root-owner-group -Zxz --build "$STAGE" \
    "$BUILD/packages/com.dogka.carstack_${VERSION}_iphoneos-arm64.deb"

echo "Built $BUILD/packages/com.dogka.carstack_${VERSION}_iphoneos-arm64.deb"
