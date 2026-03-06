import XCTest
import CoreLocation
import SwiftData
@testable import FieldWalk

@MainActor
final class SurveyTests: XCTestCase {
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

    // MARK: - Creation defaults

    func testSurveyCreationDefaults() throws {
        let survey = Survey(name: "Test Survey")
        context.insert(survey)

        XCTAssertEqual(survey.name, "Test Survey")
        XCTAssertEqual(survey.status, .recording)
        XCTAssertEqual(survey.notes, "")
        XCTAssertTrue(survey.trackPoints.isEmpty)
        XCTAssertTrue(survey.observations.isEmpty)
        XCTAssertNil(survey.endDate)
    }

    // MARK: - totalDistance

    func testTotalDistanceWithKnownPoints() throws {
        let survey = Survey(name: "Distance Test")
        context.insert(survey)

        // Two points about 111km apart (1 degree latitude)
        let p1 = TrackPoint(latitude: 0.0, longitude: 0.0, altitude: 0, timestamp: Date(timeIntervalSince1970: 0))
        let p2 = TrackPoint(latitude: 1.0, longitude: 0.0, altitude: 0, timestamp: Date(timeIntervalSince1970: 1))
        survey.trackPoints = [p1, p2]

        let distance = survey.totalDistance
        // 1 degree latitude ≈ 111,320 meters
        XCTAssertGreaterThan(distance, 110_000)
        XCTAssertLessThan(distance, 112_000)
    }

    func testTotalDistanceSinglePoint() throws {
        let survey = Survey(name: "Single Point")
        context.insert(survey)

        let p1 = TrackPoint(latitude: 0.0, longitude: 0.0, altitude: 0, timestamp: Date())
        survey.trackPoints = [p1]

        XCTAssertEqual(survey.totalDistance, 0)
    }

    func testTotalDistanceEmptyPoints() throws {
        let survey = Survey(name: "Empty")
        context.insert(survey)

        XCTAssertEqual(survey.totalDistance, 0)
    }

    // MARK: - isNearClosed

    func testIsNearClosedWhenFirstLastWithin50m() throws {
        let survey = Survey(name: "Near Closed")
        context.insert(survey)

        // Create >10 points in a loop, start and end within 50m
        var points: [TrackPoint] = []
        let baseTime = Date(timeIntervalSince1970: 0)
        for i in 0...15 {
            let angle = Double(i) * 2 * .pi / 15.0
            let lat = 51.5 + 0.001 * sin(angle)
            let lon = -0.1 + 0.001 * cos(angle)
            points.append(TrackPoint(latitude: lat, longitude: lon, altitude: 0, timestamp: baseTime.addingTimeInterval(Double(i))))
        }
        // Last point same as first => distance 0 < 50m
        survey.trackPoints = points

        XCTAssertTrue(survey.isNearClosed)
    }

    func testIsNearClosedFalseWhenFarApart() throws {
        let survey = Survey(name: "Not Closed")
        context.insert(survey)

        var points: [TrackPoint] = []
        let baseTime = Date(timeIntervalSince1970: 0)
        // 15 points in a straight line, far apart
        for i in 0..<15 {
            let lat = 51.5 + Double(i) * 0.01 // each step ~1.1km
            points.append(TrackPoint(latitude: lat, longitude: -0.1, altitude: 0, timestamp: baseTime.addingTimeInterval(Double(i))))
        }
        survey.trackPoints = points

        XCTAssertFalse(survey.isNearClosed)
    }

    func testIsNearClosedFalseWithTooFewPoints() throws {
        let survey = Survey(name: "Few Points")
        context.insert(survey)

        // Only 5 points, even if close together => need >10
        var points: [TrackPoint] = []
        let baseTime = Date(timeIntervalSince1970: 0)
        for i in 0..<5 {
            points.append(TrackPoint(latitude: 51.5, longitude: -0.1, altitude: 0, timestamp: baseTime.addingTimeInterval(Double(i))))
        }
        survey.trackPoints = points

        XCTAssertFalse(survey.isNearClosed)
    }

    // MARK: - estimatedArea

    func testEstimatedAreaNilWhenNotNearClosed() throws {
        let survey = Survey(name: "Open Track")
        context.insert(survey)

        // Straight line, far apart => isNearClosed false => area nil
        var points: [TrackPoint] = []
        let baseTime = Date(timeIntervalSince1970: 0)
        for i in 0..<15 {
            let lat = 51.5 + Double(i) * 0.01
            points.append(TrackPoint(latitude: lat, longitude: -0.1, altitude: 0, timestamp: baseTime.addingTimeInterval(Double(i))))
        }
        survey.trackPoints = points

        XCTAssertNil(survey.estimatedArea)
    }

    func testEstimatedAreaForKnownRectangle() throws {
        let survey = Survey(name: "Rectangle")
        context.insert(survey)

        // A rectangle: ~100m x ~200m near equator
        // At equator: 1 degree lat ≈ 111320m, 1 degree lon ≈ 111320m
        // 100m ≈ 0.000898 degrees, 200m ≈ 0.001797 degrees
        let baseLat = 0.0
        let baseLon = 0.0
        let dLat = 0.000898  // ~100m
        let dLon = 0.001797  // ~200m

        // Need >10 points, so add intermediate points along the rectangle
        let baseTime = Date(timeIntervalSince1970: 0)
        var points: [TrackPoint] = []
        // Bottom edge (left to right): 4 points
        for i in 0..<4 {
            let frac = Double(i) / 3.0
            points.append(TrackPoint(latitude: baseLat, longitude: baseLon + frac * dLon, altitude: 0,
                                     timestamp: baseTime.addingTimeInterval(Double(points.count))))
        }
        // Right edge (bottom to top): 3 points
        for i in 1..<4 {
            let frac = Double(i) / 3.0
            points.append(TrackPoint(latitude: baseLat + frac * dLat, longitude: baseLon + dLon, altitude: 0,
                                     timestamp: baseTime.addingTimeInterval(Double(points.count))))
        }
        // Top edge (right to left): 3 points
        for i in 1..<4 {
            let frac = Double(i) / 3.0
            points.append(TrackPoint(latitude: baseLat + dLat, longitude: baseLon + dLon - frac * dLon, altitude: 0,
                                     timestamp: baseTime.addingTimeInterval(Double(points.count))))
        }
        // Left edge (top to bottom, back toward start): 3 points (not including start)
        for i in 1..<4 {
            let frac = Double(i) / 3.0
            points.append(TrackPoint(latitude: baseLat + dLat - frac * dLat, longitude: baseLon, altitude: 0,
                                     timestamp: baseTime.addingTimeInterval(Double(points.count))))
        }
        // Total: 4 + 3 + 3 + 3 = 13 points, first and last very close

        survey.trackPoints = points

        // Verify near-closed first
        XCTAssertTrue(survey.isNearClosed, "Rectangle should be near-closed")

        guard let area = survey.estimatedArea else {
            XCTFail("estimatedArea should not be nil for closed rectangle")
            return
        }

        // Expected area: ~100m * ~200m = ~20,000 m²
        // Allow generous tolerance due to discrete points
        XCTAssertGreaterThan(area, 15_000, "Area should be > 15000 m²")
        XCTAssertLessThan(area, 25_000, "Area should be < 25000 m²")
    }

    // MARK: - sortedTrackPoints

    func testSortedTrackPointsReturnsTimestampOrder() throws {
        let survey = Survey(name: "Sorting Test")
        context.insert(survey)

        let t1 = Date(timeIntervalSince1970: 300)
        let t2 = Date(timeIntervalSince1970: 100)
        let t3 = Date(timeIntervalSince1970: 200)

        let p1 = TrackPoint(latitude: 1, longitude: 1, altitude: 0, timestamp: t1)
        let p2 = TrackPoint(latitude: 2, longitude: 2, altitude: 0, timestamp: t2)
        let p3 = TrackPoint(latitude: 3, longitude: 3, altitude: 0, timestamp: t3)

        survey.trackPoints = [p1, p2, p3]

        let sorted = survey.sortedTrackPoints
        XCTAssertEqual(sorted[0].timestamp, t2) // earliest
        XCTAssertEqual(sorted[1].timestamp, t3)
        XCTAssertEqual(sorted[2].timestamp, t1) // latest
    }
}
