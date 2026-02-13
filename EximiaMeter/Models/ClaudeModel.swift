import SwiftUI

enum ClaudeModel: String, Codable, CaseIterable, Identifiable {
    case opus = "claude-opus-4-6"
    case sonnet = "claude-sonnet-4-5-20250929"
    case haiku = "claude-haiku-4-5-20251001"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .opus: return "Opus 4.6"
        case .sonnet: return "Sonnet 4.5"
        case .haiku: return "Haiku 4.5"
        }
    }

    var shortName: String {
        switch self {
        case .opus: return "Opus"
        case .sonnet: return "Sonnet"
        case .haiku: return "Haiku"
        }
    }

    var cliFlag: String {
        switch self {
        case .opus: return "--model opus"
        case .sonnet: return "--model sonnet"
        case .haiku: return "--model haiku"
        }
    }

    var badgeColor: Color {
        switch self {
        case .opus: return Color(hex: "#A855F7")
        case .sonnet: return Color(hex: "#3B82F6")
        case .haiku: return ExTokens.Colors.statusSuccess
        }
    }

    var badgeVariant: ExBadgeVariant {
        switch self {
        case .opus: return .opus
        case .sonnet: return .sonnet
        case .haiku: return .haiku
        }
    }
}
