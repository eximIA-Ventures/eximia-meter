import XCTest
@testable import EximiaMeter

final class UsageCalculatorTests: XCTestCase {
    func testCalculateWithNilStats() {
        let data = UsageCalculatorService.calculate(from: nil)

        XCTAssertEqual(data.weeklyUsage, 0.0)
        XCTAssertEqual(data.sessionUsage, 0.0)
        XCTAssertEqual(data.totalSessions, 0)
    }

    func testCalculateWithStats() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let today = dateFormatter.string(from: Date())

        let stats = StatsCache(
            version: 1,
            lastComputedDate: today,
            dailyActivity: [
                DailyActivity(date: today, messageCount: 50, sessionCount: 3, toolCallCount: 25)
            ],
            dailyModelTokens: [
                DailyModelTokens(date: today, tokensByModel: ["claude-opus-4-6": 4_500_000])
            ],
            modelUsage: [
                "claude-opus-4-6": ModelUsage(
                    inputTokens: 2_000_000,
                    outputTokens: 2_500_000,
                    cacheReadInputTokens: 500_000,
                    cacheCreationInputTokens: 200_000
                )
            ],
            totalSessions: 10,
            totalMessages: 500,
            longestSession: nil,
            firstSessionDate: "2026-01-01",
            hourCounts: ["14": 5]
        )

        let data = UsageCalculatorService.calculate(from: stats)

        XCTAssertEqual(data.totalSessions, 10)
        XCTAssertEqual(data.totalMessages, 500)
        XCTAssertGreaterThan(data.weeklyUsage, 0)
        XCTAssertGreaterThan(data.totalTokensThisWeek, 0)
    }

    func testUsageDataFormatting() {
        var data = UsageData()
        data.weeklyResetTimeRemaining = 86400 + 3600 * 8  // 1d 8h
        data.sessionResetTimeRemaining = 21 * 60           // 21m

        XCTAssertEqual(data.weeklyResetFormatted, "1d 8h")
        XCTAssertEqual(data.sessionResetFormatted, "21m")
    }

    func testUsageDataFormattingZero() {
        var data = UsageData()
        data.weeklyResetTimeRemaining = 0

        XCTAssertEqual(data.weeklyResetFormatted, "now")
    }
}
