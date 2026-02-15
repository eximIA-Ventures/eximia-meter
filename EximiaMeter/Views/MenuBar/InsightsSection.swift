import SwiftUI

struct InsightsSection: View {
    @EnvironmentObject var appViewModel: AppViewModel

    @State private var isExpanded = true

    private var usage: UsageViewModel {
        appViewModel.usageViewModel
    }

    private var hasAnyInsight: Bool {
        usage.estimatedWeeklyCostUSD > 0 ||
        usage.usageStreak > 1 ||
        usage.peakDetectionMessage != nil ||
        usage.modelSuggestion != nil ||
        usage.weekOverWeekChange != nil ||
        !usage.last7DaysTokens.isEmpty
    }

    var body: some View {
        if hasAnyInsight {
            VStack(spacing: ExTokens.Spacing._12) {
                // Header
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        isExpanded.toggle()
                    }
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: isExpanded ? "chevron.down" : "chevron.right")
                            .font(.system(size: 8, weight: .bold))
                            .foregroundColor(ExTokens.Colors.textMuted)

                        Text("INSIGHTS")
                            .font(ExTokens.Typography.label)
                            .tracking(1.5)
                            .foregroundColor(ExTokens.Colors.textMuted)

                        Spacer()
                    }
                    .padding(.vertical, 4)
                    .contentShape(Rectangle())
                }
                .buttonStyle(HoverableButtonStyle())

                if isExpanded {
                    VStack(spacing: ExTokens.Spacing._12) {
                        // Top row: Cost + Streak + Week comparison
                        HStack(spacing: ExTokens.Spacing._6) {
                            if usage.estimatedWeeklyCostUSD > 0 {
                                InsightPill(
                                    icon: "dollarsign.circle.fill",
                                    label: "CUSTO 7D",
                                    value: usage.formattedWeeklyCost,
                                    color: ExTokens.Colors.statusWarning
                                )
                            }

                            if usage.usageStreak > 1 {
                                InsightPill(
                                    icon: "flame.fill",
                                    label: "STREAK",
                                    value: "\(usage.usageStreak)d",
                                    color: ExTokens.Colors.accentPrimary
                                )
                            }

                            if let wow = usage.weekOverWeekChange {
                                InsightPill(
                                    icon: usage.weekOverWeekIsUp ? "arrow.up.right" : "arrow.down.right",
                                    label: "SEMANA",
                                    value: wow,
                                    color: usage.weekOverWeekIsUp ? ExTokens.Colors.statusWarning : ExTokens.Colors.statusSuccess
                                )
                            }
                        }

                        // Sparkline (7 days)
                        if !usage.last7DaysTokens.isEmpty && usage.last7DaysTokens.contains(where: { $0.1 > 0 }) {
                            insightCard {
                                VStack(alignment: .leading, spacing: 6) {
                                    insightSectionHeader("TOKENS POR DIA (7D)", icon: "chart.bar.fill")

                                    SparklineView(data: usage.last7DaysTokens)
                                }
                            }
                        }

                        // Activity heatmap
                        if !usage.hourCounts.isEmpty {
                            insightCard {
                                VStack(alignment: .leading, spacing: 6) {
                                    insightSectionHeader("ATIVIDADE POR HORA", icon: "clock.fill")

                                    HeatmapView(hourCounts: usage.hourCounts)
                                }
                            }
                        }

                        // Peak detection alert
                        if let peak = usage.peakDetectionMessage {
                            insightAlert(
                                icon: "bolt.fill",
                                message: peak,
                                color: ExTokens.Colors.statusWarning
                            )
                        }

                        // Model suggestion
                        if let suggestion = usage.modelSuggestion {
                            insightAlert(
                                icon: "lightbulb.fill",
                                message: suggestion,
                                color: ExTokens.Colors.accentPrimary
                            )
                        }
                    }
                }
            }
            .padding(.horizontal, ExTokens.Spacing.popoverPadding)
        }
    }

    // MARK: - Shared Components

    private func insightSectionHeader(_ title: String, icon: String) -> some View {
        HStack(spacing: 5) {
            Image(systemName: icon)
                .font(.system(size: 8))
                .foregroundColor(ExTokens.Colors.accentPrimary.opacity(0.6))
            Text(title)
                .font(.system(size: 8, weight: .bold))
                .tracking(1)
                .foregroundColor(ExTokens.Colors.textMuted)
        }
    }

    private func insightCard<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        content()
            .padding(10)
            .background(ExTokens.Colors.backgroundCard)
            .clipShape(RoundedRectangle(cornerRadius: ExTokens.Radius.md))
            .overlay(
                RoundedRectangle(cornerRadius: ExTokens.Radius.md)
                    .stroke(ExTokens.Colors.borderDefault, lineWidth: 1)
            )
    }

    private func insightAlert(icon: String, message: String, color: Color) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 10))
                .foregroundColor(color)
                .frame(width: 22, height: 22)
                .background(color.opacity(0.15))
                .clipShape(RoundedRectangle(cornerRadius: 5))

            Text(message)
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(color == ExTokens.Colors.accentPrimary ? ExTokens.Colors.textSecondary : color)
                .lineLimit(2)

            Spacer()
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(color.opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: ExTokens.Radius.md))
        .overlay(
            RoundedRectangle(cornerRadius: ExTokens.Radius.md)
                .stroke(color.opacity(0.15), lineWidth: 1)
        )
    }
}

// MARK: - Insight Pill

struct InsightPill: View {
    let icon: String
    let label: String
    let value: String
    let color: Color

    @State private var isHovered = false

    var body: some View {
        VStack(spacing: 5) {
            // Icon with colored background
            Image(systemName: icon)
                .font(.system(size: 11))
                .foregroundColor(color)
                .frame(width: 26, height: 26)
                .background(color.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 6))

            Text(value)
                .font(.system(size: 12, weight: .bold, design: .monospaced))
                .foregroundColor(ExTokens.Colors.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.7)

            Text(label)
                .font(.system(size: 7, weight: .bold))
                .foregroundColor(ExTokens.Colors.textMuted)
                .tracking(0.5)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(ExTokens.Colors.backgroundCard)
        .clipShape(RoundedRectangle(cornerRadius: ExTokens.Radius.md))
        .overlay(
            RoundedRectangle(cornerRadius: ExTokens.Radius.md)
                .stroke(
                    isHovered ? color.opacity(0.4) : ExTokens.Colors.borderDefault,
                    lineWidth: 1
                )
        )
        .overlay(alignment: .top) {
            // Subtle colored top line
            LinearGradient(
                colors: [.clear, color.opacity(isHovered ? 0.5 : 0.2), .clear],
                startPoint: .leading,
                endPoint: .trailing
            )
            .frame(height: 1)
        }
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.15)) {
                isHovered = hovering
            }
        }
    }
}
