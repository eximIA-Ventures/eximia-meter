import SwiftUI

struct AlertsTabView: View {
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
                        Text("Alerts")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(ExTokens.Colors.textPrimary)

                        Text("Notifications and usage thresholds")
                            .font(ExTokens.Typography.caption)
                            .foregroundColor(ExTokens.Colors.textTertiary)
                    }
                    Spacer()
                }

                // Notifications toggle
                HStack {
                    Image(systemName: settings.notificationsEnabled ? "bell.fill" : "bell.slash")
                        .font(.system(size: 13))
                        .foregroundColor(settings.notificationsEnabled ? ExTokens.Colors.accentPrimary : ExTokens.Colors.textMuted)

                    Text("Enable Notifications")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(ExTokens.Colors.textPrimary)

                    Spacer()

                    Toggle("", isOn: Binding(
                        get: { settings.notificationsEnabled },
                        set: { settings.notificationsEnabled = $0 }
                    ))
                    .toggleStyle(.switch)
                    .tint(ExTokens.Colors.accentPrimary)
                    .labelsHidden()
                }
                .padding(ExTokens.Spacing._16)
                .background(ExTokens.Colors.backgroundCard)
                .overlay(
                    RoundedRectangle(cornerRadius: ExTokens.Radius.lg)
                        .stroke(ExTokens.Colors.borderDefault, lineWidth: 1)
                )
                .clipShape(RoundedRectangle(cornerRadius: ExTokens.Radius.lg))

                // Session thresholds
                thresholdCard(
                    icon: "bolt.fill",
                    title: "Session Thresholds",
                    subtitle: "5-hour rolling window",
                    warningValue: Binding(
                        get: { settings.thresholds.sessionWarning },
                        set: { settings.thresholds.sessionWarning = $0 }
                    ),
                    criticalValue: Binding(
                        get: { settings.thresholds.sessionCritical },
                        set: { settings.thresholds.sessionCritical = $0 }
                    )
                )

                // Weekly thresholds
                thresholdCard(
                    icon: "calendar",
                    title: "Weekly Thresholds",
                    subtitle: "7-day rolling window",
                    warningValue: Binding(
                        get: { settings.thresholds.weeklyWarning },
                        set: { settings.thresholds.weeklyWarning = $0 }
                    ),
                    criticalValue: Binding(
                        get: { settings.thresholds.weeklyCritical },
                        set: { settings.thresholds.weeklyCritical = $0 }
                    )
                )

                // Active Alerts summary
                if settings.notificationsEnabled {
                    activeAlertsSummary
                        .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
            .padding(ExTokens.Spacing._24)
            .animation(.easeInOut(duration: 0.2), value: settings.notificationsEnabled)
        }
    }

    // MARK: - Active Alerts Summary

    private var activeAlertsSummary: some View {
        VStack(alignment: .leading, spacing: ExTokens.Spacing._12) {
            HStack(spacing: 6) {
                Image(systemName: "list.bullet")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(ExTokens.Colors.accentPrimary)

                Text("Active Alerts")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(ExTokens.Colors.textPrimary)
            }

            alertRow(
                color: ExTokens.Colors.statusWarning,
                icon: "exclamationmark.triangle.fill",
                text: "Session warning",
                value: "\(Int(settings.thresholds.sessionWarning * 100))%"
            )

            alertRow(
                color: ExTokens.Colors.statusCritical,
                icon: "exclamationmark.octagon.fill",
                text: "Session critical",
                value: "\(Int(settings.thresholds.sessionCritical * 100))%"
            )

            Rectangle()
                .fill(ExTokens.Colors.borderDefault)
                .frame(height: 1)

            alertRow(
                color: ExTokens.Colors.statusWarning,
                icon: "exclamationmark.triangle.fill",
                text: "Weekly warning",
                value: "\(Int(settings.thresholds.weeklyWarning * 100))%"
            )

            alertRow(
                color: ExTokens.Colors.statusCritical,
                icon: "exclamationmark.octagon.fill",
                text: "Weekly critical",
                value: "\(Int(settings.thresholds.weeklyCritical * 100))%"
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

    // MARK: - Threshold Card

    private func thresholdCard(
        icon: String,
        title: String,
        subtitle: String,
        warningValue: Binding<Double>,
        criticalValue: Binding<Double>
    ) -> some View {
        VStack(alignment: .leading, spacing: ExTokens.Spacing._16) {
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

            previewBar(warning: warningValue.wrappedValue, critical: criticalValue.wrappedValue)

            sliderRow(
                color: ExTokens.Colors.statusWarning,
                label: "Warning",
                value: warningValue
            )

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

    // MARK: - Helpers

    private func previewBar(warning: Double, critical: Double) -> some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 3)
                    .fill(ExTokens.Colors.backgroundElevated)

                RoundedRectangle(cornerRadius: 3)
                    .fill(ExTokens.Colors.statusSuccess.opacity(0.3))
                    .frame(width: geo.size.width * warning)

                Rectangle()
                    .fill(ExTokens.Colors.statusWarning)
                    .frame(width: 2)
                    .offset(x: geo.size.width * warning - 1)

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

    private func alertRow(color: Color, icon: String, text: String, value: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 10))
                .foregroundColor(color)

            Text(text)
                .font(.system(size: 11))
                .foregroundColor(ExTokens.Colors.textSecondary)

            Spacer()

            Text(value)
                .font(.system(size: 10, weight: .bold, design: .monospaced))
                .foregroundColor(color)
        }
    }
}
