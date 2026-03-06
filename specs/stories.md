# FieldWalk — User Stories

### S-001: Start a Survey
**As a** field researcher, **I want** to create a named survey and start recording with one tap, **so that** I can begin documenting my transect quickly.
**Acceptance:** Tapping Record starts GPS tracking, timer begins, map shows current location. Survey name and optional notes captured before recording starts.
**Priority:** must-have

### S-002: See Live Stats While Recording
**As a** field researcher, **I want** to see elapsed time, distance walked, and observation count while recording, **so that** I know my progress without stopping.
**Acceptance:** Stats bar updates in real-time. Distance accumulates as I move. Timer pauses when I pause recording.
**Priority:** must-have

### S-003: See My Track on the Map
**As a** field researcher, **I want** to see my path drawn on the map as I walk, **so that** I can see where I've been and plan where to go next.
**Acceptance:** Polyline appears on MapKit map, updating as new track points arrive. Map auto-centers on current location.
**Priority:** must-have

### S-004: Pause and Resume Recording
**As a** field researcher, **I want** to pause recording (e.g., during a break) and resume without losing data, **so that** my survey reflects actual work time.
**Acceptance:** Pause stops GPS and timer. Resume continues the same survey. Elapsed time excludes paused duration. Track has a gap during paused period.
**Priority:** must-have

### S-005: Take a Photo Observation
**As a** field researcher, **I want** to take a photo and fill in structured data about what I see, **so that** my observations are documented with context.
**Acceptance:** Camera opens, photo captured, form presented with category/condition/notes/measurement fields. Location and timestamp auto-attached. Observation appears as pin on map.
**Priority:** must-have

### S-006: View Completed Surveys
**As a** field researcher, **I want** to browse my past surveys in a list, **so that** I can review and export them later.
**Acceptance:** Survey list shows name, date, distance, observation count. Tapping opens survey detail with map and observations.
**Priority:** must-have

### S-007: Review a Survey
**As a** field researcher, **I want** to see a completed survey's full track on a map with observation pins, **so that** I can review the work I did.
**Acceptance:** Map shows complete track polyline + observation pin markers. Tapping a pin shows observation detail. Stats summary visible.
**Priority:** must-have

### S-008: View Observation Detail
**As a** field researcher, **I want** to tap an observation to see its photo, form data, and location, **so that** I can review individual findings.
**Acceptance:** Full-size photo displayed. All form fields shown. Pin on small map. Timestamp displayed.
**Priority:** must-have

### S-009: Export a Survey
**As a** field researcher, **I want** to export a completed survey as a zip file, **so that** I can share it or upload it to another system.
**Acceptance:** Export produces .zip containing track.gpx, manifest.json, and photos/ directory. Share sheet opens for sending/saving. GPX is valid and opens in standard GIS tools.
**Priority:** must-have

### S-010: Area Estimate
**As a** field researcher, **I want** to see an area estimate when my path forms a near-closed shape, **so that** I can gauge the size of the area I've surveyed.
**Acceptance:** When first and last track points are within ~50m, area stat appears using shoelace formula on projected coordinates. Hidden otherwise.
**Priority:** nice-to-have

### S-011: Background Recording
**As a** field researcher, **I want** recording to continue when my screen locks, **so that** I don't have to keep my phone awake while walking.
**Acceptance:** GPS tracking continues with screen off. Track points recorded. Timer continues. Uses "When In Use" + background location capability.
**Priority:** must-have

### S-012: Voice Input for Observations (Stub)
**As a** field researcher, **I want** a voice input option for observation forms, **so that** I can dictate notes while walking.
**Acceptance:** Microphone button visible but disabled with "Coming soon" tooltip. No functionality in v1.
**Priority:** v2
