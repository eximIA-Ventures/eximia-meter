import SwiftUI

struct ThresholdsTabView: View {
    @EnvironmentObject var appViewModel: AppViewModel

    private var settings: SettingsViewModel {
        appViewModel.settingsViewModel
    }

    var body: some View {
        ScrollView {
            VStack(spacing: ExTokens.Spacing._16) {
                // Section header
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Alert Thresholds")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(ExTokens.Colors.textPrimary)

                        Text("Configure when to show warnings and critical alerts")
                            .font(ExTokens.Typography.caption)
                            .foregroundColor(ExTokens.Colors.textTertiary)
                    }
                    Spacer()
                }

                // Current Session
                thresholdCard(
                    icon: "bolt.fill",
                    title: "Current Session",
                    subtitle: "Tokens used in active session",
                    warningValue: Binding(
                        get: { settings.thresholds.sessionWarning },
                        set: { settings.thresholds.sessionWarning = $0 }
                    ),
                    criticalValue: Binding(
                        get: { settings.thresholds.sessionCritical },
                        set: { settings.thresholds.sessionCritical = $0 }
                    )
                )

                // Weekly Limits
                thresholdCard(
                    icon: "calendar",
                    title: "Weekly Limits",
                    subtitle: "Token budget for the current week",
                    warningValue: Binding(
                        get: { settings.thresholds.weeklyWarning },
                        set: { settings.thresholds.weeklyWarning = $0 }
                    ),
                    criticalValue: Binding(
                        get: { settings.thresholds.weeklyCritical },
                        set: { settings.thresholds.weeklyCritical = $0 }
                    )
                )
            }
            .padding(ExTokens.Spacing._24)
        }
    }

    private func thresholdCard(
        icon: String,
        title: String,
        subtitle: String,
        warningValue: Binding<Double>,
        criticalValue: Binding<Double>
    ) -> some View {
        VStack(alignment: .leading, spacing: ExTokens.Spacing._16) {
            // Card header
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(ExTokens.Colors.accentPrimary)

                VStack(alignment: .leading, spacing: 1) {
                    Text(title)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(ExTokens.Colors.textPrimary)

                    Text(subtitle)
                        .font(.system(size: 10))
                        .foregroundColor(ExTokens.Colors.textMuted)
                }
            }

            // Preview bar
            previewBar(warning: warningValue.wrappedValue, critical: criticalValue.wrappedValue)

            // Warning slider
            sliderRow(
                color: ExTokens.Colors.statusWarning,
                label: "Warning",
                value: warningValue
            )

            // Critical slider
            sliderRow(
                color: ExTokens.Colors.statusCritical,
                label: "Critical",
                value: criticalValue
            )
        }
        .padding(ExTokens.Spacing._16)
        .background(ExTokens.Colors.backgroundCard)
        .overlay(
            RoundedRectangle(cornerRadius: ExTokens.Radius.lg)
                .stroke(ExTokens.Colors.borderDefault, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: ExTokens.Radius.lg))
    }

    private func previewBar(warning: Double, critical: Double) -> some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                // Track
                RoundedRectangle(cornerRadius: 3)
                    .fill(ExTokens.Colors.backgroundElevated)

                // Green zone
                RoundedRectangle(cornerRadius: 3)
                    .fill(ExTokens.Colors.statusSuccess.opacity(0.3))
                    .frame(width: geo.size.width * warning)

                // Warning marker
                Rectangle()
                    .fill(ExTokens.Colors.statusWarning)
                    .frame(width: 2)
                    .offset(x: geo.size.width * warning - 1)

                // Critical marker
                Rectangle()
                    .fill(ExTokens.Colors.statusCritical)
                    .frame(width: 2)
                    .offset(x: geo.size.width * critical - 1)
            }
        }
        .frame(height: 8)
        .clipShape(RoundedRectangle(cornerRadius: 3))
    }

    private func sliderRow(color: Color, label: String, value: Binding<Double>) -> some View {
        HStack(spacing: 10) {
            Circle()
                .fill(color)
                .frame(width: 6, height: 6)

            Text(label)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(ExTokens.Colors.textSecondary)
                .frame(width: 55, alignment: .leading)

            Slider(value: value, in: 0.1...0.99)
                .tint(color)

            Text("\(Int(value.wrappedValue * 100))%")
                .font(.system(size: 11, weight: .bold, design: .monospaced))
                .foregroundColor(color)
                .frame(width: 36, alignment: .trailing)
        }
    }
}
