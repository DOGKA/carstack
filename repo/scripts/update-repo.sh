#!/usr/bin/env bash

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PUBLIC="$ROOT/public"
SOURCE="${1:-$ROOT/../build/packages}"

command -v dpkg-scanpackages >/dev/null || {
    echo "dpkg-scanpackages is required" >&2
    exit 1
}

mkdir -p "$PUBLIC/debs"
rm -f "$PUBLIC/debs/"*.deb
LATEST_DEB="$(ls -t "$SOURCE/"/com.dogka.carstack_*.deb | awk 'NR == 1 { print; exit }')"
cp "$LATEST_DEB" "$PUBLIC/debs/"

(
    cd "$PUBLIC"
    dpkg-scanpackages -m debs /dev/null > Packages
    gzip -9c Packages > Packages.gz
    bzip2 -9c Packages > Packages.bz2

    cat > Release <<EOF
Origin: CarStack
Label: CarStack
Suite: stable
Version: 1.0
Codename: carstack
Architectures: iphoneos-arm64
Components: main
Description: CarStack packages for Dopamine rootless
Date: $(LC_ALL=C date -u '+%a, %d %b %Y %H:%M:%S UTC')
MD5Sum:
EOF

    for file in Packages Packages.gz Packages.bz2; do
        printf ' %s %16s %s\n' \
            "$(md5 -q "$file")" "$(stat -f '%z' "$file")" "$file" >> Release
    done

    printf 'SHA256:\n' >> Release
    for file in Packages Packages.gz Packages.bz2; do
        printf ' %s %16s %s\n' \
            "$(shasum -a 256 "$file" | awk '{print $1}')" \
            "$(stat -f '%z' "$file")" "$file" >> Release
    done
)

echo "Updated repository in $PUBLIC"
