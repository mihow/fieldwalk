import Foundation
import SwiftData

@Model
final class FieldObservation {
    var id: UUID
    var photoFilename: String
    var latitude: Double
    var longitude: Double
    var timestamp: Date
    @Relationship(deleteRule: .cascade) var formEntries: [FormEntry]
    var survey: Survey?

    init(photoFilename: String, latitude: Double, longitude: Double, timestamp: Date) {
        self.id = UUID()
        self.photoFilename = photoFilename
        self.latitude = latitude
        self.longitude = longitude
        self.timestamp = timestamp
        self.formEntries = []
    }
}
