import Foundation

// Codable models for ~/.claude/stats-cache.json

struct StatsCache: Codable {
    let version: Int?
    let lastComputedDate: String?
    let dailyActivity: [DailyActivity]?
    let dailyModelTokens: [DailyModelTokens]?
    let modelUsage: [String: ModelUsage]?
    let totalSessions: Int?
    let totalMessages: Int?
    let longestSession: LongestSession?
    let firstSessionDate: String?
    let hourCounts: [String: Int]?
}

struct DailyActivity: Codable {
    let date: String
    let messageCount: Int?
    let sessionCount: Int?
    let toolCallCount: Int?
}

struct DailyModelTokens: Codable {
    let date: String
    let tokensByModel: [String: Int]?
}

struct ModelUsage: Codable {
    let inputTokens: Int?
    let outputTokens: Int?
    let cacheReadInputTokens: Int?
    let cacheCreationInputTokens: Int?

    var totalTokens: Int {
        (inputTokens ?? 0) + (outputTokens ?? 0) + (cacheReadInputTokens ?? 0) + (cacheCreationInputTokens ?? 0)
    }
}

struct LongestSession: Codable {
    let sessionId: String?
    let messageCount: Int?
    let duration: Int?
}
