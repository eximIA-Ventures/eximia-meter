import SwiftUI

struct PopoverContentView: View {
    @EnvironmentObject var appViewModel: AppViewModel

    var body: some View {
        VStack(spacing: 0) {
            HeaderView()

            // Subtle amber gradient separator
            LinearGradient(
                colors: [.clear, ExTokens.Colors.accentPrimary.opacity(0.3), .clear],
                startPoint: .leading,
                endPoint: .trailing
            )
            .frame(height: 1)

            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: ExTokens.Spacing._12) {
                    ProjectCarouselView()
                        .padding(.top, ExTokens.Spacing._8)

                    // Subtle divider
                    Rectangle()
                        .fill(ExTokens.Colors.borderDefault)
                        .frame(height: 1)
                        .padding(.horizontal, ExTokens.Spacing.popoverPadding)

                    UsageMetersSection()

                    HistorySection()
                }
                .padding(.bottom, ExTokens.Spacing._12)
            }

            Rectangle()
                .fill(ExTokens.Colors.borderDefault)
                .frame(height: 1)

            FooterView()
        }
        .frame(width: 420, height: 620)
        .background(ExTokens.Colors.backgroundPrimary)
    }
}
