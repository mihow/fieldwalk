import SwiftUI
import CoreLocation

struct NewObservationView: View {
    let survey: Survey
    let location: CLLocation?
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Text("Observation capture — coming next")
                .navigationTitle("New Observation")
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") { dismiss() }
                    }
                }
        }
    }
}
