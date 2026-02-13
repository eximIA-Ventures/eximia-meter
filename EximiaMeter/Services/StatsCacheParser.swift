import Foundation

struct StatsCacheParser {
    static func parse(from url: URL) throws -> StatsCache {
        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()
        return try decoder.decode(StatsCache.self, from: data)
    }

    static func parse(from path: String) throws -> StatsCache {
        let expandedPath = NSString(string: path).expandingTildeInPath
        let url = URL(fileURLWithPath: expandedPath)
        return try parse(from: url)
    }
}
