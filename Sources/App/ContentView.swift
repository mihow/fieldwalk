import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var seeded = false

    var body: some View {
        SurveyListView()
            .task {
                guard !seeded else { return }
                seeded = true
                #if targetEnvironment(simulator)
                FixtureData.seedIfEmpty(context: modelContext)
                #endif
            }
    }
}

/// Auto-tour view: cycles through all screens automatically, holding each for a set duration.
/// Launch by setting app entry point to ScreenTourView.
struct ScreenTourView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Survey.startDate, order: .reverse) private var surveys: [Survey]
    @State private var currentIndex = 0
    @State private var seeded = false

    private let screenNames = ["list", "detail", "observation", "new_survey", "debug_map"]
    private let holdSeconds: Double = 8

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Screen label banner
                Text("Screen \(currentIndex + 1)/\(screenNames.count): \(screenNames[currentIndex])")
                    .font(.caption)
                    .padding(4)
                    .frame(maxWidth: .infinity)
                    .background(Color.blue.opacity(0.2))

                screenView(for: screenNames[currentIndex])
            }
        }
        .task {
            if !seeded {
                seeded = true
                FixtureData.seedIfEmpty(context: modelContext)
            }
            // Auto-advance through screens
            for i in 0..<screenNames.count {
                try? await Task.sleep(for: .seconds(holdSeconds))
                if i + 1 < screenNames.count {
                    currentIndex = i + 1
                }
            }
        }
    }

    @ViewBuilder
    private func screenView(for screen: String) -> some View {
        switch screen {
        case "detail":
            if let completed = surveys.first(where: { $0.status == .completed }) {
                SurveyDetailView(survey: completed)
            } else {
                Text("No completed survey")
            }
        case "observation":
            if let completed = surveys.first(where: { $0.status == .completed }),
               let obs = completed.observations.first {
                ObservationDetailView(observation: obs, survey: completed)
            } else {
                Text("No observation")
            }
        case "new_survey":
            NewSurveyView()
        case "debug_map":
            DebugMapTestView()
        default:
            SurveyListView()
        }
    }
}
