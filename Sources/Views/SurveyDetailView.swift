import SwiftUI
import MapKit

struct SurveyDetailView: View {
    let survey: Survey

    @State private var exportURL: URL?
    @State private var showShareSheet = false

    private var mapPosition: MapCameraPosition {
        let allCoords: [(Double, Double)] = survey.sortedTrackPoints.map { ($0.latitude, $0.longitude) }
            + survey.observations.map { ($0.latitude, $0.longitude) }
        guard !allCoords.isEmpty else { return .automatic }

        let minLat = allCoords.map(\.0).min()!
        let maxLat = allCoords.map(\.0).max()!
        let minLon = allCoords.map(\.1).min()!
        let maxLon = allCoords.map(\.1).max()!

        let center = CLLocationCoordinate2D(
            latitude: (minLat + maxLat) / 2,
            longitude: (minLon + maxLon) / 2
        )
        let latDelta = max((maxLat - minLat) * 1.3, 0.002)
        let lonDelta = max((maxLon - minLon) * 1.3, 0.002)

        return .region(MKCoordinateRegion(
            center: center,
            span: MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: lonDelta)
        ))
    }

    var body: some View {
        List {
            mapSection
            statsSection
            if !survey.notes.isEmpty {
                notesSection
            }
            observationsSection
        }
        .navigationTitle(survey.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: {
                    exportURL = ExportService.exportURL(for: survey)
                    if exportURL != nil { showShareSheet = true }
                }) {
                    Label("Export", systemImage: "square.and.arrow.up")
                }
            }
        }
        .sheet(isPresented: $showShareSheet) {
            if let url = exportURL {
                ShareSheet(activityItems: [url])
            }
        }
        .navigationDestination(for: FieldObservation.self) { observation in
            ObservationDetailView(observation: observation, survey: survey)
        }
    }

    private var mapSection: some View {
        Section {
            Map(initialPosition: mapPosition) {
                if survey.sortedTrackPoints.count > 1 {
                    MapPolyline(coordinates: survey.sortedTrackPoints.map {
                        CLLocationCoordinate2D(latitude: $0.latitude, longitude: $0.longitude)
                    })
                    .stroke(.blue, lineWidth: 3)
                }
                ForEach(survey.observations) { obs in
                    Marker(
                        obs.categoryLabel,
                        systemImage: "mappin",
                        coordinate: CLLocationCoordinate2D(latitude: obs.latitude, longitude: obs.longitude)
                    )
                    .tint(.orange)
                }
            }
            .frame(height: 250)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .listRowInsets(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0))
        }
    }

    private var statsSection: some View {
        Section("Summary") {
            LabeledContent("Date", value: survey.startDate.formatted(date: .abbreviated, time: .shortened))
            if let endDate = survey.endDate {
                LabeledContent("Duration", value: formatDuration(from: survey.startDate, to: endDate))
            }
            LabeledContent("Distance", value: formatDistance(survey.totalDistance))
            if let area = survey.estimatedArea {
                LabeledContent("Area", value: formatArea(area))
            }
            LabeledContent("Observations", value: "\(survey.observations.count)")
            LabeledContent("Status", value: survey.status.rawValue.capitalized)
        }
    }

    private var notesSection: some View {
        Section("Notes") {
            Text(survey.notes)
                .font(.body)
        }
    }

    private var observationsSection: some View {
        Section("Observations (\(survey.observations.count))") {
            if survey.observations.isEmpty {
                Text("No observations recorded")
                    .foregroundStyle(.secondary)
            } else {
                ForEach(sortedObservations) { observation in
                    NavigationLink(value: observation) {
                        ObservationRow(observation: observation)
                    }
                }
            }
        }
    }

    private var sortedObservations: [FieldObservation] {
        survey.observations.sorted { $0.timestamp < $1.timestamp }
    }

    private func formatDistance(_ meters: Double) -> String {
        if meters < 1000 {
            return String(format: "%.0f m", meters)
        } else {
            return String(format: "%.2f km", meters / 1000)
        }
    }

    private func formatArea(_ sqMeters: Double) -> String {
        if sqMeters < 10_000 {
            return String(format: "%.0f m\u{00B2}", sqMeters)
        } else {
            return String(format: "%.2f ha", sqMeters / 10_000)
        }
    }

    private func formatDuration(from start: Date, to end: Date) -> String {
        let interval = end.timeIntervalSince(start)
        let hours = Int(interval) / 3600
        let minutes = (Int(interval) % 3600) / 60
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
}

struct ObservationRow: View {
    let observation: FieldObservation

    var body: some View {
        HStack(spacing: 12) {
            photoThumbnail
            VStack(alignment: .leading, spacing: 4) {
                Text(observation.categoryLabel)
                    .font(.headline)
                Text(observation.timestamp.formatted(date: .abbreviated, time: .shortened))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }

    private var photoThumbnail: some View {
        Group {
            let docsDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let path = docsDir.appendingPathComponent("photos").appendingPathComponent(observation.photoFilename)
            if let uiImage = UIImage(contentsOfFile: path.path) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 56, height: 56)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            } else {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 56, height: 56)
                    .overlay {
                        Image(systemName: "photo")
                            .foregroundStyle(.secondary)
                    }
            }
        }
    }
}

extension FieldObservation {
    var categoryLabel: String {
        if let cat = formEntries.first(where: { $0.fieldLabel.lowercased().contains("category") || $0.fieldLabel.lowercased().contains("type") }) {
            return cat.value.isEmpty ? "Observation" : cat.value
        }
        return "Observation"
    }
}
