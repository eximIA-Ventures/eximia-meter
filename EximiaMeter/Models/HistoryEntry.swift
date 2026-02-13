import Foundation

// Codable model for ~/.claude/history.jsonl entries

struct HistoryEntry: Codable {
    let sessionId: String?
    let timestamp: Int64?
    let project: String?
    let display: String?
    let model: String?
    let messageCount: Int?
    let duration: Int?

    // Legacy field names
    let projectPath: String?

    var effectiveProject: String? {
        project ?? projectPath
    }

    var date: Date? {
        guard let timestamp else { return nil }
        return Date(timeIntervalSince1970: Double(timestamp) / 1000.0)
    }

    private enum CodingKeys: String, CodingKey {
        case sessionId, timestamp, project, display, model, messageCount, duration, projectPath
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        sessionId = try container.decodeIfPresent(String.self, forKey: .sessionId)
        display = try container.decodeIfPresent(String.self, forKey: .display)
        project = try container.decodeIfPresent(String.self, forKey: .project)
        model = try container.decodeIfPresent(String.self, forKey: .model)
        messageCount = try container.decodeIfPresent(Int.self, forKey: .messageCount)
        duration = try container.decodeIfPresent(Int.self, forKey: .duration)
        projectPath = try container.decodeIfPresent(String.self, forKey: .projectPath)

        // timestamp can be Int64 or String
        if let ts = try? container.decodeIfPresent(Int64.self, forKey: .timestamp) {
            timestamp = ts
        } else if let tsStr = try? container.decodeIfPresent(String.self, forKey: .timestamp) {
            timestamp = Int64(tsStr)
        } else {
            timestamp = nil
        }
    }
}
