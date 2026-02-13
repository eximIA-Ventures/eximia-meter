import Foundation

struct HistoryParser {
    static func parse(from url: URL) throws -> [HistoryEntry] {
        let content = try String(contentsOf: url, encoding: .utf8)
        let lines = content.components(separatedBy: .newlines).filter { !$0.isEmpty }
        let decoder = JSONDecoder()

        return lines.compactMap { line in
            guard let data = line.data(using: .utf8) else { return nil }
            return try? decoder.decode(HistoryEntry.self, from: data)
        }
    }

    static func parse(from path: String) throws -> [HistoryEntry] {
        let expandedPath = NSString(string: path).expandingTildeInPath
        let url = URL(fileURLWithPath: expandedPath)
        return try parse(from: url)
    }

    static func latestEntry(from path: String) -> HistoryEntry? {
        guard let entries = try? parse(from: path) else { return nil }
        return entries.last
    }
}
