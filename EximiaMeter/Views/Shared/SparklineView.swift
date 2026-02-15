import SwiftUI

struct SparklineView: View {
    let data: [(String, Int)]
    var barColor: Color = ExTokens.Colors.accentPrimary

    private var maxValue: Int {
        data.map(\.1).max() ?? 1
    }

    var body: some View {
        HStack(alignment: .bottom, spacing: 4) {
            ForEach(Array(data.enumerated()), id: \.offset) { _, item in
                let (label, value) = item
                let ratio = maxValue > 0 ? CGFloat(value) / CGFloat(maxValue) : 0
                let isToday = label == "Hoje"

                VStack(spacing: 3) {
                    // Token count above bar
                    if value > 0 {
                        Text(formatShort(value))
                            .font(.system(size: 7, weight: .bold, design: .monospaced))
                            .foregroundColor(isToday ? barColor : ExTokens.Colors.textTertiary)
                    }

                    // Bar with gradient
                    RoundedRectangle(cornerRadius: 3)
                        .fill(
                            LinearGradient(
                                colors: value == 0
                                    ? [ExTokens.Colors.borderDefault, ExTokens.Colors.borderDefault]
                                    : (isToday
                                        ? [barColor.opacity(0.8), barColor]
                                        : [barColor.opacity(0.15 + 0.35 * ratio), barColor.opacity(0.25 + 0.55 * ratio)]),
                                startPoint: .bottom,
                                endPoint: .top
                            )
                        )
                        .frame(height: max(4, 50 * ratio))

                    Text(label)
                        .font(.system(size: 7, weight: isToday ? .bold : .regular, design: .monospaced))
                        .foregroundColor(isToday ? ExTokens.Colors.textSecondary : ExTokens.Colors.textMuted)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .frame(height: 76)
    }

    private func formatShort(_ count: Int) -> String {
        if count >= 1_000_000 {
            return String(format: "%.1fM", Double(count) / 1_000_000)
        } else if count >= 1_000 {
            return String(format: "%.0fK", Double(count) / 1_000)
        }
        return "\(count)"
    }
}
