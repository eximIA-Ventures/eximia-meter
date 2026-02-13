import SwiftUI

struct SettingsWindowView: View {
    @EnvironmentObject var appViewModel: AppViewModel
    @State private var selectedTab = 0

    private let tabs = [
        ("gauge.with.dots.needle.33percent", "Thresholds"),
        ("gearshape", "General"),
        ("folder", "Projects"),
        ("bell", "Notifications")
    ]

    var body: some View {
        VStack(spacing: 0) {
            // Custom tab bar
            HStack(spacing: 0) {
                ForEach(Array(tabs.enumerated()), id: \.offset) { index, tab in
                    settingsTab(icon: tab.0, label: tab.1, index: index)
                }
            }
            .padding(.horizontal, ExTokens.Spacing._16)
            .padding(.top, ExTokens.Spacing._16)
            .padding(.bottom, ExTokens.Spacing._8)

            // Subtle divider
            Rectangle()
                .fill(ExTokens.Colors.borderDefault)
                .frame(height: 1)

            // Content
            Group {
                switch selectedTab {
                case 0: ThresholdsTabView()
                case 1: GeneralTabView()
                case 2: ProjectsTabView()
                case 3: NotificationsTabView()
                default: ThresholdsTabView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(width: 520, height: 460)
        .background(ExTokens.Colors.backgroundPrimary)
    }

    private func settingsTab(icon: String, label: String, index: Int) -> some View {
        let isSelected = selectedTab == index

        return Button {
            withAnimation(.easeInOut(duration: 0.15)) {
                selectedTab = index
            }
        } label: {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 14, weight: isSelected ? .semibold : .regular))
                    .foregroundColor(isSelected ? ExTokens.Colors.accentPrimary : ExTokens.Colors.textMuted)

                Text(label)
                    .font(.system(size: 10, weight: isSelected ? .bold : .medium))
                    .foregroundColor(isSelected ? ExTokens.Colors.textPrimary : ExTokens.Colors.textTertiary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .background(
                isSelected
                    ? ExTokens.Colors.backgroundCard
                    : Color.clear
            )
            .overlay(alignment: .bottom) {
                if isSelected {
                    Rectangle()
                        .fill(ExTokens.Colors.accentPrimary)
                        .frame(height: 2)
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: ExTokens.Radius.sm))
        }
        .buttonStyle(.plain)
    }
}
