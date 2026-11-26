#!/bin/bash
# Builds "dist/Upwell Everyday.app" and a drag-to-Applications DMG (run from repo root on macOS).
# Usage: mac/build_app.sh [dmg-name]
set -e
ROOT="$(cd "$(dirname "$0")/.." && pwd)"; cd "$ROOT"
NAME="${1:-UpwellEveryday.dmg}"
APP="dist/Upwell Everyday.app"
rm -rf build/mac "$APP"
python3 -m PyInstaller --noconfirm --windowed --name "Upwell Everyday" \
  --icon "$ROOT/icons/icon.icns" --osx-bundle-identifier com.upwelleveryday.app \
  --distpath dist --workpath build/mac/work --specpath build/mac mac/upwell_everyday.py
P="$APP/Contents/Info.plist"
plutil -replace NSAppleEventsUsageDescription -string "Upwell Everyday uses System Events to set your desktop wallpaper." "$P"
plutil -replace LSUIElement -bool true "$P"
plutil -replace CFBundleShortVersionString -string "${VERSION:-1.0.0}" "$P"
codesign --force --deep --sign - "$APP"

T="$(mktemp -d)"; mkdir "$T/src"
cp -R "$APP" "$T/src/"
ln -s /Applications "$T/src/Applications"
cp icons/icon.icns "$T/src/.VolumeIcon.icns"
for i in 1 2 3 4 5; do hdiutil create -volname "Upwell Everyday" -srcfolder "$T/src" -ov -format UDRW "$T/rw.dmg" >/dev/null && break; echo "hdiutil busy, retrying"; sleep 5; done
MNT="$T/mnt"; hdiutil attach -nobrowse "$T/rw.dmg" -mountpoint "$MNT" >/dev/null
SetFile -a C "$MNT" 2>/dev/null || osascript -l JavaScript -e "ObjC.import('AppKit'); \$.NSWorkspace.sharedWorkspace.setIconForFileOptions(\$.NSImage.alloc.initWithContentsOfFile('$ROOT/icons/icon.icns'),'$MNT',0)" >/dev/null
sync; for i in 1 2 3 4 5; do hdiutil detach "$MNT" >/dev/null 2>&1 && break; sleep 3; [ $i -ge 3 ] && hdiutil detach -force "$MNT" >/dev/null 2>&1 && break; done
rm -f "dist/$NAME"
hdiutil convert "$T/rw.dmg" -format UDZO -o "dist/$NAME" >/dev/null
echo "Built $APP and dist/$NAME"
