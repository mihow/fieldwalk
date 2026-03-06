import Foundation
import SwiftData

@Model
final class TrackPoint {
    var id: UUID
    var latitude: Double
    var longitude: Double
    var altitude: Double
    var timestamp: Date
    var survey: Survey?

    init(latitude: Double, longitude: Double, altitude: Double, timestamp: Date) {
        self.id = UUID()
        self.latitude = latitude
        self.longitude = longitude
        self.altitude = altitude
        self.timestamp = timestamp
    }
}
