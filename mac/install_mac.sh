#!/bin/bash
# Installs Upwell Everyday on macOS (runs at login + every day at 07:00).
set -e
DIR="$HOME/Library/Application Support/UpwellEveryday"
mkdir -p "$DIR"
cp "$(dirname "$0")/upwell_everyday.py" "$DIR/"
python3 -m venv "$DIR/venv"
"$DIR/venv/bin/pip" install -q --upgrade pip pillow
PLIST="$HOME/Library/LaunchAgents/com.upwelleveryday.wallpaper.plist"
cat > "$PLIST" <<PL
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0"><dict>
  <key>Label</key><string>com.upwelleveryday.wallpaper</string>
  <key>ProgramArguments</key><array>
    <string>$DIR/venv/bin/python</string><string>$DIR/upwell_everyday.py</string>
  </array>
  <key>RunAtLoad</key><true/>
  <key>StartCalendarInterval</key><dict><key>Hour</key><integer>7</integer><key>Minute</key><integer>0</integer></dict>
  <key>StandardOutPath</key><string>$DIR/log.txt</string>
  <key>StandardErrorPath</key><string>$DIR/log.txt</string>
</dict></plist>
PL
launchctl unload "$PLIST" 2>/dev/null || true
launchctl load "$PLIST"
echo "Installed. Fetching this week's wallpapers now (first run may ask permission to control System Events)..."
"$DIR/venv/bin/python" "$DIR/upwell_everyday.py"
