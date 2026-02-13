import SwiftUI

struct NotificationsTabView: View {
    @EnvironmentObject var appViewModel: AppViewModel

    private var settings: SettingsViewModel {
        appViewModel.settingsViewModel
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: ExTokens.Spacing._16) {
                // Section header
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Notifications")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(ExTokens.Colors.textPrimary)

                        Text("Get alerted when usage reaches thresholds")
                            .font(ExTokens.Typography.caption)
                            .foregroundColor(ExTokens.Colors.textTertiary)
                    }
                    Spacer()
                }

                // Master toggle card
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

                if settings.notificationsEnabled {
                    // Alert details card
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
                    .transition(.opacity.combined(with: .move(edge: .top)))

                    // Tip
                    HStack(spacing: 6) {
                        Image(systemName: "info.circle")
                            .font(.system(size: 10))
                            .foregroundColor(ExTokens.Colors.textMuted)

                        Text("Adjust thresholds in the Thresholds tab")
                            .font(.system(size: 10))
                            .foregroundColor(ExTokens.Colors.textMuted)
                    }
                }

                Spacer()
            }
            .padding(ExTokens.Spacing._24)
            .animation(.easeInOut(duration: 0.2), value: settings.notificationsEnabled)
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
