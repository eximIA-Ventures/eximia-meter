import Foundation

struct UsageCalculatorService {
    struct Limits {
        var weeklyTokenLimit: Int = 2_000_000_000
        var dailyTokenLimit: Int = 300_000_000
        var sessionTokenLimit: Int = 200_000_000
        var weeklyResetDay: Int = 1
    }

    static func calculate(from stats: StatsCache?, limits: Limits = Limits(), historyEntries: [HistoryEntry] = []) -> UsageData {
        guard let stats else { return UsageData() }

        var data = UsageData()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.timeZone = TimeZone.current

        // Calculate cache multiplier from modelUsage (cumulative data)
        let multiplier = cacheMultiplier(from: stats)

        // Total stats
        data.totalSessions = stats.totalSessions ?? 0
        data.totalMessages = stats.totalMessages ?? 0
        data.dailyActivity = stats.dailyActivity ?? []
        data.dailyModelTokens = stats.dailyModelTokens ?? []
        data.hourCounts = stats.hourCounts ?? [:]

        // Weekly usage — apply cache multiplier to get real token count
        let rawWeeklyTokens = rawTokensByPeriod(from: stats, days: 7, formatter: dateFormatter)
        let weeklyTokens = Int(Double(rawWeeklyTokens) * multiplier)
        data.totalTokensThisWeek = weeklyTokens
        data.weeklyUsage = limits.weeklyTokenLimit > 0
            ? min(Double(weeklyTokens) / Double(limits.weeklyTokenLimit), 1.0)
            : 0.0

        // Daily usage
        let rawTodayTokens = rawTokensByPeriod(from: stats, days: 1, formatter: dateFormatter)
        let todayTokens = Int(Double(rawTodayTokens) * multiplier)
        data.totalTokensToday = todayTokens
        data.dailyUsage = limits.dailyTokenLimit > 0
            ? min(Double(todayTokens) / Double(limits.dailyTokenLimit), 1.0)
            : 0.0

        // Session usage — estimate from current session's message proportion
        let sessionEstimate = estimateSessionTokens(todayTokens: todayTokens, historyEntries: historyEntries)
        data.totalTokensThisSession = sessionEstimate.tokens
        data.sessionUsage = limits.sessionTokenLimit > 0
            ? min(Double(sessionEstimate.tokens) / Double(limits.sessionTokenLimit), 1.0)
            : 0.0

        // Per-model usage (last 7 days) — proportions don't need multiplier
        data.perModelUsage = calculatePerModelUsage(from: stats, formatter: dateFormatter)

        // Per-period breakdowns (with cache multiplier)
        data.tokens24h = todayTokens
        data.tokens7d = weeklyTokens
        data.tokens30d = Int(Double(rawTokensByPeriod(from: stats, days: 30, formatter: dateFormatter)) * multiplier)
        data.tokensAllTime = totalTokens(from: stats)

        data.messages24h = messagesByPeriod(from: stats, days: 1, formatter: dateFormatter)
        data.messages7d = messagesByPeriod(from: stats, days: 7, formatter: dateFormatter)
        data.messages30d = messagesByPeriod(from: stats, days: 30, formatter: dateFormatter)
        data.messagesAllTime = stats.totalMessages ?? 0

        data.sessions24h = sessionsByPeriod(from: stats, days: 1, formatter: dateFormatter)
        data.sessions7d = sessionsByPeriod(from: stats, days: 7, formatter: dateFormatter)
        data.sessions30d = sessionsByPeriod(from: stats, days: 30, formatter: dateFormatter)
        data.sessionsAllTime = stats.totalSessions ?? 0

        // Reset timers
        data.weeklyResetTimeRemaining = calculateWeeklyReset(resetDay: limits.weeklyResetDay)
        data.sessionResetTimeRemaining = calculateSessionReset(sessionStart: sessionEstimate.startTime)

        data.lastUpdated = Date()

        return data
    }

    // MARK: - Session Estimation

    struct SessionEstimate {
        let tokens: Int
        let startTime: Date?
    }

    /// Estimates current session tokens by looking at history.jsonl entries.
    /// Uses the proportion of current session messages vs today's total messages.
    static func estimateSessionTokens(todayTokens: Int, historyEntries: [HistoryEntry]) -> SessionEstimate {
        guard !historyEntries.isEmpty else {
            return SessionEstimate(tokens: todayTokens, startTime: nil)
        }

        // Find the latest sessionId
        guard let lastEntry = historyEntries.last,
              let currentSessionId = lastEntry.sessionId else {
            return SessionEstimate(tokens: todayTokens, startTime: nil)
        }

        let startOfToday = Calendar.current.startOfDay(for: Date())

        // Count today's history entries
        let todayEntries = historyEntries.filter { entry in
            guard let ts = entry.timestamp else { return false }
            let date = Date(timeIntervalSince1970: Double(ts) / 1000.0)
            return date >= startOfToday
        }

        // Count current session's entries
        let sessionEntries = historyEntries.filter { $0.sessionId == currentSessionId }

        let todayCount = max(todayEntries.count, 1)
        let sessionCount = sessionEntries.count

        // Find session start time
        let sessionStart: Date? = sessionEntries.first.flatMap { entry in
            guard let ts = entry.timestamp else { return nil }
            return Date(timeIntervalSince1970: Double(ts) / 1000.0)
        }

        // Estimate: session tokens = today's tokens × (session messages / today's messages)
        let ratio = min(Double(sessionCount) / Double(todayCount), 1.0)
        let sessionTokens = Int(Double(todayTokens) * ratio)

        return SessionEstimate(tokens: sessionTokens, startTime: sessionStart)
    }

    // MARK: - Cache Multiplier

    /// Calculates a multiplier to estimate real token usage from dailyModelTokens.
    ///
    /// `dailyModelTokens` only records input+output tokens, but real usage includes
    /// cacheReadInputTokens and cacheCreationInputTokens which are typically 99%+ of actual usage.
    /// We derive the multiplier from `modelUsage` which has the full breakdown.
    static func cacheMultiplier(from stats: StatsCache) -> Double {
        guard let modelUsage = stats.modelUsage, !modelUsage.isEmpty else { return 1.0 }

        var totalAllTokens: Double = 0
        var totalIOTokens: Double = 0

        for (_, usage) in modelUsage {
            let io = Double((usage.inputTokens ?? 0) + (usage.outputTokens ?? 0))
            let all = Double(usage.totalTokens)
            totalIOTokens += io
            totalAllTokens += all
        }

        guard totalIOTokens > 0 else { return 1.0 }

        let multiplier = totalAllTokens / totalIOTokens
        // Sanity check: multiplier should be >= 1.0 and not absurdly high
        return min(max(multiplier, 1.0), 10000.0)
    }

    // MARK: - Raw token calculations (without multiplier)

    /// Calculate raw input+output tokens for a given period from dailyModelTokens.
    static func rawTokensByPeriod(from stats: StatsCache, days: Int, formatter: DateFormatter) -> Int {
        guard let dailyTokens = stats.dailyModelTokens else { return 0 }

        let calendar = Calendar.current
        let startOfToday = calendar.startOfDay(for: Date())
        let cutoff = calendar.date(byAdding: .day, value: -days, to: startOfToday) ?? startOfToday

        return dailyTokens
            .filter { entry in
                guard let date = formatter.date(from: entry.date) else { return false }
                return date >= cutoff
            }
            .reduce(0) { total, entry in
                total + (entry.tokensByModel?.values.reduce(0, +) ?? 0)
            }
    }

    /// Kept for backward compatibility — now returns multiplied tokens.
    static func tokensByPeriod(from stats: StatsCache, days: Int, formatter: DateFormatter) -> Int {
        let raw = rawTokensByPeriod(from: stats, days: days, formatter: formatter)
        let multiplier = cacheMultiplier(from: stats)
        return Int(Double(raw) * multiplier)
    }

    private static func totalTokens(from stats: StatsCache) -> Int {
        // Use cumulative modelUsage for all-time (includes all token types)
        if let modelUsage = stats.modelUsage {
            return modelUsage.values.reduce(0) { $0 + $1.totalTokens }
        }
        // Fallback to daily sum (raw, no multiplier available)
        guard let dailyTokens = stats.dailyModelTokens else { return 0 }
        return dailyTokens.reduce(0) { total, entry in
            total + (entry.tokensByModel?.values.reduce(0, +) ?? 0)
        }
    }

    private static func messagesByPeriod(from stats: StatsCache, days: Int, formatter: DateFormatter) -> Int {
        guard let activity = stats.dailyActivity else { return 0 }
        let calendar = Calendar.current
        let cutoff = calendar.startOfDay(for: calendar.date(byAdding: .day, value: -days, to: Date()) ?? Date())

        return activity
            .filter { formatter.date(from: $0.date).map { $0 >= cutoff } ?? false }
            .reduce(0) { $0 + ($1.messageCount ?? 0) }
    }

    private static func sessionsByPeriod(from stats: StatsCache, days: Int, formatter: DateFormatter) -> Int {
        guard let activity = stats.dailyActivity else { return 0 }
        let calendar = Calendar.current
        let cutoff = calendar.startOfDay(for: calendar.date(byAdding: .day, value: -days, to: Date()) ?? Date())

        return activity
            .filter { formatter.date(from: $0.date).map { $0 >= cutoff } ?? false }
            .reduce(0) { $0 + ($1.sessionCount ?? 0) }
    }

    private static func calculatePerModelUsage(from stats: StatsCache, formatter: DateFormatter) -> [String: Double] {
        guard let dailyTokens = stats.dailyModelTokens else { return [:] }

        let calendar = Calendar.current
        let weekAgo = calendar.startOfDay(for: calendar.date(byAdding: .day, value: -7, to: Date()) ?? Date())
        var modelTotals: [String: Int] = [:]

        for entry in dailyTokens {
            guard let date = formatter.date(from: entry.date), date >= weekAgo else { continue }
            guard let tokensByModel = entry.tokensByModel else { continue }

            for (model, tokens) in tokensByModel {
                modelTotals[model, default: 0] += tokens
            }
        }

        let total = modelTotals.values.reduce(0, +)
        guard total > 0 else { return [:] }

        return modelTotals.mapValues { Double($0) / Double(total) }
    }

    private static func calculateWeeklyReset(resetDay: Int) -> TimeInterval {
        let calendar = Calendar.current
        let now = Date()
        let currentWeekday = calendar.component(.weekday, from: now)

        var daysUntilReset = (resetDay - currentWeekday + 7) % 7
        if daysUntilReset == 0 { daysUntilReset = 7 }

        guard let resetDate = calendar.date(byAdding: .day, value: daysUntilReset, to: calendar.startOfDay(for: now)) else {
            return 0
        }

        return resetDate.timeIntervalSince(now)
    }

    private static func calculateSessionReset(sessionStart: Date? = nil) -> TimeInterval {
        let sessionDuration: TimeInterval = 5 * 3600 // ~5 hours session window
        guard let start = sessionStart else { return sessionDuration }
        let elapsed = Date().timeIntervalSince(start)
        return max(sessionDuration - elapsed, 0)
    }
}
