#!/bin/bash
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
APP="$ROOT_DIR/dist/Career Manager.app"
mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources"
cp "$ROOT_DIR/server.py" "$ROOT_DIR/index.html" "$APP/Contents/Resources/"
swiftc "$ROOT_DIR/macos/main.swift" -o "$APP/Contents/MacOS/CareerManager" -framework Cocoa -framework WebKit
cat > "$APP/Contents/Info.plist" <<'PLIST'
<?xml version="1.0" encoding="UTF-8"?><!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd"><plist version="1.0"><dict><key>CFBundleName</key><string>Career Manager</string><key>CFBundleIdentifier</key><string>local.careermanager.app</string><key>CFBundleExecutable</key><string>CareerManager</string><key>CFBundlePackageType</key><string>APPL</string><key>CFBundleVersion</key><string>1</string><key>NSAppTransportSecurity</key><dict><key>NSAllowsLocalNetworking</key><true/></dict></dict></plist>
PLIST
/usr/bin/codesign --force --sign - "$APP" >/dev/null
/usr/bin/open -n "$APP"
