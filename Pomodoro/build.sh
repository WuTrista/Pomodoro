#!/bin/bash

# Build the Pomodoro macOS app
set -e

APP_NAME="Pomodoro"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
BUILD_DIR="$SCRIPT_DIR/build"
cd "$SCRIPT_DIR"
APP_BUNDLE="$BUILD_DIR/$APP_NAME.app"

echo "Building $APP_NAME..."

# Clean build
rm -rf "$BUILD_DIR"
mkdir -p "$APP_BUNDLE/Contents/MacOS"
mkdir -p "$APP_BUNDLE/Contents/Resources"

# Compile all Swift files
SWIFT_FILES=(
    "Models/TimerState.swift"
    "Models/PomodoroRecord.swift"
    "Models/Settings.swift"
    "Services/NotificationService.swift"
    "ViewModels/TimerViewModel.swift"
    "Views/StatisticsView.swift"
    "Views/SettingsView.swift"
    "Views/ContentView.swift"
    "PomodoroApp.swift"
)

echo "Compiling Swift files..."
swiftc \
    -o "$APP_BUNDLE/Contents/MacOS/$APP_NAME" \
    -sdk "$(xcrun --show-sdk-path --sdk macosx)" \
    -target "$(uname -m)-apple-macos14.0" \
    -framework SwiftUI \
    -framework Combine \
    -framework UserNotifications \
    -framework AppKit \
    "${SWIFT_FILES[@]}"

# Create Info.plist
cat > "$APP_BUNDLE/Contents/Info.plist" << 'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleName</key>
    <string>Pomodoro</string>
    <key>CFBundleDisplayName</key>
    <string>番茄钟</string>
    <key>CFBundleIdentifier</key>
    <string>com.pomodoro.app</string>
    <key>CFBundleVersion</key>
    <string>1.0</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0</string>
    <key>CFBundleExecutable</key>
    <string>Pomodoro</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>LSMinimumSystemVersion</key>
    <string>14.0</string>
    <key>NSHighResolutionCapable</key>
    <true/>
</dict>
</plist>
PLIST

echo "Done! App built at: $APP_BUNDLE"
echo ""
echo "To run: open $APP_BUNDLE"
echo ""
echo "Or run directly: $APP_BUNDLE/Contents/MacOS/$APP_NAME"

# Optionally launch immediately
if [ "$1" = "--run" ]; then
    echo "Launching..."
    open "$APP_BUNDLE"
fi
