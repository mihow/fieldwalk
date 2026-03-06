# FieldWalk — Structured Spec

## Overview

Field survey app for walking linear transects. One-tap recording captures your GPS path and elapsed time. Take geotagged photo observations with structured form data along the way. Export completed surveys as bundles (GPX + photos + JSON manifest). Local storage only in v1, with future external API integration.

## Target User

Field researchers, environmental monitors, land surveyors, trail assessors — anyone who walks a path and documents conditions or points of interest along it.

## Core Features (v1)

### F-001: Survey Recording
- Start/pause/stop GPS recording with a prominent record button
- Track GPS path at ~10m resolution using CoreLocation
- Background location while app is in recent background (screen off)
- "When In Use" permission only

### F-002: Live Stats
- Elapsed time (excludes paused time)
- Total distance walked
- Area estimate when track is near-closed (first/last point within ~50m)
- Observation count

### F-003: Photo Observations
- Capture photo via camera during active survey
- Auto-tag with current GPS coordinates and timestamp
- Fill structured form: category (dropdown), condition (dropdown), notes (text), measurement (number)
- Default template with: vegetation, erosion, wildlife, infrastructure, water, other

### F-004: Survey Management
- List all surveys (past and in-progress)
- View completed survey on map with track + observation pins
- View individual observation detail (photo, form data, location)

### F-005: Export
- Export survey as .zip bundle via iOS share sheet
- Bundle contains: track.gpx, manifest.json, photos/ directory
- manifest.json includes all survey metadata, stats, and observation form data

### F-006: Map Display
- Apple MapKit for SwiftUI
- Live track polyline during recording
- Observation pins on map
- Survey detail shows full track with pins

## Deferred Features (v2+)

- Voice input for observation forms
- Custom form templates (user-defined fields)
- External API posting
- Cloud sync
- Offline map tiles
- Photo annotation/markup
- Audio notes during survey
- Multi-user collaboration
- Elevation profile

## Technical Constraints

- iOS 17+ (SwiftUI, SwiftData, MapKit for SwiftUI)
- Simulator-only builds (no code signing)
- SPM-based project (no .xcodeproj)
- Single external dependency: CoreGPX
- No auth, no networking, no paid services

## Reference Apps

- ArcGIS Survey123 — structured field data collection (inspiration for observation forms)
- Strava — simple record/pause/stop UX with live stats (inspiration for recording flow)
- iOS-Open-GPX-Tracker — open source GPX recording app (technical reference)

## Acceptance Criteria

1. User can create a survey, start recording, and see their path drawn on the map in real-time
2. User can pause and resume recording without losing data
3. User can take a photo observation with form fields while recording
4. Live stats (time, distance, observation count) update during recording
5. Completed surveys appear in the list with correct stats
6. Survey detail shows track on map with observation pins
7. Export produces a valid .zip with GPX track, photos, and JSON manifest
8. App works with screen locked (background location)
