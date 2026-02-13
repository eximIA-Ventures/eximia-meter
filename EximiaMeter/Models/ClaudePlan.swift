import Foundation

enum ClaudePlan: String, Codable, CaseIterable, Identifiable {
    case pro = "pro"
    case max5x = "max5x"
    case max20x = "max20x"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .pro:    return "Pro"
        case .max5x:  return "Max 5x"
        case .max20x: return "Max 20x"
        }
    }

    var description: String {
        switch self {
        case .pro:    return "Standard rate limits"
        case .max5x:  return "5x higher rate limits"
        case .max20x: return "20x higher rate limits"
        }
    }

    /// Estimated weekly token limit (including cache tokens).
    /// These are calibrated estimates based on observed Claude Code usage patterns.
    var weeklyTokenLimit: Int {
        switch self {
        case .pro:    return 100_000_000      // ~100M
        case .max5x:  return 500_000_000      // ~500M
        case .max20x: return 2_000_000_000    // ~2B
        }
    }

    /// Estimated session token limit (including cache tokens).
    var sessionTokenLimit: Int {
        switch self {
        case .pro:    return 10_000_000       // ~10M
        case .max5x:  return 50_000_000       // ~50M
        case .max20x: return 200_000_000      // ~200M
        }
    }
}
