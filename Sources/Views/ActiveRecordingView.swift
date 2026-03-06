import SwiftUI
import SwiftData
import MapKit

struct ActiveRecordingView: View {
    let survey: Survey
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel: RecordingViewModel?
    @State private var locationService = LocationService()
    @State private var cameraPosition: MapCameraPosition = .automatic

    var body: some View {
        if let viewModel {
            RecordingContentView(
                survey: survey,
                viewModel: viewModel,
                locationService: locationService,
                cameraPosition: $cameraPosition
            )
        } else {
            ProgressView("Starting...")
                .onAppear {
                    let vm = RecordingViewModel(
                        survey: survey,
                        locationService: locationService,
                        modelContext: modelContext
                    )
                    viewModel = vm
                    if survey.status == .paused {
                        vm.resumeRecording()
                    } else {
                        vm.startRecording()
                    }
                }
        }
    }
}

private struct RecordingContentView: View {
    let survey: Survey
    @Bindable var viewModel: RecordingViewModel
    let locationService: LocationService
    @Binding var cameraPosition: MapCameraPosition
    @State private var hasInitialLocation = false

    var body: some View {
        VStack(spacing: 0) {
            StatsBar(
                time: viewModel.formattedTime,
                distance: viewModel.formattedDistance,
                area: viewModel.formattedArea,
                observationCount: survey.observations.count
            )

            Map(position: $cameraPosition) {
                UserAnnotation()
                if survey.sortedTrackPoints.count > 1 {
                    MapPolyline(coordinates: survey.sortedTrackPoints.map {
                        CLLocationCoordinate2D(latitude: $0.latitude, longitude: $0.longitude)
                    })
                    .stroke(.blue, lineWidth: 3)
                }
                ForEach(survey.observations) { obs in
                    Marker(obs.formEntries.first?.value ?? "Obs", coordinate:
                        CLLocationCoordinate2D(latitude: obs.latitude, longitude: obs.longitude))
                    .tint(.orange)
                }
            }
            .mapControls {
                MapUserLocationButton()
                MapCompass()
            }
            .onChange(of: locationService.currentLocation) { _, newLocation in
                guard let loc = newLocation else { return }
                if !hasInitialLocation {
                    hasInitialLocation = true
                    cameraPosition = .region(MKCoordinateRegion(
                        center: loc.coordinate,
                        latitudinalMeters: 500,
                        longitudinalMeters: 500
                    ))
                }
            }

            controlBar
        }
        .navigationTitle(survey.name)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .alert("End Survey?", isPresented: $viewModel.showStopConfirmation) {
            Button("End", role: .destructive) {
                viewModel.stopRecording()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This will finish recording and save the survey.")
        }
        .sheet(isPresented: $viewModel.showObservationSheet) {
            NewObservationView(survey: survey, location: locationService.currentLocation)
        }
    }

    private var controlBar: some View {
        HStack(spacing: 40) {
            Button(action: { viewModel.showStopConfirmation = true }) {
                Image(systemName: "stop.fill")
                    .font(.title2)
                    .foregroundStyle(.white)
                    .frame(width: 50, height: 50)
                    .background(.red)
                    .clipShape(Circle())
            }

            Button(action: {
                if viewModel.isPaused { viewModel.resumeRecording() } else { viewModel.pauseRecording() }
            }) {
                Image(systemName: viewModel.isPaused ? "record.circle" : "pause.fill")
                    .font(.largeTitle)
                    .foregroundStyle(.white)
                    .frame(width: 70, height: 70)
                    .background(viewModel.isPaused ? .green : .orange)
                    .clipShape(Circle())
            }

            Button(action: { viewModel.showObservationSheet = true }) {
                Image(systemName: "camera.fill")
                    .font(.title2)
                    .foregroundStyle(.white)
                    .frame(width: 50, height: 50)
                    .background(.blue)
                    .clipShape(Circle())
            }
        }
        .padding(.vertical, 16)
        .frame(maxWidth: .infinity)
        .background(.ultraThinMaterial)
    }
}
