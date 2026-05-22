#!/bin/bash
set -e

# Change to the root of the project
cd "$(dirname "$0")/.."

echo "Building release binary..."
swift build -c release

echo "Creating App Bundle structure..."
APP_NAME="Multipaste"
APP_DIR="$APP_NAME.app"
MACOS_DIR="$APP_DIR/Contents/MacOS"
RES_DIR="$APP_DIR/Contents/Resources"

rm -rf "$APP_DIR"
mkdir -p "$MACOS_DIR" "$RES_DIR"

echo "Copying binary..."
cp .build/release/multipaste "$MACOS_DIR/$APP_NAME"

echo "Copying icon..."
if [ -f "AppIcon.icns" ]; then
    cp AppIcon.icns "$RES_DIR/"
fi

echo "Writing Info.plist..."
cat <<EOF > "$APP_DIR/Contents/Info.plist"
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleIdentifier</key>
    <string>com.local.multipaste</string>
    <key>CFBundleName</key>
    <string>Multipaste</string>
    <key>CFBundleDisplayName</key>
    <string>Multipaste</string>
    <key>CFBundleExecutable</key>
    <string>Multipaste</string>
    <key>CFBundleVersion</key>
    <string>1</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0.0</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>LSUIElement</key>
    <true/>
    <key>NSAccessibilityUsageDescription</key>
    <string>Multipaste needs Accessibility access to read the cursor position and intercept keyboard shortcuts.</string>
    <key>NSPrincipalClass</key>
    <string>NSApplication</string>
    <key>CFBundleIconFile</key>
    <string>AppIcon</string>
</dict>
</plist>
EOF

echo "Done! App bundle created at $APP_DIR"
