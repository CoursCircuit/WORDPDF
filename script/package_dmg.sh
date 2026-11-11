#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."

app=dist/WORDPDF.app
version=$(/usr/libexec/PlistBuddy -c 'Print CFBundleShortVersionString' "$app/Contents/Info.plist")
dmg="$PWD/dist/WORDPDF-$version-universal.dmg"
stage=$(mktemp -d "${TMPDIR:-/tmp}/wordpdf-dmg.XXXXXX")
mountpoint="$stage/mounted"
mounted=false
cleanup() {
  if $mounted; then
    hdiutil detach "$mountpoint" >/dev/null || return
  fi
  rm -rf "$stage"
}
trap cleanup EXIT

mkdir "$stage/payload" "$mountpoint"
ditto --norsrc --noextattr "$app" "$stage/payload/WORDPDF.app"
xattr -cr "$stage/payload/WORDPDF.app"
codesign --verify --strict "$stage/payload/WORDPDF.app"
ln -s /Applications "$stage/payload/Applications"
hdiutil create -ov -volname WORDPDF -fs 'HFS+' -srcfolder "$stage/payload" -format UDZO "$stage/WORDPDF.dmg"
hdiutil verify "$stage/WORDPDF.dmg"
hdiutil attach -readonly -nobrowse -mountpoint "$mountpoint" "$stage/WORDPDF.dmg"
mounted=true
codesign --verify --strict "$mountpoint/WORDPDF.app"
cmp "$mountpoint/WORDPDF.app/Contents/MacOS/WORDPDF" "$app/Contents/MacOS/WORDPDF"
test "$(readlink "$mountpoint/Applications")" = /Applications
hdiutil detach "$mountpoint"
mounted=false
mv -f "$stage/WORDPDF.dmg" "$dmg"
shasum -a 256 "$dmg"
