#!/bin/bash
set -e

BUNDLE="com.example.FieldWalk"
SCREENSHOT_DIR="/tmp/fieldwalk_screenshots"
mkdir -p "$SCREENSHOT_DIR"

# Build
echo "=== Building ==="
cd ~/Projects/FieldWalk
bash scripts/build.sh 2>&1 | tail -3

echo "=== App launched in auto-tour mode ==="
echo "=== Screens advance every 8 seconds ==="
echo "=== Taking screenshots at each screen ==="

# Screen order matches ScreenTourView: list, detail, observation, new_survey, debug_map
SCREENS=("list" "detail" "observation" "new_survey" "debug_map")
HOLD=8

# Wait for first screen to render
sleep 4

for i in "${!SCREENS[@]}"; do
    screen="${SCREENS[$i]}"
    echo "=== Screenshot: $screen ==="
    xcrun simctl io booted screenshot "$SCREENSHOT_DIR/${screen}.png" 2>&1
    echo "  -> Saved ${screen}.png"

    if [ $i -lt $((${#SCREENS[@]} - 1)) ]; then
        echo "  Waiting ${HOLD}s for next screen..."
        sleep "$HOLD"
    fi
done

echo ""
echo "=== All screenshots saved to $SCREENSHOT_DIR ==="
ls -la "$SCREENSHOT_DIR/"
