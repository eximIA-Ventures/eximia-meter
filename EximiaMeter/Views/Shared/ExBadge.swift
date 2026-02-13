import SwiftUI

enum ExBadgeVariant {
    case `default`
    case primary
    case success
    case warning
    case outline
    case opus
    case sonnet
    case haiku
}

struct ExBadge: View {
    let text: String
    var variant: ExBadgeVariant = .default

    var body: some View {
        Text(text)
            .font(.system(size: 9, weight: .bold))
            .tracking(1.5)
            .textCase(.uppercase)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .foregroundColor(foregroundColor)
            .background(backgroundColor)
            .overlay(
                RoundedRectangle(cornerRadius: ExTokens.Radius.sm)
                    .stroke(borderColor, lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: ExTokens.Radius.sm))
    }

    private var foregroundColor: Color {
        switch variant {
        case .default: return ExTokens.Colors.textSecondary
        case .primary: return ExTokens.Colors.accentPrimary
        case .success: return ExTokens.Colors.statusSuccess
        case .warning: return Color(hex: "#F97316")
        case .outline: return ExTokens.Colors.textTertiary
        case .opus: return Color(hex: "#A855F7")
        case .sonnet: return Color(hex: "#3B82F6")
        case .haiku: return ExTokens.Colors.statusSuccess
        }
    }

    private var backgroundColor: Color {
        switch variant {
        case .default: return ExTokens.Zinc._900
        case .primary: return ExTokens.Colors.accentPrimary.opacity(0.1)
        case .success: return ExTokens.Colors.statusSuccess.opacity(0.1)
        case .warning: return Color(hex: "#F97316").opacity(0.1)
        case .outline: return .clear
        case .opus: return Color(hex: "#A855F7").opacity(0.1)
        case .sonnet: return Color(hex: "#3B82F6").opacity(0.1)
        case .haiku: return ExTokens.Colors.statusSuccess.opacity(0.1)
        }
    }

    private var borderColor: Color {
        switch variant {
        case .default: return ExTokens.Colors.borderDefault
        case .primary: return ExTokens.Colors.accentPrimary.opacity(0.2)
        case .success: return ExTokens.Colors.statusSuccess.opacity(0.2)
        case .warning: return Color(hex: "#F97316").opacity(0.2)
        case .outline: return ExTokens.Zinc._700
        case .opus: return Color(hex: "#A855F7").opacity(0.2)
        case .sonnet: return Color(hex: "#3B82F6").opacity(0.2)
        case .haiku: return ExTokens.Colors.statusSuccess.opacity(0.2)
        }
    }
}
