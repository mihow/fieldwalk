import SwiftUI
import SwiftData

@main
struct FieldWalkApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [Survey.self, TrackPoint.self, FieldObservation.self, FormEntry.self])
    }
}
