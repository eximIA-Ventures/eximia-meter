import SwiftUI

struct HeaderView: View {
    @EnvironmentObject var appViewModel: AppViewModel

    var body: some View {
        HStack(alignment: .center) {
            // Left: Logo + plan info
            HStack(alignment: .center, spacing: 8) {
                ExLogoIcon(size: 18)

                HStack(alignment: .lastTextBaseline, spacing: 4) {
                    Text("exímIA")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)

                    Text("Meter")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(ExTokens.Colors.accentPrimary)
                }

                Text(appViewModel.settingsViewModel.claudePlan.displayName)
                    .font(.system(size: 9, weight: .bold, design: .monospaced))
                    .foregroundColor(ExTokens.Colors.accentPrimary)
                    .padding(.horizontal, 5)
                    .padding(.vertical, 2)
                    .background(ExTokens.Colors.accentPrimary.opacity(0.15))
                    .clipShape(RoundedRectangle(cornerRadius: ExTokens.Radius.xs))
            }

            Spacer()

            // Right: Settings + Refresh
            HStack(spacing: 8) {
                Button {
                    appViewModel.refresh()
                } label: {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 11))
                        .foregroundColor(ExTokens.Colors.textMuted)
                }
                .buttonStyle(.plain)
                .help("Refresh data")

                Button {
                    AppDelegate.shared?.openSettings()
                } label: {
                    Image(systemName: "gearshape.fill")
                        .font(.system(size: 11))
                        .foregroundColor(ExTokens.Colors.textMuted)
                }
                .buttonStyle(.plain)
                .help("Settings")
            }
        }
        .padding(.horizontal, ExTokens.Spacing.popoverPadding)
        .padding(.vertical, ExTokens.Spacing._12)
    }
}
