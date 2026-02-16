import Foundation

struct CalibrationStore {
    struct Snapshot: Codable {
        let timestamp: Date
        let apiWeeklyPercent: Double
        let apiSessionPercent: Double
        let apiWeeklyResetsAt: Date?
        let apiSessionResetsAt: Date?
        let localWeeklyTokens: Int
        let localSessionTokens: Int
    }

    private static let key = "calibrationSnapshots"
    private static let maxSnapshots = 20
    private static let maxAge: TimeInterval = 8 * 3600 // 8 hours

    // MARK: - Save

    static func save(_ snapshot: Snapshot) {
        // Guards: ignore useless data points
        guard snapshot.apiWeeklyPercent >= 1.0,
              snapshot.localWeeklyTokens > 0 else { return }

        var snapshots = load()
        snapshots.append(snapshot)

        // Keep rolling window
        if snapshots.count > maxSnapshots {
            snapshots = Array(snapshots.suffix(maxSnapshots))
        }

        if let data = try? JSONEncoder().encode(snapshots) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }

    // MARK: - Load

    private static func load() -> [Snapshot] {
        guard let data = UserDefaults.standard.data(forKey: key),
              let snapshots = try? JSONDecoder().decode([Snapshot].self, from: data) else {
            return []
        }
        return snapshots
    }

    private static func freshSnapshots() -> [Snapshot] {
        let cutoff = Date().addingTimeInterval(-maxAge)
        return load().filter { $0.timestamp > cutoff }
    }

    // MARK: - Effective Limits

    static func effectiveWeeklyLimit(fallback: Int) -> Int? {
        computeEffectiveLimit(
            snapshots: freshSnapshots(),
            percentKeyPath: \.apiWeeklyPercent,
            tokensKeyPath: \.localWeeklyTokens,
            fallback: fallback
        )
    }

    static func effectiveSessionLimit(fallback: Int) -> Int? {
        let snaps = freshSnapshots().filter { $0.localSessionTokens > 0 && $0.apiSessionPercent >= 1.0 }
        return computeEffectiveLimit(
            snapshots: snaps,
            percentKeyPath: \.apiSessionPercent,
            tokensKeyPath: \.localSessionTokens,
            fallback: fallback
        )
    }

    // MARK: - Core Calculation

    private static func computeEffectiveLimit(
        snapshots: [Snapshot],
        percentKeyPath: KeyPath<Snapshot, Double>,
        tokensKeyPath: KeyPath<Snapshot, Int>,
        fallback: Int
    ) -> Int? {
        guard !snapshots.isEmpty else { return nil }

        // Weighted average: more recent snapshots weigh more
        var weightedSum: Double = 0
        var totalWeight: Double = 0
        let now = Date()

        for snap in snapshots {
            let age = now.timeIntervalSince(snap.timestamp)
            let weight = max(1.0 - (age / maxAge), 0.1) // linear decay, min 0.1
            let pct = snap[keyPath: percentKeyPath] / 100.0
            guard pct > 0 else { continue }
            let impliedLimit = Double(snap[keyPath: tokensKeyPath]) / pct
            weightedSum += impliedLimit * weight
            totalWeight += weight
        }

        guard totalWeight > 0 else { return nil }
        let effectiveLimit = Int(weightedSum / totalWeight)

        // Sanity bounds: 50%-500% of fallback
        let low = fallback / 2
        let high = fallback * 5
        guard effectiveLimit >= low, effectiveLimit <= high else { return nil }

        return effectiveLimit
    }
}
