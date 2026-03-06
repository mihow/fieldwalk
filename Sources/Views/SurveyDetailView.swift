import SwiftUI

struct SurveyDetailView: View {
    let survey: Survey
    var body: some View {
        Text("Detail: \(survey.name)")
    }
}
