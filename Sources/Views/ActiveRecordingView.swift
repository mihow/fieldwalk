import SwiftUI

struct ActiveRecordingView: View {
    let survey: Survey
    var body: some View {
        Text("Recording: \(survey.name)")
    }
}
