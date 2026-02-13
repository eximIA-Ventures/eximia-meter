import SwiftUI
import Combine

class AppViewModel: ObservableObject {
    @Published var globalModel: ClaudeModel = .opus
    @Published var usageViewModel = UsageViewModel()
    @Published var projectsViewModel = ProjectsViewModel()
    @Published var settingsViewModel = SettingsViewModel()

    let monitorService = CLIMonitorService()

    // Status bar now shows only the logo icon — no dynamic text updates needed

    private var updateTimer: Timer?

    func start() {
        monitorService.start()
        projectsViewModel.load()

        if settingsViewModel.notificationsEnabled {
            NotificationService.shared.requestPermission()
        }

        refreshUsageData()

        updateTimer = Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { [weak self] _ in
            self?.refreshUsageData()
        }
    }

    func stop() {
        monitorService.stop()
        updateTimer?.invalidate()
        updateTimer = nil
    }

    func refresh() {
        monitorService.refresh()
        projectsViewModel.discoverProjects()
        refreshUsageData()
    }

    private func refreshUsageData() {
        let limits = UsageCalculatorService.Limits(
            weeklyTokenLimit: settingsViewModel.weeklyTokenLimit,
            dailyTokenLimit: settingsViewModel.weeklyTokenLimit / 7,
            sessionTokenLimit: settingsViewModel.sessionTokenLimit
        )

        var usageData = UsageCalculatorService.calculate(
            from: monitorService.statsCache,
            limits: limits,
            historyEntries: monitorService.historyEntries
        )

        // Per-project usage
        usageData.perProjectTokens = ProjectUsageService.calculatePerProjectUsage(
            projects: projectsViewModel.projects,
            statsCache: monitorService.statsCache
        )

        usageViewModel.update(from: usageData)

        if settingsViewModel.notificationsEnabled {
            NotificationService.shared.checkAndNotify(
                usageData: usageData,
                thresholds: settingsViewModel.thresholds
            )
        }

        // Status bar is icon-only, no update needed
    }
}
