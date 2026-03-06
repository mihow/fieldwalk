#\!/bin/bash
set -e
cd ~/Projects/FieldWalk

echo "=== Building FieldWalk ==="
xcodebuild -scheme FieldWalk \
  -sdk iphonesimulator \
  -destination "platform=iOS Simulator,name=iPhone SE (3rd generation)" \
  build 2>&1 | tail -5

# Find the built binary
BINARY=$(find ~/Library/Developer/Xcode/DerivedData/FieldWalk-*/Build/Products/Debug-iphonesimulator/FieldWalk -maxdepth 0 2>/dev/null | head -1)

if [ -z "$BINARY" ]; then
  echo "ERROR: Binary not found"
  exit 1
fi

echo "=== Creating .app bundle ==="
cp "$BINARY" FieldWalk.app/FieldWalk
codesign --force --sign - --timestamp=none FieldWalk.app

echo "=== Installing on simulator ==="
xcrun simctl install "iPhone SE (3rd generation)" FieldWalk.app

echo "=== Launching ==="
xcrun simctl launch "iPhone SE (3rd generation)" com.example.FieldWalk

echo "=== Done ==="
