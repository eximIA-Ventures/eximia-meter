import Foundation

enum OptimizationLevel: String, Codable, CaseIterable, Identifiable {
    case low, med, high

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .low: return "Low"
        case .med: return "Med"
        case .high: return "High"
        }
    }
}
