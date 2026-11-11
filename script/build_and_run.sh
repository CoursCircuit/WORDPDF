#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."

case "${1:-}" in
  ""|--build-only|--verify) ;;
  *) echo "Usage: $0 [--build-only|--verify]" >&2; exit 2 ;;
esac

mkdir -p .build dist
sdk="$(xcrun --sdk macosx --show-sdk-path)"
staging=$(mktemp -d "$PWD/.build/stage.XXXXXX")
trap 'rm -rf "$staging"' EXIT
app="$staging/WORDPDF.app"
mkdir -p "$app/Contents/MacOS" "$app/Contents/Resources"
cp Sources/Info.plist "$app/Contents/"
cp Sources/Export.applescript Assets/WORDPDF.icns "$app/Contents/Resources/"
for arch in arm64 x86_64; do
  version=$(/usr/libexec/PlistBuddy -c "Print LSMinimumSystemVersionByArchitecture:$arch" Sources/Info.plist)
  xcrun swiftc -O -module-cache-path "$PWD/.build/ModuleCache" -sdk "$sdk" -target "$arch-apple-macos$version" \
    Sources/main.swift -o "$staging/WORDPDF-$arch"
done
xcrun lipo -create "$staging/WORDPDF-arm64" "$staging/WORDPDF-x86_64" \
  -output "$app/Contents/MacOS/WORDPDF"

xattr -cr "$app"
identity="${WORDPDF_SIGN_IDENTITY:--}"
if [[ "$identity" == "Developer ID Application:"* ]]; then
  codesign --sign "$identity" --options runtime --timestamp \
    --entitlements Sources/Entitlements.plist "$app"
else
  codesign --sign "$identity" --entitlements Sources/Entitlements.plist "$app"
fi
codesign --verify --strict "$app"
rm -rf dist/WORDPDF.app
mv "$app" dist/
if [[ "${1:-}" != --build-only ]]; then
  open "$PWD/dist/WORDPDF.app"
  if [[ "${1:-}" == --verify ]]; then
    sleep 1
    pgrep -fx "$PWD/dist/WORDPDF.app/Contents/MacOS/WORDPDF"
  fi
fi
