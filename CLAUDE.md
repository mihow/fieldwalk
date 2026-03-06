# FieldWalk — Agent Rules

## Swift Rules
- Swift 6 strict concurrency; async/await for all async ops
- Prefer structs over classes (except SwiftData @Model classes)
- @Observable for view models
- Never force unwrap (!); handle optionals explicitly
- Extract views > 100 lines into separate files
- NavigationStack with type-safe routing

## Project Rules
- SPM-based — no .xcodeproj
- Simulator builds only — no code signing
- One external dependency only: CoreGPX
- Build with: `bash scripts/build.sh`

## Agent Behavior
- Never repeat the same failing action more than twice
- Build and verify before reporting task complete
- Keep changes small and focused
- Commit after each working feature

## Testing
- Write tests for business logic and services
- Run tests: `xcodebuild -scheme FieldWalk -sdk iphonesimulator -destination "platform=iOS Simulator,name=iPhone SE (3rd generation)" test`
