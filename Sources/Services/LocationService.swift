import Foundation
import CoreLocation

@Observable
final class LocationService: NSObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()

    var currentLocation: CLLocation?
    var isAuthorized = false
    var trackPoints: [CLLocation] = []
    private(set) var isTracking = false

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.distanceFilter = 10
        manager.allowsBackgroundLocationUpdates = true
        manager.showsBackgroundLocationIndicator = true
    }

    func requestPermission() {
        manager.requestWhenInUseAuthorization()
    }

    func startTracking() {
        trackPoints = []
        isTracking = true
        manager.startUpdatingLocation()
    }

    func resumeTracking() {
        isTracking = true
        manager.startUpdatingLocation()
    }

    func pauseTracking() {
        isTracking = false
        manager.stopUpdatingLocation()
    }

    func stopTracking() {
        isTracking = false
        manager.stopUpdatingLocation()
    }

    // MARK: - CLLocationManagerDelegate

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard isTracking else { return }
        for location in locations {
            guard location.horizontalAccuracy >= 0 && location.horizontalAccuracy < 50 else { continue }
            currentLocation = location
            trackPoints.append(location)
        }
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            isAuthorized = true
        default:
            isAuthorized = false
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location error: \(error.localizedDescription)")
    }
}
