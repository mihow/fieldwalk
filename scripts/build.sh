#!/bin/bash
set -e
cd ~/Projects/FieldWalk

DEVICE="iPhone 17"

echo "=== Building FieldWalk ==="
xcodebuild -project FieldWalk.xcodeproj \
  -scheme FieldWalk \
  -sdk iphonesimulator \
  -destination "platform=iOS Simulator,name=$DEVICE" \
  CODE_SIGN_IDENTITY="" \
  CODE_SIGNING_REQUIRED=NO \
  build 2>&1 | tail -5

# Find the built .app bundle
APP=$(find ~/Library/Developer/Xcode/DerivedData/FieldWalk-*/Build/Products/Debug-iphonesimulator/FieldWalk.app -maxdepth 0 2>/dev/null | head -1)

if [ -z "$APP" ]; then
  echo "ERROR: .app bundle not found"
  exit 1
fi

echo "=== Installing on simulator ==="
xcrun simctl install "$DEVICE" "$APP"

echo "=== Launching ==="
xcrun simctl launch "$DEVICE" com.example.FieldWalk

echo "=== Done ==="
