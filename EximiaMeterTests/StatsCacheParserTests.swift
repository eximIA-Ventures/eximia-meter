import XCTest
@testable import EximiaMeter

final class StatsCacheParserTests: XCTestCase {
    func testParseValidJSON() throws {
        let json = """
        {
            "version": 1,
            "lastComputedDate": "2026-02-13",
            "dailyActivity": [
                {"date": "2026-02-13", "messageCount": 100, "sessionCount": 5, "toolCallCount": 50}
            ],
            "dailyModelTokens": [
                {"date": "2026-02-13", "tokensByModel": {"claude-opus-4-6": 1000000}}
            ],
            "modelUsage": {
                "claude-opus-4-6": {
                    "inputTokens": 500000,
                    "outputTokens": 500000,
                    "cacheReadInputTokens": 100000,
                    "cacheCreationInputTokens": 50000
                }
            },
            "totalSessions": 163,
            "totalMessages": 74105,
            "firstSessionDate": "2026-01-01",
            "hourCounts": {"16": 19, "17": 28}
        }
        """

        let data = json.data(using: .utf8)!
        let stats = try JSONDecoder().decode(StatsCache.self, from: data)

        XCTAssertEqual(stats.version, 1)
        XCTAssertEqual(stats.totalSessions, 163)
        XCTAssertEqual(stats.totalMessages, 74105)
        XCTAssertEqual(stats.dailyActivity?.count, 1)
        XCTAssertEqual(stats.dailyActivity?.first?.messageCount, 100)
        XCTAssertEqual(stats.dailyModelTokens?.count, 1)
        XCTAssertEqual(stats.modelUsage?["claude-opus-4-6"]?.inputTokens, 500000)
        XCTAssertEqual(stats.hourCounts?["16"], 19)
    }

    func testParsePartialJSON() throws {
        let json = """
        {
            "totalSessions": 10,
            "totalMessages": 100
        }
        """

        let data = json.data(using: .utf8)!
        let stats = try JSONDecoder().decode(StatsCache.self, from: data)

        XCTAssertNil(stats.version)
        XCTAssertEqual(stats.totalSessions, 10)
        XCTAssertNil(stats.dailyActivity)
    }

    func testModelUsageTotalTokens() throws {
        let usage = ModelUsage(
            inputTokens: 300000,
            outputTokens: 200000,
            cacheReadInputTokens: 100000,
            cacheCreationInputTokens: 50000
        )

        XCTAssertEqual(usage.totalTokens, 650000)
    }
}
