import Foundation

/// Calculates per-project token usage by scanning ~/.claude/projects/ session files
struct ProjectUsageService {
    private static let projectsDir = NSString(string: "~/.claude/projects").expandingTildeInPath

    /// Returns a dictionary of project path -> total tokens (last 7 days estimated from session count)
    static func calculatePerProjectUsage(projects: [Project], statsCache: StatsCache?) -> [String: Int] {
        let fm = FileManager.default
        var result: [String: Int] = [:]

        for project in projects {
            let dirName = project.path.replacingOccurrences(of: "/", with: "-")
            let projectSessionDir = "\(projectsDir)/\(dirName)"

            guard fm.fileExists(atPath: projectSessionDir) else { continue }

            // Count session files as a proxy for usage
            let sessionCount = countRecentSessions(in: projectSessionDir)
            if sessionCount > 0 {
                // Estimate tokens based on proportion of sessions
                let totalSessions = statsCache?.totalSessions ?? 1
                let totalTokens = totalWeeklyTokens(from: statsCache)
                let estimatedTokens = totalSessions > 0
                    ? Int(Double(totalTokens) * Double(sessionCount) / Double(totalSessions))
                    : 0
                if estimatedTokens > 0 {
                    result[project.path] = estimatedTokens
                }
            }
        }

        return result
    }

    private static func countRecentSessions(in dir: String) -> Int {
        let fm = FileManager.default
        guard let files = try? fm.contentsOfDirectory(atPath: dir) else { return 0 }

        let sessionFiles = files.filter { $0.hasSuffix(".jsonl") }

        // Count files modified in last 7 days
        let weekAgo = Date().addingTimeInterval(-7 * 86400)
        var recentCount = 0

        for file in sessionFiles {
            let path = "\(dir)/\(file)"
            if let attrs = try? fm.attributesOfItem(atPath: path),
               let modDate = attrs[.modificationDate] as? Date,
               modDate >= weekAgo {
                recentCount += 1
            }
        }

        return recentCount
    }

    private static func totalWeeklyTokens(from stats: StatsCache?) -> Int {
        guard let stats else { return 0 }
        guard let dailyTokens = stats.dailyModelTokens else { return 0 }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let weekAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()

        let rawTokens = dailyTokens
            .filter { dateFormatter.date(from: $0.date).map { $0 >= weekAgo } ?? false }
            .reduce(0) { $0 + ($1.tokensByModel?.values.reduce(0, +) ?? 0) }

        // Apply cache multiplier for accurate token count
        let multiplier = UsageCalculatorService.cacheMultiplier(from: stats)
        return Int(Double(rawTokens) * multiplier)
    }
}
