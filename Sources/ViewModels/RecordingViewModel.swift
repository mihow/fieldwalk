import Foundation
import SwiftData
import CoreLocation

@Observable
final class RecordingViewModel {
    let survey: Survey
    let locationService: LocationService
    private let modelContext: ModelContext

    var elapsedTime: TimeInterval = 0
    var isPaused = false
    var showStopConfirmation = false
    var showObservationSheet = false

    private var timer: Timer?
    private var activeStartTime: Date?
    private var accumulatedTime: TimeInterval = 0
    private var lastProcessedIndex = 0

    init(survey: Survey, locationService: LocationService, modelContext: ModelContext) {
        self.survey = survey
        self.locationService = locationService
        self.modelContext = modelContext
    }

    func startRecording() {
        locationService.requestPermission()
        locationService.startTracking()
        isPaused = false
        activeStartTime = Date()
        startTimer()
    }

    func pauseRecording() {
        locationService.pauseTracking()
        isPaused = true
        if let start = activeStartTime {
            accumulatedTime += Date().timeIntervalSince(start)
            activeStartTime = nil
        }
        stopTimer()
        survey.status = .paused
    }

    func resumeRecording() {
        locationService.resumeTracking()
        isPaused = false
        activeStartTime = Date()
        startTimer()
        survey.status = .recording
    }

    func stopRecording() {
        locationService.stopTracking()
        if let start = activeStartTime {
            accumulatedTime += Date().timeIntervalSince(start)
        }
        stopTimer()
        survey.status = .completed
        survey.endDate = Date()
        try? modelContext.save()
    }

    func processNewTrackPoints() {
        let newPoints = Array(locationService.trackPoints.dropFirst(lastProcessedIndex))
        for location in newPoints {
            let point = TrackPoint(
                latitude: location.coordinate.latitude,
                longitude: location.coordinate.longitude,
                altitude: location.altitude,
                timestamp: location.timestamp
            )
            point.survey = survey
            survey.trackPoints.append(point)
            modelContext.insert(point)
        }
        lastProcessedIndex = locationService.trackPoints.count
        try? modelContext.save()
    }

    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let self else { return }
            if let start = self.activeStartTime {
                self.elapsedTime = self.accumulatedTime + Date().timeIntervalSince(start)
            }
            self.processNewTrackPoints()
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    var formattedTime: String {
        let hours = Int(elapsedTime) / 3600
        let minutes = (Int(elapsedTime) % 3600) / 60
        let seconds = Int(elapsedTime) % 60
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        }
        return String(format: "%02d:%02d", minutes, seconds)
    }

    var formattedDistance: String {
        let meters = survey.totalDistance
        if meters >= 1000 {
            return String(format: "%.1f km", meters / 1000)
        }
        return String(format: "%.0f m", meters)
    }

    var formattedArea: String? {
        guard let area = survey.estimatedArea else { return nil }
        if area >= 10_000 {
            return String(format: "%.2f ha", area / 10_000)
        }
        return String(format: "%.0f m²", area)
    }
}
