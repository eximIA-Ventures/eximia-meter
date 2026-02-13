import Foundation
import Combine

@Observable
class CLIMonitorService {
    private(set) var statsCache: StatsCache?
    private(set) var historyEntries: [HistoryEntry] = []
    private(set) var lastUpdate: Date = Date()

    private var fileDescriptor: Int32 = -1
    private var dispatchSource: DispatchSourceFileSystemObject?
    private var pollingTimer: Timer?

    private let claudeDir: String
    private let statsCachePath: String
    private let historyPath: String

    init(claudeDir: String = "~/.claude") {
        let expanded = NSString(string: claudeDir).expandingTildeInPath
        self.claudeDir = expanded
        self.statsCachePath = "\(expanded)/stats-cache.json"
        self.historyPath = "\(expanded)/history.jsonl"
    }

    func start() {
        loadData()
        startFileWatcher()
        startPolling()
    }

    func stop() {
        dispatchSource?.cancel()
        dispatchSource = nil
        if fileDescriptor >= 0 {
            close(fileDescriptor)
            fileDescriptor = -1
        }
        pollingTimer?.invalidate()
        pollingTimer = nil
    }

    func refresh() {
        loadData()
    }

    // MARK: - Data Loading

    private func loadData() {
        loadStatsCache()
        loadHistory()
        lastUpdate = Date()
    }

    private func loadStatsCache() {
        do {
            statsCache = try StatsCacheParser.parse(from: statsCachePath)
        } catch {
            // File may not exist yet — graceful degradation
        }
    }

    private func loadHistory() {
        do {
            historyEntries = try HistoryParser.parse(from: historyPath)
        } catch {
            // File may not exist yet
        }
    }

    // MARK: - File Watching (FSEvents via DispatchSource)

    private func startFileWatcher() {
        let path = statsCachePath

        fileDescriptor = open(path, O_EVTONLY)
        guard fileDescriptor >= 0 else { return }

        let source = DispatchSource.makeFileSystemObjectSource(
            fileDescriptor: fileDescriptor,
            eventMask: [.write, .rename, .delete],
            queue: .main
        )

        source.setEventHandler { [weak self] in
            self?.loadData()
        }

        source.setCancelHandler { [weak self] in
            if let fd = self?.fileDescriptor, fd >= 0 {
                close(fd)
                self?.fileDescriptor = -1
            }
        }

        source.resume()
        dispatchSource = source
    }

    // MARK: - Polling Fallback

    private func startPolling(interval: TimeInterval = 30) {
        pollingTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            self?.loadData()
        }
    }
}
