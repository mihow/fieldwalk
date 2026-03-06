import SwiftUI
import MapKit

struct ObservationDetailView: View {
    let observation: FieldObservation
    let survey: Survey

    private var mapRegion: MKCoordinateRegion {
        // Center on observation, but include track if possible
        var allLats = [observation.latitude]
        var allLons = [observation.longitude]
        for tp in survey.sortedTrackPoints {
            allLats.append(tp.latitude)
            allLons.append(tp.longitude)
        }
        let minLat = allLats.min()!
        let maxLat = allLats.max()!
        let minLon = allLons.min()!
        let maxLon = allLons.max()!

        let center = CLLocationCoordinate2D(
            latitude: (minLat + maxLat) / 2,
            longitude: (minLon + maxLon) / 2
        )
        let latDelta = max((maxLat - minLat) * 1.3, 0.002)
        let lonDelta = max((maxLon - minLon) * 1.3, 0.002)

        return MKCoordinateRegion(
            center: center,
            span: MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: lonDelta)
        )
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                photoSection
                mapSection
                detailsSection
                formEntriesSection
            }
            .padding()
        }
        .navigationTitle("Observation")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Photo

    private var photoSection: some View {
        Group {
            let docsDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let path = docsDir.appendingPathComponent("photos").appendingPathComponent(observation.photoFilename)
            if let uiImage = UIImage(contentsOfFile: path.path) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            } else {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 250)
                    .overlay {
                        VStack {
                            Image(systemName: "photo")
                                .font(.largeTitle)
                            Text("Photo not found")
                                .font(.caption)
                        }
                        .foregroundStyle(.secondary)
                    }
            }
        }
    }

    // MARK: - Map

    private var mapSection: some View {
        OSMMapView(
            trackCoordinates: survey.sortedTrackPoints.map {
                CLLocationCoordinate2D(latitude: $0.latitude, longitude: $0.longitude)
            },
            annotations: [(
                coordinate: CLLocationCoordinate2D(latitude: observation.latitude, longitude: observation.longitude),
                title: observation.categoryLabel
            )],
            region: mapRegion
        )
        .frame(height: 200)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - Details

    private var detailsSection: some View {
        GroupBox("Details") {
            VStack(spacing: 0) {
                detailRow(label: "Timestamp", value: observation.timestamp.formatted(date: .abbreviated, time: .standard))
                Divider()
                detailRow(label: "Latitude", value: String(format: "%.6f", observation.latitude))
                Divider()
                detailRow(label: "Longitude", value: String(format: "%.6f", observation.longitude))
                Divider()
                detailRow(label: "Photo", value: observation.photoFilename)
            }
        }
    }

    // MARK: - Form Entries

    @ViewBuilder
    private var formEntriesSection: some View {
        if !observation.formEntries.isEmpty {
            GroupBox("Form Data") {
                VStack(spacing: 0) {
                    let sorted = observation.formEntries.sorted { $0.fieldLabel < $1.fieldLabel }
                    ForEach(Array(sorted.enumerated()), id: \.element.id) { index, entry in
                        if index > 0 { Divider() }
                        detailRow(label: entry.fieldLabel, value: entry.value.isEmpty ? "-" : entry.value)
                    }
                }
            }
        }
    }

    private func detailRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .multilineTextAlignment(.trailing)
        }
        .font(.subheadline)
        .padding(.vertical, 6)
    }
}
