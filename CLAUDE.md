# FieldWalk — Agent Rules

## Swift Rules
- Swift 6 strict concurrency; async/await for all async ops
- Prefer structs over classes (except SwiftData @Model classes)
- @Observable for view models (not ObservableObject)
- Never force unwrap (!); handle optionals explicitly
- Extract views > 100 lines into separate files
- NavigationStack with type-safe routing enums

## Project Rules
- Xcode project managed via XcodeGen (`project.yml` → `xcodegen generate`)
- Never edit `.xcodeproj` directly — edit `project.yml` and regenerate
- Simulator builds only — no code signing
- One external dependency: CoreGPX
- Build: `bash scripts/build.sh`
- Regenerate project: `xcodegen generate`

## Build & Simulator
- Default simulator: iPhone 17 (iOS 26)
- Build command: `xcodebuild -project FieldWalk.xcodeproj -scheme FieldWalk -sdk iphonesimulator -destination "platform=iOS Simulator,name=iPhone 17" build`
- Simulator install: `xcrun simctl install "iPhone 17" /path/to/FieldWalk.app`
- Screenshots: `xcrun simctl io booted screenshot output.png`

## Agent Behavior
- Never repeat the same failing action more than twice
- Build and verify before reporting task complete
- Keep changes small and focused
- Commit after each working feature
- Max 3 visual iterations before human checkpoint
- On blockers: check existing scripts/docs first, ask before deviating

## Testing
- Write tests for business logic and services
- Run tests: `xcodebuild -project FieldWalk.xcodeproj -scheme FieldWalkTests -sdk iphonesimulator -destination "platform=iOS Simulator,name=iPhone 17" test`

## Branch & Merge
- Feature branches: `build/YYYY-MM-DD-<topic>`
- Squash-merge to `main` (one clean commit per build)
- Tag releases: `v0.1.0-build.N`
