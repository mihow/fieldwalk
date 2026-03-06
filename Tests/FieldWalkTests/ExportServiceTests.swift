import XCTest
import SwiftData
@testable import FieldWalk

@MainActor
final class ExportServiceTests: XCTestCase {
    var container: ModelContainer!
    var context: ModelContext!

    override func setUp() async throws {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        container = try ModelContainer(
            for: Survey.self, TrackPoint.self, FieldObservation.self, FormEntry.self,
            configurations: config
        )
        context = container.mainContext
    }

    override func tearDown() async throws {
        container = nil
        context = nil
    }

    private func makeSurveyWithData() -> Survey {
        let survey = Survey(name: "Export Test")
        context.insert(survey)

        // Add track points
        let baseTime = Date(timeIntervalSince1970: 1_000_000)
        for i in 0..<5 {
            let tp = TrackPoint(
                latitude: 51.5 + Double(i) * 0.001,
                longitude: -0.1 + Double(i) * 0.001,
                altitude: 100,
                timestamp: baseTime.addingTimeInterval(Double(i) * 10)
            )
            survey.trackPoints.append(tp)
        }

        // Add an observation with form entries
        let obs = FieldObservation(
            photoFilename: "test_photo.jpg",
            latitude: 51.501,
            longitude: -0.099,
            timestamp: baseTime.addingTimeInterval(15)
        )
        let categoryEntry = FormEntry(fieldLabel: "Category", fieldType: .dropdown, value: "Wildlife")
        let notesEntry = FormEntry(fieldLabel: "Notes", fieldType: .text, value: "Saw a fox")
        obs.formEntries = [categoryEntry, notesEntry]
        survey.observations.append(obs)

        return survey
    }

    func testExportGeneratesZipFile() throws {
        let survey = makeSurveyWithData()

        guard let exportURL = ExportService.exportURL(for: survey) else {
            XCTFail("ExportService.exportURL returned nil")
            return
        }

        XCTAssertTrue(FileManager.default.fileExists(atPath: exportURL.path))
        XCTAssertTrue(exportURL.lastPathComponent.hasSuffix(".zip"))
    }

    func testExportTempDirectoryContainsTrackGpx() throws {
        let survey = makeSurveyWithData()

        let tempDir = FileManager.default.temporaryDirectory
            .appendingPathComponent("export_\(survey.id.uuidString)", isDirectory: true)

        // Trigger export to create the directory
        _ = ExportService.exportURL(for: survey)

        let gpxURL = tempDir.appendingPathComponent("track.gpx")
        if FileManager.default.fileExists(atPath: gpxURL.path) {
            let gpxContent = try String(contentsOf: gpxURL, encoding: .utf8)
            XCTAssertTrue(gpxContent.contains("<trk>"), "GPX should contain a track element")
            XCTAssertTrue(gpxContent.contains("<trkpt"), "GPX should contain track points")
            XCTAssertTrue(gpxContent.contains("51.5"), "GPX should contain our latitude")
        }
    }

    func testExportManifestContainsSurveyInfo() throws {
        let survey = makeSurveyWithData()

        let tempDir = FileManager.default.temporaryDirectory
            .appendingPathComponent("export_\(survey.id.uuidString)", isDirectory: true)

        _ = ExportService.exportURL(for: survey)

        let manifestURL = tempDir.appendingPathComponent("manifest.json")
        if FileManager.default.fileExists(atPath: manifestURL.path) {
            let data = try Data(contentsOf: manifestURL)
            let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]

            XCTAssertEqual(json?["name"] as? String, "Export Test")
            let observations = json?["observations"] as? [[String: Any]]
            XCTAssertEqual(observations?.count, 1)
        }
    }

    func testExportPhotosDirectoryCreated() throws {
        let survey = makeSurveyWithData()

        let tempDir = FileManager.default.temporaryDirectory
            .appendingPathComponent("export_\(survey.id.uuidString)", isDirectory: true)

        _ = ExportService.exportURL(for: survey)

        let photosDir = tempDir.appendingPathComponent("photos")
        if FileManager.default.fileExists(atPath: tempDir.path) {
            var isDir: ObjCBool = false
            let exists = FileManager.default.fileExists(atPath: photosDir.path, isDirectory: &isDir)
            XCTAssertTrue(exists, "photos directory should exist")
            XCTAssertTrue(isDir.boolValue, "photos should be a directory")
        }
    }
}
