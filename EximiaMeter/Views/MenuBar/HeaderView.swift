import SwiftUI

struct HeaderView: View {
    @EnvironmentObject var appViewModel: AppViewModel

    @State private var selectedOptimization: OptimizationLevel = .med

    var body: some View {
        HStack(alignment: .top) {
            // Left: Logo + plan info
            VStack(alignment: .leading, spacing: 2) {
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
                }

                Text("plan: max20x")
                    .font(ExTokens.Typography.captionMono)
                    .foregroundColor(ExTokens.Colors.textMuted)
            }

            Spacer()

            // Right: Global model + optimization
            VStack(alignment: .trailing, spacing: 4) {
                Text("Global model")
                    .font(ExTokens.Typography.caption)
                    .foregroundColor(ExTokens.Colors.textMuted)

                HStack(spacing: 12) {
                    ModelPickerView(selectedModel: $appViewModel.globalModel)

                    OptimizationPickerView(level: $selectedOptimization)
                }
            }
        }
        .padding(.horizontal, ExTokens.Spacing.popoverPadding)
        .padding(.vertical, ExTokens.Spacing._12)
    }
}
