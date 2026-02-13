import SwiftUI

struct FooterView: View {
    @EnvironmentObject var appViewModel: AppViewModel

    var body: some View {
        HStack(spacing: ExTokens.Spacing._12) {
            Text("Updated \(appViewModel.usageViewModel.timeSinceUpdate)")
                .font(ExTokens.Typography.caption)
                .foregroundColor(ExTokens.Colors.textMuted)

            Spacer()

            // Refresh
            Button {
                appViewModel.refresh()
            } label: {
                Image(systemName: "arrow.clockwise")
                    .font(.system(size: 12))
                    .foregroundColor(ExTokens.Colors.accentPrimary)
            }
            .buttonStyle(.plain)
            .help("Refresh data")

            // Settings — use NSApp.sendAction to open Settings scene
            Button {
                openSettingsWindow()
            } label: {
                Image(systemName: "gearshape.fill")
                    .font(.system(size: 12))
                    .foregroundColor(ExTokens.Colors.textTertiary)
            }
            .buttonStyle(.plain)
            .help("Settings")

            // Quit
            Button {
                NSApplication.shared.terminate(nil)
            } label: {
                Text("Quit")
                    .font(ExTokens.Typography.caption)
                    .foregroundColor(ExTokens.Colors.statusCritical)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, ExTokens.Spacing.popoverPadding)
        .padding(.vertical, ExTokens.Spacing._8)
    }

    private func openSettingsWindow() {
        AppDelegate.shared?.openSettings()
    }
}
