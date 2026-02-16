import Foundation

/// Calculates active work time by analyzing message timestamps in session JSONL files.
/// Uses the Active Window Detection model: only counts time between Claude's response
/// and the user's next message (reading/thinking/coding time), with a gap threshold
/// to detect breaks.
final class WorkTimeService {
    static let shared = WorkTimeService()

    private let projectsDir = NSString(string: "~/.claude/projects").expandingTildeInPath

    // Cache: filePath → (modDate, workSeconds) — immutable for closed sessions
    private var fileCache: [String: (modDate: Date, seconds: TimeInterval)] = [:]

    // Daily aggregated cache: "YYYY-MM-DD" → total seconds
    private var dailyCache: [String: TimeInterval] = [:]

    // Constants
    private let gapThreshold: TimeInterval = 20 * 60   // 20 min — beyond this is a break
    private let bufferAfter: TimeInterval = 5 * 60      // 5 min — reading time after last response
    private let minWorkSegment: TimeInterval = 10        // 10 sec — ignore trivial gaps

    private let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        f.timeZone = .current
        return f
    }()

    private init() {}

    // MARK: - Public API

    /// Total active work seconds for today
    func workSecondsToday() -> TimeInterval {
        let today = dateFormatter.string(from: Date())
        let startOfDay = Calendar.current.startOfDay(for: Date())
        return workSeconds(since: startOfDay, dateKey: today, allowCached: false)
    }

    /// Total active work seconds for the current week (last 7 days)
    func workSecondsThisWeek() -> TimeInterval {
        let cal = Calendar.current
        var total: TimeInterval = 0

        for daysAgo in 0..<7 {
            let date = cal.date(byAdding: .day, value: -daysAgo, to: Date())!
            let key = dateFormatter.string(from: date)
            let startOfDay = cal.startOfDay(for: date)

            if daysAgo == 0 {
                // Today: always recalculate (active session)
                total += workSeconds(since: startOfDay, dateKey: key, allowCached: false)
            } else if let cached = dailyCache[key] {
                // Past days: use cached value
                total += cached
            } else {
                // Past days not cached: calculate and cache
                let seconds = workSeconds(since: startOfDay, dateKey: key, allowCached: true)
                dailyCache[key] = seconds
                total += seconds
            }
        }

        return total
    }

    /// Formatted string "Xh YYmin"
    static func format(_ seconds: TimeInterval) -> String {
        guard seconds >= 60 else { return "0min" }
        let hours = Int(seconds) / 3600
        let mins = (Int(seconds) % 3600) / 60
        if hours > 0 {
            return "\(hours)h \(String(format: "%02d", mins))min"
        }
        return "\(mins)min"
    }

    /// Compact format for menu bar "Xh YYm"
    static func formatCompact(_ seconds: TimeInterval) -> String {
        guard seconds >= 60 else { return "0m" }
        let hours = Int(seconds) / 3600
        let mins = (Int(seconds) % 3600) / 60
        if hours > 0 {
            return "\(hours)h\(String(format: "%02d", mins))m"
        }
        return "\(mins)m"
    }

    /// Prune cache entries older than 8 days
    func pruneCache() {
        let cutoff = dateFormatter.string(from: Date().addingTimeInterval(-8 * 86400))
        dailyCache = dailyCache.filter { $0.key >= cutoff }
    }

    // MARK: - Core Calculation

    /// Calculate work seconds from all session files that have activity since `since`
    private func workSeconds(since: Date, dateKey: String, allowCached: Bool) -> TimeInterval {
        let fm = FileManager.default
        guard let dirs = try? fm.contentsOfDirectory(atPath: projectsDir) else { return 0 }

        var total: TimeInterval = 0

        for dirName in dirs {
            let dirPath = "\(projectsDir)/\(dirName)"
            var isDir: ObjCBool = false
            guard fm.fileExists(atPath: dirPath, isDirectory: &isDir), isDir.boolValue else { continue }

            guard let files = try? fm.contentsOfDirectory(atPath: dirPath) else { continue }
            for fileName in files where fileName.hasSuffix(".jsonl") {
                let filePath = "\(dirPath)/\(fileName)"

                // Check file modification date — skip if older than our window
                guard let attrs = try? fm.attributesOfItem(atPath: filePath),
                      let modDate = attrs[.modificationDate] as? Date else { continue }

                // Skip files not modified since our target date (with 1h buffer for timezone)
                guard modDate > since.addingTimeInterval(-3600) else { continue }

                // Use cache for unchanged files
                if allowCached, let cached = fileCache[filePath], cached.modDate == modDate {
                    total += cached.seconds
                    continue
                }

                // Parse timestamps and calculate work time
                let seconds = calculateWorkTime(filePath: filePath, since: since)
                fileCache[filePath] = (modDate: modDate, seconds: seconds)
                total += seconds
            }
        }

        return total
    }

    /// Parse a session JSONL file and calculate active work time using the gap model
    private func calculateWorkTime(filePath: String, since: Date) -> TimeInterval {
        guard let data = FileManager.default.contents(atPath: filePath),
              let content = String(data: data, encoding: .utf8) else { return 0 }

        // Extract all timestamps with their type (user/assistant)
        var events: [(date: Date, isAssistant: Bool)] = []
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        for line in content.split(separator: "\n", omittingEmptySubsequences: true) {
            guard line.contains("\"timestamp\"") else { continue }

            let typeStr: String?
            let timestampStr: String?

            // Quick extraction without full JSON parse for performance
            if let typeRange = line.range(of: "\"type\":\""),
               let typeEnd = line[typeRange.upperBound...].range(of: "\"") {
                typeStr = String(line[typeRange.upperBound..<typeEnd.lowerBound])
            } else if let typeRange = line.range(of: "\"type\": \""),
                      let typeEnd = line[typeRange.upperBound...].range(of: "\"") {
                typeStr = String(line[typeRange.upperBound..<typeEnd.lowerBound])
            } else {
                continue
            }

            guard typeStr == "user" || typeStr == "assistant" else { continue }

            if let tsRange = line.range(of: "\"timestamp\":\""),
               let tsEnd = line[tsRange.upperBound...].range(of: "\"") {
                timestampStr = String(line[tsRange.upperBound..<tsEnd.lowerBound])
            } else if let tsRange = line.range(of: "\"timestamp\": \""),
                      let tsEnd = line[tsRange.upperBound...].range(of: "\"") {
                timestampStr = String(line[tsRange.upperBound..<tsEnd.lowerBound])
            } else {
                continue
            }

            guard let ts = timestampStr, let date = isoFormatter.date(from: ts) else { continue }
            guard date >= since else { continue }

            events.append((date: date, isAssistant: typeStr == "assistant"))
        }

        // Sort by time
        events.sort { $0.date < $1.date }
        guard events.count >= 2 else { return 0 }

        // Apply Active Window Detection model
        var totalWork: TimeInterval = 0

        for i in 0..<(events.count - 1) {
            let current = events[i]
            let next = events[i + 1]

            // Only count: assistant response → next user message = work time
            if current.isAssistant && !next.isAssistant {
                let gap = next.date.timeIntervalSince(current.date)

                if gap < minWorkSegment {
                    continue // Too short, skip
                } else if gap <= gapThreshold {
                    totalWork += gap // Active work
                } else {
                    totalWork += bufferAfter // Long gap = break, count buffer only
                }
            }
        }

        // Buffer after last assistant message
        if let last = events.last, last.isAssistant {
            totalWork += bufferAfter
        }

        return totalWork
    }
}
