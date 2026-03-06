# FieldWalk — Screen Inventory

## Navigation Flow

```
Survey List (home)
├── + New Survey → New Survey form → Active Recording
│                                    ├── Add Observation → New Observation (camera → form)
│                                    └── Stop → Survey Detail
└── Tap survey → Survey Detail
                 ├── Tap observation pin → Observation Detail
                 └── Export → Share sheet
```

## Screen Details

### 1. Survey List (Home)
- **Tab/Nav:** Root view, NavigationStack
- **Content:** List of all surveys sorted by date (newest first)
- **Each row:** Survey name, date, distance (formatted), observation count, small static map thumbnail showing the track
- **Empty state:** "No surveys yet. Tap + to start your first one."
- **Actions:** + button (top trailing) → New Survey
- **In-progress indicator:** If a survey is recording/paused, it appears at the top with a highlighted "In Progress" badge and tap resumes Active Recording

### 2. New Survey
- **Presented:** Sheet or push from Survey List
- **Fields:** Survey name (required, text field), Notes (optional, multiline text)
- **Actions:** "Start Recording" button (prominent, bottom). Disabled until name is entered.
- **On start:** Creates Survey model, transitions to Active Recording

### 3. Active Recording
- **Layout:**
  - Top: Stats bar (elapsed time | distance | area estimate | obs count)
  - Center: MapKit map filling remaining space, showing current location + track polyline
  - Bottom: Control bar with large Pause/Record toggle button (center), Stop button (left), Add Observation button (right)
- **Map behavior:** Auto-follows current location. Track polyline drawn in real-time. User can pan to explore, tap location button to re-center.
- **Paused state:** Record button shows "Resume", stats bar shows paused indicator, GPS stops
- **Stop:** Confirmation alert ("End this survey?"), then navigates to Survey Detail

### 4. New Observation
- **Presented:** Full-screen sheet from Active Recording
- **Step 1:** Camera view (AVFoundation). Capture button. Flash toggle.
- **Step 2:** After photo taken, form appears:
  - Auto-filled: coordinates (shown as lat/lon), timestamp
  - Category (picker/dropdown)
  - Condition (picker/dropdown)
  - Notes (text field)
  - Measurement (number field, optional)
  - Mic button (disabled, "Coming soon" — v2 stub)
- **Actions:** Save (adds observation to survey, returns to Active Recording), Cancel (discards)

### 5. Survey Detail
- **Presented:** Push from Survey List, or after stopping a recording
- **Layout:**
  - Top: Map showing full track polyline + observation pin markers
  - Middle: Stats summary (date range, elapsed time, total distance, area if applicable, observation count)
  - Bottom: Scrollable list of observations (thumbnail, category, timestamp)
- **Actions:**
  - Export button (toolbar) → generates .zip → share sheet
  - Tap observation → Observation Detail
- **Map interaction:** Tap pin → shows observation callout with thumbnail + category

### 6. Observation Detail
- **Presented:** Push from Survey Detail
- **Layout:**
  - Full-width photo (zoomable)
  - Form data displayed as label: value pairs
  - Small map showing observation pin location relative to survey track
  - Timestamp
- **Actions:** Back to Survey Detail
