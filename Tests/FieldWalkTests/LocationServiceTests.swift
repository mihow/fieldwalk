import XCTest
@testable import FieldWalk

@MainActor
final class LocationServiceTests: XCTestCase {

    func testInitialStateNotTracking() {
        let service = LocationService()
        XCTAssertFalse(service.isTracking)
    }

    func testInitialStateNoCurrentLocation() {
        let service = LocationService()
        XCTAssertNil(service.currentLocation)
    }

    func testInitialStateNotAuthorized() {
        let service = LocationService()
        XCTAssertFalse(service.isAuthorized)
    }

    func testStartTrackingSetsIsTracking() {
        let service = LocationService()
        service.startTracking()
        XCTAssertTrue(service.isTracking)
    }

    func testPauseTrackingSetsIsTrackingFalse() {
        let service = LocationService()
        service.startTracking()
        service.pauseTracking()
        XCTAssertFalse(service.isTracking)
    }

    func testStopTrackingSetsIsTrackingFalse() {
        let service = LocationService()
        service.startTracking()
        service.stopTracking()
        XCTAssertFalse(service.isTracking)
    }
}
