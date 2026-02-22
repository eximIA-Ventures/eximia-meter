import Foundation

enum UsageSource {
    case api             // Layer 1: Anthropic OAuth API (authoritative)
    case calibratedLocal // Layer 2b: .jsonl tokens calibrated by saved API ratio
    case exactLocal      // Layer 2: .jsonl exact scan
    case estimated       // Layer 3: stats-cache × multiplier
}

struct UsageData {
    var weeklyUsage: Double = 0.0
    var dailyUsage: Double = 0.0
    var sessionUsage: Double = 0.0
    var perModelUsage: [String: Double] = [:]

    var weeklyResetTimeRemaining: TimeInterval = 0
    var sessionResetTimeRemaining: TimeInterval = 0

    var totalTokensThisWeek: Int = 0
    var totalTokensToday: Int = 0
    var totalTokensThisSession: Int = 0
    var totalSessions: Int = 0
    var totalMessages: Int = 0

    var usageSource: UsageSource = .estimated

    // Per-period stats
    var tokens24h: Int = 0
    var tokens7d: Int = 0
    var tokens30d: Int = 0
    var tokensAllTime: Int = 0
    var messages24h: Int = 0
    var messages7d: Int = 0
    var messages30d: Int = 0
    var messagesAllTime: Int = 0
    var sessions24h: Int = 0
    var sessions7d: Int = 0
    var sessions30d: Int = 0
    var sessionsAllTime: Int = 0

    // Per-project tokens (path -> tokens this week)
    var perProjectTokens: [String: Int] = [:]

    var dailyActivity: [DailyActivity] = []
    var dailyModelTokens: [DailyModelTokens] = []
    var hourCounts: [String: Int] = [:]

    // Work time (Active Window Detection from session JSONL files)
    var workSecondsToday: TimeInterval = 0
    var workSecondsThisWeek: TimeInterval = 0

    var formattedWorkToday: String {
        WorkTimeService.format(workSecondsToday)
    }

    var formattedWorkThisWeek: String {
        WorkTimeService.format(workSecondsThisWeek)
    }

    var formattedWorkTodayCompact: String {
        WorkTimeService.formatCompact(workSecondsToday)
    }

    var formattedWorkThisWeekCompact: String {
        WorkTimeService.formatCompact(workSecondsThisWeek)
    }

    var lastUpdated: Date = Date()

    var weeklyResetFormatted: String {
        formatTimeInterval(weeklyResetTimeRemaining)
    }

    var sessionResetFormatted: String {
        formatTimeInterval(sessionResetTimeRemaining)
    }

    // MARK: - Burn Rate / Projection

    /// Total week duration (7 days in seconds)
    private var totalWeekDuration: TimeInterval { 7 * 86400 }

    /// Time elapsed since the start of the current week (clamped to non-negative)
    var weeklyTimeElapsed: TimeInterval {
        max(0, totalWeekDuration - weeklyResetTimeRemaining)
    }

    /// Consumption rate per active hour (uses WorkTimeService active hours, not wall-clock)
    var burnRatePerHour: Double {
        guard workSecondsThisWeek > 3600 else { return 0 }
        return weeklyUsage / (workSecondsThisWeek / 3600)
    }

    /// Projected usage at weekly reset (linear extrapolation based on wall-clock elapsed time)
    var projectedUsageAtReset: Double {
        guard weeklyTimeElapsed > 3600 else { return weeklyUsage }
        let totalDuration = weeklyTimeElapsed + weeklyResetTimeRemaining
        return weeklyUsage * (totalDuration / weeklyTimeElapsed)
    }

    /// Formatted projection for the UI — always shows remaining % at reset
    var weeklyProjection: String {
        if weeklyUsage >= 1.0 {
            return "Limite atingido. Reseta em \(weeklyResetFormatted)"
        }
        if weeklyUsage == 0 || weeklyTimeElapsed <= 3600 {
            return ""
        }

        let projected = projectedUsageAtReset
        let freePercent = max(0, Int((1.0 - min(projected, 1.0)) * 100))

        if projected >= 1.0 {
            // Wall-clock time until 100%: weeklyTimeElapsed * (1 - weeklyUsage) / weeklyUsage
            let timeToLimit = weeklyTimeElapsed * (1.0 - weeklyUsage) / weeklyUsage
            return "Limite em ~\(formatTimeInterval(timeToLimit)) · 0% livre no reset"
        } else {
            return "No reset, sobrará \(freePercent)% para uso"
        }
    }

    /// True if projected to hit limit before weekly reset
    var projectionIsWarning: Bool {
        guard weeklyUsage > 0, weeklyUsage < 1.0 else { return weeklyUsage >= 1.0 }
        return projectedUsageAtReset >= 1.0
    }

    // MARK: - Cost Estimation

    /// The user's active Claude plan (set by UsageCalculatorService)
    var claudePlan: ClaudePlan = .max20x

    /// Equivalent API cost (USD) if tokens were paid per-token (not subscription)
    var equivalentAPICostUSD: Double {
        guard tokens7d > 0 else { return 0 }
        if perModelUsage.isEmpty {
            return Double(tokens7d) / 1_000_000.0 * ClaudeModel.sonnet.costPerMillionTokens
        }
        var cost: Double = 0
        for (modelId, pct) in perModelUsage {
            let model = ClaudeModel.resolve(modelId) ?? .sonnet
            let modelTokens = Double(tokens7d) * pct
            cost += (modelTokens / 1_000_000.0) * model.costPerMillionTokens
        }
        return cost
    }

    /// Real weekly cost based on subscription plan
    var estimatedWeeklyCostUSD: Double {
        claudePlan.weeklyCost
    }

    /// Savings compared to API pricing
    var weeklySavingsUSD: Double {
        max(0, equivalentAPICostUSD - claudePlan.weeklyCost)
    }

    var formattedWeeklyCost: String {
        let cost = claudePlan.weeklyCost
        if cost >= 100 {
            return String(format: "$%.0f", cost)
        }
        return String(format: "$%.2f", cost)
    }

    var formattedEquivalentAPICost: String {
        let cost = equivalentAPICostUSD
        if cost >= 10_000 {
            return String(format: "$%.1fK", cost / 1_000)
        } else if cost >= 1_000 {
            return String(format: "$%.1fK", cost / 1_000)
        } else if cost >= 100 {
            return String(format: "$%.0f", cost)
        } else if cost >= 1 {
            return String(format: "$%.2f", cost)
        } else if cost > 0 {
            return String(format: "$%.3f", cost)
        }
        return "$0"
    }

    var formattedSavings: String {
        let s = weeklySavingsUSD
        if s >= 1_000 {
            return String(format: "$%.1fK", s / 1_000)
        } else if s >= 100 {
            return String(format: "$%.0f", s)
        } else if s >= 1 {
            return String(format: "$%.2f", s)
        }
        return "$0"
    }

    // MARK: - Streak (consecutive active days)

    /// Number of consecutive days with activity (including today)
    var usageStreak: Int {
        guard !dailyActivity.isEmpty else { return 0 }
        let sorted = dailyActivity
            .compactMap { dateFromString($0.date) }
            .sorted(by: >)
        guard let latest = sorted.first else { return 0 }

        let cal = Calendar.current
        // Only count streak if latest activity is today or yesterday
        let daysSinceLatest = cal.dateComponents([.day], from: latest, to: Date()).day ?? 0
        guard daysSinceLatest <= 1 else { return 0 }

        var streak = 1
        for i in 1..<sorted.count {
            let diff = cal.dateComponents([.day], from: sorted[i], to: sorted[i - 1]).day ?? 0
            if diff == 1 {
                streak += 1
            } else {
                break
            }
        }
        return streak
    }

    // MARK: - Peak Detection

    /// Ratio of today's tokens vs previous 6-day daily average (excludes today to avoid bias)
    var todayVsAverageRatio: Double {
        guard tokens7d > 0, tokens24h > 0 else { return 0 }
        let previousDaysTokens = tokens7d - tokens24h
        guard previousDaysTokens > 0 else { return 0 }
        let dailyAvg = Double(previousDaysTokens) / 6.0
        return Double(tokens24h) / dailyAvg
    }

    var peakDetectionMessage: String? {
        if todayVsAverageRatio >= 3.0 {
            return "Hoje: \(String(format: "%.1fx", todayVsAverageRatio)) mais que a média diária!"
        } else if todayVsAverageRatio >= 2.0 {
            return "Hoje: \(String(format: "%.1fx", todayVsAverageRatio)) a média diária"
        }
        return nil
    }

    // MARK: - Model Suggestion

    /// Suggests cheaper model if dominant model is expensive
    var modelSuggestion: String? {
        guard !perModelUsage.isEmpty else { return nil }
        let sorted = perModelUsage.sorted { $0.value > $1.value }
        guard let dominant = sorted.first, dominant.value > 0.6 else { return nil }
        let model = ClaudeModel.resolve(dominant.key)
        if model == .opus {
            let savings = Int((1.0 - ClaudeModel.sonnet.costPerMillionTokens / ClaudeModel.opus.costPerMillionTokens) * 100)
            return "\(Int(dominant.value * 100))% Opus — Sonnet economizaria ~\(savings)%"
        }
        return nil
    }

    // MARK: - Week-over-Week Comparison

    /// Tokens from the previous 7-day window (days 8-14 ago) based on dailyModelTokens
    var tokensPreviousWeek: Int {
        let cal = Calendar.current
        let today = Date()
        var total = 0
        for entry in dailyModelTokens {
            guard let date = dateFromString(entry.date) else { continue }
            let daysAgo = cal.dateComponents([.day], from: date, to: today).day ?? 0
            if daysAgo >= 7 && daysAgo < 14 {
                total += entry.tokensByModel?.values.reduce(0, +) ?? 0
            }
        }
        return total
    }

    var weekOverWeekChange: String? {
        guard tokensPreviousWeek > 0, tokens7d > 0 else { return nil }
        let change = Double(tokens7d - tokensPreviousWeek) / Double(tokensPreviousWeek) * 100
        let sign = change >= 0 ? "+" : ""
        if abs(change) >= 1000 {
            return "\(sign)\(String(format: "%.1f", change / 1000))K%"
        }
        return "\(sign)\(Int(change))%"
    }

    var weekOverWeekIsUp: Bool {
        tokens7d > tokensPreviousWeek
    }

    // MARK: - Sparkline Data (last 7 days token counts)

    /// Returns array of (date label, token count) for the last 7 days
    var last7DaysTokens: [(String, Int)] {
        let cal = Calendar.current
        let today = cal.startOfDay(for: Date())
        var result: [(String, Int)] = []

        for daysAgo in (0..<7).reversed() {
            guard let targetDate = cal.date(byAdding: .day, value: -daysAgo, to: today) else { continue }
            let dateStr = dateToString(targetDate)
            let dayLabel = daysAgo == 0 ? "Hoje" : shortWeekday(targetDate)

            var dayTokens = 0
            if let entry = dailyModelTokens.first(where: { $0.date == dateStr }) {
                dayTokens = entry.tokensByModel?.values.reduce(0, +) ?? 0
            }
            result.append((dayLabel, dayTokens))
        }
        return result
    }

    // MARK: - Helpers

    private func dateFromString(_ s: String) -> Date? {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f.date(from: s)
    }

    private func dateToString(_ d: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f.string(from: d)
    }

    private func shortWeekday(_ d: Date) -> String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "pt_BR")
        f.dateFormat = "EEE"
        return f.string(from: d).prefix(3).capitalized
    }

    private func formatTimeInterval(_ interval: TimeInterval) -> String {
        guard interval > 0 else { return "now" }

        let days = Int(interval) / 86400
        let hours = (Int(interval) % 86400) / 3600
        let minutes = (Int(interval) % 3600) / 60

        if days > 0 {
            return "\(days)d \(hours)h"
        } else if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
}
