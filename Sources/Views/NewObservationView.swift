import SwiftUI
import SwiftData
import PhotosUI
import CoreLocation

struct NewObservationView: View {
    let survey: Survey
    let location: CLLocation?
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var capturedImage: UIImage?
    @State private var showCamera = false
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var formEntries: [FormEntry] = DefaultTemplate.createEntries()

    var body: some View {
        NavigationStack {
            Form {
                Section("Photo") {
                    if let capturedImage {
                        Image(uiImage: capturedImage)
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: 200)
                    }
                    HStack {
                        Button("Take Photo") { showCamera = true }
                        Spacer()
                        PhotosPicker("From Library", selection: $selectedPhotoItem, matching: .images)
                    }
                }

                Section("Location") {
                    if let loc = location {
                        LabeledContent("Latitude", value: String(format: "%.6f", loc.coordinate.latitude))
                        LabeledContent("Longitude", value: String(format: "%.6f", loc.coordinate.longitude))
                    } else {
                        Text("Location unavailable")
                            .foregroundStyle(.secondary)
                    }
                }

                Section("Details") {
                    ForEach(formEntries) { entry in
                        FormFieldView(entry: entry)
                    }
                }

                Section {
                    HStack {
                        Image(systemName: "mic.fill")
                            .foregroundStyle(.secondary)
                        Text("Voice input")
                            .foregroundStyle(.secondary)
                        Spacer()
                        Text("Coming soon")
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                    }
                }
            }
            .navigationTitle("New Observation")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { saveObservation() }
                        .disabled(capturedImage == nil)
                }
            }
            .fullScreenCover(isPresented: $showCamera) {
                CameraView(image: $capturedImage)
                    .ignoresSafeArea()
            }
            .onChange(of: selectedPhotoItem) { _, item in
                Task {
                    if let data = try? await item?.loadTransferable(type: Data.self),
                       let image = UIImage(data: data) {
                        capturedImage = image
                    }
                }
            }
        }
    }

    private func saveObservation() {
        guard let image = capturedImage else { return }
        let filename = "obs_\(UUID().uuidString).jpg"
        let loc = location ?? CLLocation(latitude: 0, longitude: 0)

        // Save photo to app documents
        if let data = image.jpegData(compressionQuality: 0.8) {
            let docsDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let photosDir = docsDir.appendingPathComponent("photos", isDirectory: true)
            try? FileManager.default.createDirectory(at: photosDir, withIntermediateDirectories: true)
            try? data.write(to: photosDir.appendingPathComponent(filename))
        }

        let observation = FieldObservation(
            photoFilename: filename,
            latitude: loc.coordinate.latitude,
            longitude: loc.coordinate.longitude,
            timestamp: Date()
        )

        for entry in formEntries {
            entry.observation = observation
            observation.formEntries.append(entry)
            modelContext.insert(entry)
        }

        observation.survey = survey
        survey.observations.append(observation)
        modelContext.insert(observation)
        try? modelContext.save()
        dismiss()
    }
}
