#!/bin/bash
# build-app.sh — Build exímIA Meter as a distributable .app bundle
# Usage: bash build-app.sh [release|debug]

set -e

MODE="${1:-release}"
APP_NAME="exímIA Meter"
BUNDLE_ID="com.eximia.meter"
VERSION="1.0.0"
BUILD_DIR=".build"
OUTPUT_DIR="dist"

echo "🏗️  Building exímIA Meter ($MODE)..."

# Build
if [ "$MODE" = "release" ]; then
    swift build -c release 2>&1
    BINARY="$BUILD_DIR/release/EximiaMeter"
else
    swift build 2>&1
    BINARY="$BUILD_DIR/debug/EximiaMeter"
fi

if [ ! -f "$BINARY" ]; then
    echo "❌ Build failed — binary not found at $BINARY"
    exit 1
fi

echo "✅ Build complete"

# Create .app bundle structure
APP_BUNDLE="$OUTPUT_DIR/$APP_NAME.app"
rm -rf "$APP_BUNDLE"
mkdir -p "$APP_BUNDLE/Contents/MacOS"
mkdir -p "$APP_BUNDLE/Contents/Resources"

# Copy binary
cp "$BINARY" "$APP_BUNDLE/Contents/MacOS/EximiaMeter"

# Copy Info.plist
cp "Info.plist" "$APP_BUNDLE/Contents/"

# Create PkgInfo
echo -n "APPL????" > "$APP_BUNDLE/Contents/PkgInfo"

echo "📦 App bundle created at: $APP_BUNDLE"

# Make executable
chmod +x "$APP_BUNDLE/Contents/MacOS/EximiaMeter"

# Show result
echo ""
echo "════════════════════════════════════════════════"
echo "  $APP_NAME v$VERSION"
echo "  Bundle: $APP_BUNDLE"
echo "  Size: $(du -sh "$APP_BUNDLE" | cut -f1)"
echo "════════════════════════════════════════════════"
echo ""
echo "To install:"
echo "  cp -r '$APP_BUNDLE' /Applications/"
echo ""
echo "To run:"
echo "  open '$APP_BUNDLE'"
echo ""
echo "To create a DMG (optional):"
echo "  hdiutil create -volname '$APP_NAME' -srcfolder '$OUTPUT_DIR' -ov -format UDZO '$OUTPUT_DIR/$APP_NAME.dmg'"
echo ""
