import Foundation
import CoreGPX
import UIKit

enum ExportService {
    static func exportURL(for survey: Survey) -> URL? {
        let fm = FileManager.default
        let tempDir = fm.temporaryDirectory.appendingPathComponent("export_\(survey.id.uuidString)", isDirectory: true)

        // Clean up previous export
        try? fm.removeItem(at: tempDir)
        try? fm.createDirectory(at: tempDir, withIntermediateDirectories: true)

        // 1. Generate GPX
        let gpxRoot = GPXRoot(creator: "FieldWalk")
        let track = GPXTrack()
        let segment = GPXTrackSegment()

        for point in survey.sortedTrackPoints {
            let trackpoint = GPXTrackPoint(latitude: point.latitude, longitude: point.longitude)
            trackpoint.elevation = point.altitude
            trackpoint.time = point.timestamp
            segment.add(trackpoint: trackpoint)
        }
        track.add(trackSegment: segment)
        gpxRoot.add(track: track)

        // Add observation waypoints
        for obs in survey.observations {
            let waypoint = GPXWaypoint(latitude: obs.latitude, longitude: obs.longitude)
            waypoint.time = obs.timestamp
            waypoint.name = obs.formEntries.first(where: { $0.fieldLabel == "Category" })?.value ?? "Observation"
            waypoint.desc = obs.formEntries.first(where: { $0.fieldLabel == "Notes" })?.value
            gpxRoot.add(waypoint: waypoint)
        }

        let gpxString = gpxRoot.gpx()
        let gpxURL = tempDir.appendingPathComponent("track.gpx")
        try? gpxString.write(to: gpxURL, atomically: true, encoding: .utf8)

        // 2. Copy photos
        let photosDir = tempDir.appendingPathComponent("photos", isDirectory: true)
        try? fm.createDirectory(at: photosDir, withIntermediateDirectories: true)
        let appPhotosDir = fm.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("photos")

        for obs in survey.observations {
            let src = appPhotosDir.appendingPathComponent(obs.photoFilename)
            let dst = photosDir.appendingPathComponent(obs.photoFilename)
            try? fm.copyItem(at: src, to: dst)
        }

        // 3. Generate manifest.json
        let manifest = SurveyManifest(
            name: survey.name,
            notes: survey.notes,
            startDate: survey.startDate,
            endDate: survey.endDate,
            totalDistanceMeters: survey.totalDistance,
            estimatedAreaSqMeters: survey.estimatedArea,
            trackPointCount: survey.trackPoints.count,
            observations: survey.observations.map { obs in
                ObservationManifest(
                    id: obs.id.uuidString,
                    photoFilename: obs.photoFilename,
                    latitude: obs.latitude,
                    longitude: obs.longitude,
                    timestamp: obs.timestamp,
                    formData: Dictionary(
                        uniqueKeysWithValues: obs.formEntries
                            .filter { !$0.value.isEmpty }
                            .map { ($0.fieldLabel, $0.value) }
                    )
                )
            }
        )

        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        if let data = try? encoder.encode(manifest) {
            let manifestURL = tempDir.appendingPathComponent("manifest.json")
            try? data.write(to: manifestURL)
        }

        // 4. Create zip using NSFileCoordinator
        let safeName = survey.name.replacingOccurrences(of: " ", with: "_")
        let dateStr = survey.startDate.formatted(.iso8601.year().month().day())
        let zipName = "\(safeName)_\(dateStr).zip"
        let zipURL = fm.temporaryDirectory.appendingPathComponent(zipName)
        try? fm.removeItem(at: zipURL)

        let coordinator = NSFileCoordinator()
        var error: NSError?
        coordinator.coordinate(readingItemAt: tempDir, options: .forUploading, error: &error) { zippedURL in
            try? fm.moveItem(at: zippedURL, to: zipURL)
        }

        return fm.fileExists(atPath: zipURL.path) ? zipURL : nil
    }
}

struct SurveyManifest: Codable {
    let name: String
    let notes: String
    let startDate: Date
    let endDate: Date?
    let totalDistanceMeters: Double
    let estimatedAreaSqMeters: Double?
    let trackPointCount: Int
    let observations: [ObservationManifest]
}

struct ObservationManifest: Codable {
    let id: String
    let photoFilename: String
    let latitude: Double
    let longitude: Double
    let timestamp: Date
    let formData: [String: String]
}
