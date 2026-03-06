import Foundation
import SwiftData

/// Creates fixture data for testing when no real surveys exist.
/// A realistic walking transect through lower Manhattan with observations.
enum FixtureData {

    /// A walking transect path through lower Manhattan (~800m)
    static let transectCoords: [(lat: Double, lon: Double)] = [
        (40.7128, -74.0060),  // Start: near City Hall
        (40.7131, -74.0058),
        (40.7134, -74.0055),
        (40.7137, -74.0052),
        (40.7140, -74.0048),
        (40.7143, -74.0045),  // Turn NE
        (40.7146, -74.0041),
        (40.7148, -74.0037),
        (40.7150, -74.0033),
        (40.7152, -74.0029),
        (40.7153, -74.0025),  // Turn E
        (40.7152, -74.0021),
        (40.7150, -74.0018),
        (40.7148, -74.0015),
        (40.7145, -74.0013),  // Turn S
        (40.7142, -74.0012),
        (40.7139, -74.0013),
        (40.7136, -74.0015),
        (40.7133, -74.0018),
        (40.7130, -74.0022),  // Heading SW back
        (40.7128, -74.0026),
        (40.7127, -74.0030),
        (40.7126, -74.0035),
        (40.7126, -74.0040),
        (40.7127, -74.0045),
        (40.7128, -74.0050),
        (40.7128, -74.0055),
        (40.7128, -74.0060),  // End: back near start (closed loop)
    ]

    /// Observation points along the transect
    static let observationPoints: [(lat: Double, lon: Double, category: String, condition: String, notes: String)] = [
        (40.7140, -74.0048, "Vegetation", "Good", "Mature oak canopy, healthy growth"),
        (40.7150, -74.0033, "Erosion", "Poor", "Bank erosion along path edge, ~30cm undercut"),
        (40.7152, -74.0021, "Wildlife", "Good", "Red-tailed hawk observed soaring"),
        (40.7139, -74.0013, "Infrastructure", "Fair", "Trail marker post leaning 15 degrees"),
        (40.7127, -74.0040, "Water", "Good", "Drainage channel flowing clear"),
    ]

    /// Populate a model context with fixture data if it contains no surveys.
    @MainActor
    static func seedIfEmpty(context: ModelContext) {
        let descriptor = FetchDescriptor<Survey>()
        let count = (try? context.fetchCount(descriptor)) ?? 0
        guard count == 0 else { return }

        // Create a completed survey
        let survey = Survey(name: "City Hall Park Transect")
        survey.notes = "Morning survey of vegetation and erosion conditions along the perimeter path."
        survey.statusRaw = SurveyStatus.completed.rawValue
        survey.startDate = Calendar.current.date(byAdding: .hour, value: -2, to: Date())!
        survey.endDate = Calendar.current.date(byAdding: .minute, value: -15, to: Date())!
        context.insert(survey)

        // Add track points with timestamps spread over 2 hours
        let startTime = survey.startDate
        let intervalSeconds = 7200.0 / Double(transectCoords.count)
        for (i, coord) in transectCoords.enumerated() {
            let tp = TrackPoint(
                latitude: coord.lat,
                longitude: coord.lon,
                altitude: 10.0 + Double.random(in: -2...2),
                timestamp: startTime.addingTimeInterval(Double(i) * intervalSeconds)
            )
            tp.survey = survey
            context.insert(tp)
        }

        // Add observations
        for obs in observationPoints {
            let fieldObs = FieldObservation(
                photoFilename: "fixture_placeholder.jpg",
                latitude: obs.lat,
                longitude: obs.lon,
                timestamp: startTime.addingTimeInterval(Double.random(in: 600...6600))
            )
            fieldObs.survey = survey
            context.insert(fieldObs)

            // Add form entries
            let catEntry = FormEntry(fieldLabel: "Category", fieldType: .dropdown, value: obs.category)
            catEntry.observation = fieldObs
            context.insert(catEntry)

            let condEntry = FormEntry(fieldLabel: "Condition", fieldType: .dropdown, value: obs.condition)
            condEntry.observation = fieldObs
            context.insert(condEntry)

            let notesEntry = FormEntry(fieldLabel: "Notes", fieldType: .text, value: obs.notes)
            notesEntry.observation = fieldObs
            context.insert(notesEntry)
        }

        // Also create an in-progress survey with fewer points
        let activeSurvey = Survey(name: "Afternoon Walk")
        activeSurvey.notes = "Quick survey in progress"
        activeSurvey.statusRaw = SurveyStatus.recording.rawValue
        context.insert(activeSurvey)

        let activeCoords = Array(transectCoords.prefix(8))
        for (i, coord) in activeCoords.enumerated() {
            let tp = TrackPoint(
                latitude: coord.lat,
                longitude: coord.lon,
                altitude: 10.0,
                timestamp: Date().addingTimeInterval(Double(i) * 30)
            )
            tp.survey = activeSurvey
            context.insert(tp)
        }

        try? context.save()
    }
}
