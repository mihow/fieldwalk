import Foundation
import SwiftData
import CoreLocation

@Model
final class Survey {
    var id: UUID
    var name: String
    var notes: String
    var startDate: Date
    var endDate: Date?
    var statusRaw: String
    @Relationship(deleteRule: .cascade) var trackPoints: [TrackPoint]
    @Relationship(deleteRule: .cascade) var observations: [FieldObservation]

    var status: SurveyStatus {
        get { SurveyStatus(rawValue: statusRaw) ?? .recording }
        set { statusRaw = newValue.rawValue }
    }

    init(name: String, notes: String = "") {
        self.id = UUID()
        self.name = name
        self.notes = notes
        self.startDate = Date()
        self.statusRaw = SurveyStatus.recording.rawValue
        self.trackPoints = []
        self.observations = []
    }

    var sortedTrackPoints: [TrackPoint] {
        trackPoints.sorted { $0.timestamp < $1.timestamp }
    }

    var totalDistance: Double {
        let sorted = sortedTrackPoints
        guard sorted.count > 1 else { return 0 }
        var total: Double = 0
        for i in 1..<sorted.count {
            let prev = CLLocation(latitude: sorted[i-1].latitude, longitude: sorted[i-1].longitude)
            let curr = CLLocation(latitude: sorted[i].latitude, longitude: sorted[i].longitude)
            total += curr.distance(from: prev)
        }
        return total
    }

    var isNearClosed: Bool {
        guard let first = sortedTrackPoints.first, let last = sortedTrackPoints.last, sortedTrackPoints.count > 10 else { return false }
        let start = CLLocation(latitude: first.latitude, longitude: first.longitude)
        let end = CLLocation(latitude: last.latitude, longitude: last.longitude)
        return end.distance(from: start) < 50
    }

    var estimatedArea: Double? {
        guard isNearClosed else { return nil }
        let sorted = sortedTrackPoints
        let refLat = sorted[0].latitude
        let metersPerDegreeLat = 111_320.0
        let metersPerDegreeLon = 111_320.0 * cos(refLat * .pi / 180)

        var area: Double = 0
        let n = sorted.count
        for i in 0..<n {
            let j = (i + 1) % n
            let xi = (sorted[i].longitude - sorted[0].longitude) * metersPerDegreeLon
            let yi = (sorted[i].latitude - sorted[0].latitude) * metersPerDegreeLat
            let xj = (sorted[j].longitude - sorted[0].longitude) * metersPerDegreeLon
            let yj = (sorted[j].latitude - sorted[0].latitude) * metersPerDegreeLat
            area += xi * yj - xj * yi
        }
        return abs(area) / 2.0
    }
}
