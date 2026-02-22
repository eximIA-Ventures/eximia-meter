import SwiftUI
import Combine

class AppViewModel: ObservableObject {
    @Published var globalModel: ClaudeModel = .opus
    @Published var usageViewModel = UsageViewModel()
    @Published var projectsViewModel = ProjectsViewModel()
    @Published var settingsViewModel = SettingsViewModel()

    let monitorService = CLIMonitorService()
    private let projectUsage = ProjectUsageService.shared
    private let apiService = AnthropicUsageService.shared
    private let workTime = WorkTimeService.shared

    private var updateTimer: Timer?
    private var cacheCleanupTimer: Timer?
    private let refreshLock = NSLock()
    private var isRefreshing = false

    func start() {
        monitorService.start()
        projectsViewModel.load()

        // Always request permission — needed for system notifications to work
        NotificationService.shared.requestPermission()

        refreshUsageData()

        // Main refresh: 60s interval (was 5s — major perf improvement)
        updateTimer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { [weak self] _ in
            self?.refreshUsageData()
        }

        // Prune stale cache entries every 30 minutes
        cacheCleanupTimer = Timer.scheduledTimer(withTimeInterval: 1800, repeats: true) { [weak self] _ in
            self?.projectUsage.pruneCache()
            self?.workTime.pruneCache()
            NotificationService.shared.prunePersistedState()
        }
    }

    func stop() {
        monitorService.stop()
        updateTimer?.invalidate()
        updateTimer = nil
        cacheCleanupTimer?.invalidate()
        cacheCleanupTimer = nil
    }

    func refresh() {
        monitorService.refresh()
        refreshUsageData()
    }

    private func refreshUsageData() {
        // Prevent overlapping refreshes
        refreshLock.lock()
        guard !isRefreshing else {
            refreshLock.unlock()
            return
        }
        isRefreshing = true
        refreshLock.unlock()

        // Capture ALL settings values on the main thread before dispatching
        let weeklyTokenLimit = settingsViewModel.weeklyTokenLimit
        let sessionTokenLimit = settingsViewModel.sessionTokenLimit
        let claudePlan = settingsViewModel.claudePlan
        let notificationsEnabled = settingsViewModel.notificationsEnabled
        let thresholds = settingsViewModel.thresholds
        let soundEnabled = settingsViewModel.soundEnabled
        let inAppPopupEnabled = settingsViewModel.inAppPopupEnabled
        let systemNotificationsEnabled = settingsViewModel.systemNotificationsEnabled
        let alertSound = settingsViewModel.alertSound

        let limits = UsageCalculatorService.Limits(
            weeklyTokenLimit: weeklyTokenLimit,
            dailyTokenLimit: weeklyTokenLimit / 7,
            sessionTokenLimit: sessionTokenLimit
        )

        let historyEntries = monitorService.historyEntries
        let statsCache = monitorService.statsCache
        let currentSessionId = historyEntries.last?.sessionId

        // All heavy work on background thread
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self else { return }
            defer {
                self.refreshLock.lock()
                self.isRefreshing = false
                self.refreshLock.unlock()
            }

            // Layer 2: Exact tokens from .jsonl scan (cached — fast after first run)
            let weekAgo = Date().addingTimeInterval(-7 * 86400)
            let dayAgo = Calendar.current.startOfDay(for: Date())
            let exactWeekly = self.projectUsage.totalTokens(since: weekAgo)
            let exactDaily = self.projectUsage.totalTokens(since: dayAgo)
            let exactSession: Int? = currentSessionId.flatMap { sid in
                let tokens = self.projectUsage.currentSessionTokens(sessionId: sid)
                return tokens > 0 ? tokens : nil
            }

            let exactTokens = UsageCalculatorService.ExactTokenData(
                weeklyTokens: exactWeekly,
                dailyTokens: exactDaily,
                sessionTokens: exactSession
            )

            // Per-project usage (uses same cache — almost free after totalTokens call)
            let perProject = self.projectUsage.scanAllProjects()

            // Layer 1: API call (async, non-blocking)
            // Run API fetch concurrently with local data processing
            let apiGroup = DispatchGroup()
            var apiUsage: UsageCalculatorService.APIUsageData?

            apiGroup.enter()
            Task {
                if let response = await self.apiService.fetchUsage() {
                    apiUsage = UsageCalculatorService.APIUsageData(
                        weeklyUtilization: response.weeklyUtilization,
                        weeklyResetsAt: response.weeklyResetsAt,
                        sessionUtilization: response.sessionUtilization,
                        sessionResetsAt: response.sessionResetsAt
                    )
                }
                apiGroup.leave()
            }

            // Wait for API (max 10s, then proceed with local data)
            _ = apiGroup.wait(timeout: .now() + 10)

            // Calibration: save snapshot on API success, load on failure
            var calibrationData: UsageCalculatorService.CalibrationData?

            if let api = apiUsage {
                // API available — save calibration snapshot for future use
                let snapshot = CalibrationStore.Snapshot(
                    timestamp: Date(),
                    apiWeeklyPercent: api.weeklyUtilization,
                    apiSessionPercent: api.sessionUtilization,
                    apiWeeklyResetsAt: api.weeklyResetsAt,
                    apiSessionResetsAt: api.sessionResetsAt,
                    localWeeklyTokens: exactWeekly,
                    localSessionTokens: exactSession ?? 0
                )
                CalibrationStore.save(snapshot)
            } else {
                // API unavailable — try calibrated limits
                let calWeekly = CalibrationStore.effectiveWeeklyLimit(fallback: limits.weeklyTokenLimit)
                let calSession = CalibrationStore.effectiveSessionLimit(fallback: limits.sessionTokenLimit)
                if calWeekly != nil || calSession != nil {
                    calibrationData = UsageCalculatorService.CalibrationData(
                        effectiveWeeklyLimit: calWeekly,
                        effectiveSessionLimit: calSession
                    )
                }
            }

            // Calculate with 3-layer hybrid + calibration
            var usageData = UsageCalculatorService.calculate(
                from: statsCache,
                limits: limits,
                historyEntries: historyEntries,
                apiUsage: apiUsage,
                exactTokens: exactTokens,
                calibration: calibrationData
            )

            usageData.perProjectTokens = perProject
            usageData.claudePlan = claudePlan

            // Work time (Active Window Detection)
            usageData.workSecondsToday = self.workTime.workSecondsToday()
            usageData.workSecondsThisWeek = self.workTime.workSecondsThisWeek()

            // Update UI on main thread
            DispatchQueue.main.async {
                self.usageViewModel.update(from: usageData)

                // Update menu bar indicators
                AppDelegate.shared?.updateMenuBarIndicators()

                if notificationsEnabled {
                    NotificationService.shared.soundEnabled = soundEnabled
                    NotificationService.shared.inAppPopupEnabled = inAppPopupEnabled
                    NotificationService.shared.systemNotificationsEnabled = systemNotificationsEnabled
                    NotificationService.shared.alertSound = alertSound
                    NotificationService.shared.checkAndNotify(
                        usageData: usageData,
                        thresholds: thresholds
                    )
                    NotificationService.shared.checkWeeklyReport(usageData: usageData)
                    NotificationService.shared.checkIdleReturn(usageData: usageData)
                }
            }
        }
    }
}
