#!/bin/bash
PLIST="$HOME/Library/LaunchAgents/com.upwelleveryday.wallpaper.plist"
launchctl unload "$PLIST" 2>/dev/null; rm -f "$PLIST"
rm -rf "$HOME/Library/Application Support/UpwellEveryday"
echo "Uninstalled."
