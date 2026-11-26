#!/bin/bash
# Builds dist/UpwellEveryday.dmg (run from the repo root on macOS).
set -e
ROOT="$(cd "$(dirname "$0")/.." && pwd)"; cd "$ROOT"
T="$(mktemp -d)"; D="$T/dmg"; mkdir -p "$D/.files" dist
cp mac/upwell_everyday.py mac/install_mac.sh mac/uninstall_mac.sh "$D/.files/"
printf '#!/bin/bash\nbash "$(dirname "$0")/.files/install_mac.sh"\necho; echo "Done! You can close this window and eject the Upwell Everyday disk."\n' > "$D/Install Upwell Everyday.command"
printf '#!/bin/bash\nbash "$(dirname "$0")/.files/uninstall_mac.sh"\n' > "$D/Uninstall Upwell Everyday.command"
cat > "$D/Read Me.txt" <<'TXT'
Upwell Everyday - a new 4K motivational wallpaper every day.

1. Right-click "Install Upwell Everyday.command" and choose Open.
   (The first time, macOS warns it's from an unidentified developer; click Open.)
2. If asked to let Terminal control "System Events", click OK.
3. Today's wallpaper appears right away. New photos are downloaded every week.

To remove it, right-click "Uninstall Upwell Everyday.command" and choose Open.
TXT
chmod +x "$D"/*.command "$D"/.files/*.sh
hdiutil create -volname "Upwell Everyday" -srcfolder "$D" -ov -format UDRW -size 20m "$T/rw.dmg" >/dev/null
hdiutil attach -nobrowse "$T/rw.dmg" -mountpoint "$T/mnt" >/dev/null
ICON="$ROOT/icons/icon.icns"
setico() { osascript -l JavaScript -e "ObjC.import('AppKit'); \$.NSWorkspace.sharedWorkspace.setIconForFileOptions(\$.NSImage.alloc.initWithContentsOfFile('$ICON'),'$1',0)" >/dev/null; }
setico "$T/mnt/Install Upwell Everyday.command"; setico "$T/mnt/Uninstall Upwell Everyday.command"; setico "$T/mnt"
cp "$ICON" "$T/mnt/.VolumeIcon.icns"
hdiutil detach "$T/mnt" >/dev/null
rm -f dist/UpwellEveryday.dmg
hdiutil convert "$T/rw.dmg" -format UDZO -o dist/UpwellEveryday.dmg >/dev/null
setico "$ROOT/dist/UpwellEveryday.dmg"
echo "Built dist/UpwellEveryday.dmg"
