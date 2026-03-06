import SwiftUI

struct StatsBar: View {
    let time: String
    let distance: String
    let area: String?
    let observationCount: Int

    var body: some View {
        HStack(spacing: 0) {
            StatItem(icon: "clock", value: time, label: "Time")
            Divider().frame(height: 30)
            StatItem(icon: "figure.walk", value: distance, label: "Distance")
            if let area {
                Divider().frame(height: 30)
                StatItem(icon: "square.dashed", value: area, label: "Area")
            }
            Divider().frame(height: 30)
            StatItem(icon: "camera", value: "\(observationCount)", label: "Obs")
        }
        .padding(.vertical, 8)
        .background(.ultraThinMaterial)
    }
}

struct StatItem: View {
    let icon: String
    let value: String
    let label: String

    var body: some View {
        VStack(spacing: 2) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.caption)
                Text(value)
                    .font(.system(.body, design: .monospaced, weight: .semibold))
            }
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}
