import SwiftUI
import SwiftData
import MapKit

struct SurveyListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Survey.startDate, order: .reverse) private var surveys: [Survey]
    @State private var showingNewSurvey = false

    var body: some View {
        NavigationStack {
            Group {
                if surveys.isEmpty {
                    ContentUnavailableView(
                        "No Surveys Yet",
                        systemImage: "map",
                        description: Text("Tap + to start your first survey.")
                    )
                } else {
                    List(surveys) { survey in
                        NavigationLink(value: survey) {
                            SurveyRow(survey: survey)
                        }
                    }
                }
            }
            .navigationTitle("Surveys")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: { showingNewSurvey = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingNewSurvey) {
                NewSurveyView()
            }
            .navigationDestination(for: Survey.self) { survey in
                if survey.status == .completed {
                    SurveyDetailView(survey: survey)
                } else {
                    ActiveRecordingView(survey: survey)
                }
            }
        }
    }
}

struct SurveyRow: View {
    let survey: Survey

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(survey.name)
                    .font(.headline)
                if survey.status != .completed {
                    Text("In Progress")
                        .font(.caption)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(.orange.opacity(0.2))
                        .foregroundStyle(.orange)
                        .clipShape(Capsule())
                }
            }
            HStack(spacing: 12) {
                Label(survey.startDate.formatted(date: .abbreviated, time: .shortened), systemImage: "calendar")
                Label(formatDistance(survey.totalDistance), systemImage: "figure.walk")
                Label("\(survey.observations.count)", systemImage: "camera")
            }
            .font(.caption)
            .foregroundStyle(.secondary)
        }
        .padding(.vertical, 4)
    }

    private func formatDistance(_ meters: Double) -> String {
        if meters >= 1000 {
            return String(format: "%.1f km", meters / 1000)
        }
        return String(format: "%.0f m", meters)
    }
}
