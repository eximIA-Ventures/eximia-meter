import SwiftUI

struct AlertBannerData: Equatable {
    let type: String
    let severity: String
    let message: String

    var borderColor: Color {
        severity == "critical" ? ExTokens.Colors.statusCritical : ExTokens.Colors.statusWarning
    }

    var icon: String {
        severity == "critical" ? "exclamationmark.octagon.fill" : "exclamationmark.triangle.fill"
    }

    var backgroundColor: Color {
        severity == "critical"
            ? ExTokens.Colors.statusCritical.opacity(0.1)
            : ExTokens.Colors.statusWarning.opacity(0.1)
    }
}

struct AlertBannerView: View {
    let data: AlertBannerData
    let onDismiss: () -> Void

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: data.icon)
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(data.borderColor)

            Text(data.message)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(ExTokens.Colors.textPrimary)
                .lineLimit(1)

            Spacer()

            Button(action: onDismiss) {
                Image(systemName: "xmark")
                    .font(.system(size: 9, weight: .bold))
                    .foregroundColor(ExTokens.Colors.textMuted)
                    .frame(width: 20, height: 20)
                    .contentShape(Rectangle())
            }
            .buttonStyle(HoverableIconButtonStyle())
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(data.backgroundColor)
        .overlay(
            RoundedRectangle(cornerRadius: ExTokens.Radius.md)
                .stroke(data.borderColor.opacity(0.5), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: ExTokens.Radius.md))
        .padding(.horizontal, ExTokens.Spacing._12)
        .padding(.top, ExTokens.Spacing._8)
        .transition(.move(edge: .top).combined(with: .opacity))
    }
}
