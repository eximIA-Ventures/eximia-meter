import SwiftUI

struct HeatmapView: View {
    let hourCounts: [String: Int]

    private let hours = Array(0..<24)
    private let hourLabels = ["0", "3", "6", "9", "12", "15", "18", "21"]

    private var maxCount: Int {
        hourCounts.values.max() ?? 1
    }

    var body: some View {
        VStack(spacing: 4) {
            // Hour blocks grid (single row of 24 blocks)
            HStack(spacing: 2) {
                ForEach(hours, id: \.self) { hour in
                    let key = String(format: "%02d", hour)
                    let count = hourCounts[key] ?? hourCounts["\(hour)"] ?? 0
                    let intensity = maxCount > 0 ? Double(count) / Double(maxCount) : 0

                    RoundedRectangle(cornerRadius: 2)
                        .fill(cellColor(intensity: intensity))
                        .frame(height: 14)
                        .help("\(key):00 — \(count) sessões")
                }
            }

            // Hour labels
            HStack(spacing: 0) {
                ForEach(hourLabels, id: \.self) { label in
                    Text(label)
                        .font(.system(size: 7, weight: .medium, design: .monospaced))
                        .foregroundColor(ExTokens.Colors.textMuted)
                        .frame(maxWidth: .infinity)
                }
            }
        }
    }

    private func cellColor(intensity: Double) -> Color {
        if intensity == 0 {
            return ExTokens.Colors.backgroundElevated
        } else if intensity < 0.2 {
            return Color(hex: "#78350F").opacity(0.5) // Dark amber
        } else if intensity < 0.4 {
            return Color(hex: "#B45309").opacity(0.7) // Medium amber
        } else if intensity < 0.6 {
            return Color(hex: "#D97706") // Bright amber
        } else if intensity < 0.8 {
            return Color(hex: "#F59E0B") // Full amber
        } else {
            return Color(hex: "#FBBF24") // Brightest amber-yellow
        }
    }
}
