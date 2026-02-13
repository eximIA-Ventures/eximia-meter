import SwiftUI

struct ExProgressBar: View {
    let value: Double
    let label: String
    let detail: String?
    var warningThreshold: Double = 0.65
    var criticalThreshold: Double = 0.80

    var barColor: Color {
        if value >= criticalThreshold {
            return ExTokens.Colors.statusCritical
        } else if value >= warningThreshold {
            return ExTokens.Colors.statusWarning
        } else {
            return ExTokens.Colors.statusSuccess
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(label)
                    .font(ExTokens.Typography.subtitle)
                    .foregroundColor(ExTokens.Colors.textPrimary)

                Spacer()

                Text("\(Int(value * 100))%")
                    .font(ExTokens.Typography.captionMono)
                    .foregroundColor(barColor)
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: ExTokens.Radius.xs)
                        .fill(ExTokens.Colors.borderDefault)
                        .frame(height: 6)

                    RoundedRectangle(cornerRadius: ExTokens.Radius.xs)
                        .fill(barColor)
                        .frame(width: geo.size.width * CGFloat(min(value, 1.0)), height: 6)
                        .animation(.easeInOut(duration: 0.5), value: value)
                }
            }
            .frame(height: 6)

            if let detail {
                Text(detail)
                    .font(ExTokens.Typography.caption)
                    .foregroundColor(ExTokens.Colors.textMuted)
            }
        }
    }
}
