import SwiftUI

enum ExButtonVariant {
    case primary
    case secondary
    case outline
    case ghost
    case destructive
    case accent
    case modelColor(Color) // Dynamic color matching the selected model
}

enum ExButtonSize {
    case sm, md, lg

    var height: CGFloat {
        switch self {
        case .sm: return 28
        case .md: return 34
        case .lg: return 40
        }
    }

    var horizontalPadding: CGFloat {
        switch self {
        case .sm: return 12
        case .md: return 16
        case .lg: return 24
        }
    }

    var fontSize: CGFloat {
        switch self {
        case .sm: return 9
        case .md: return 10
        case .lg: return 11
        }
    }
}

struct ExButton: View {
    let title: String
    var variant: ExButtonVariant = .primary
    var size: ExButtonSize = .md
    var icon: String? = nil
    var fullWidth: Bool = false
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                if let icon {
                    Image(systemName: icon)
                        .font(.system(size: size.fontSize))
                }
                Text(title)
                    .font(.system(size: size.fontSize, weight: .bold))
                    .tracking(1.2)
                    .textCase(.uppercase)
            }
            .frame(height: size.height)
            .frame(maxWidth: fullWidth ? .infinity : nil)
            .padding(.horizontal, size.horizontalPadding)
            .foregroundColor(foregroundColor)
            .background(backgroundColor)
            .overlay(
                RoundedRectangle(cornerRadius: ExTokens.Radius.md)
                    .stroke(borderColor, lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: ExTokens.Radius.md))
            .shadow(color: shadowColor, radius: shadowRadius)
        }
        .buttonStyle(.plain)
    }

    private var foregroundColor: Color {
        switch variant {
        case .primary: return .black
        case .secondary: return ExTokens.Colors.textSecondary
        case .outline: return ExTokens.Colors.textTertiary
        case .ghost: return ExTokens.Colors.textTertiary
        case .destructive: return ExTokens.Colors.destructive
        case .accent: return .black
        case .modelColor: return .white
        }
    }

    private var backgroundColor: Color {
        switch variant {
        case .primary: return .white
        case .secondary: return ExTokens.Colors.backgroundCard
        case .outline: return .clear
        case .ghost: return .clear
        case .destructive: return ExTokens.Colors.destructiveBg
        case .accent: return ExTokens.Colors.accentPrimary
        case .modelColor(let color): return color
        }
    }

    private var borderColor: Color {
        switch variant {
        case .primary: return .clear
        case .secondary: return ExTokens.Colors.borderDefault
        case .outline: return ExTokens.Zinc._700
        case .ghost: return .clear
        case .destructive: return Color(hex: "#881337").opacity(0.5)
        case .accent, .modelColor: return .clear
        }
    }

    private var shadowColor: Color {
        switch variant {
        case .primary: return .white.opacity(0.15)
        case .accent: return ExTokens.Colors.accentPrimary.opacity(0.25)
        case .modelColor(let color): return color.opacity(0.3)
        default: return .clear
        }
    }

    private var shadowRadius: CGFloat {
        switch variant {
        case .primary, .accent, .modelColor: return 10
        default: return 0
        }
    }
}
