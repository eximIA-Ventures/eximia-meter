import UserNotifications

class NotificationService {
    static let shared = NotificationService()

    private var notifiedThresholds: Set<String> = []
    private var isAvailable = false

    func requestPermission() {
        // UNUserNotificationCenter requires a valid bundle identifier
        guard Bundle.main.bundleIdentifier != nil else {
            print("Notifications unavailable: no bundle identifier (running via swift run?)")
            return
        }

        isAvailable = true
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, error in
            if let error {
                print("Notification permission error: \(error)")
            }
        }
    }

    func checkAndNotify(usageData: UsageData, thresholds: ThresholdConfig) {
        guard isAvailable else { return }

        checkThreshold(
            id: "weekly-warning",
            value: usageData.weeklyUsage,
            threshold: thresholds.weeklyWarning,
            title: "eximIA Meter - Weekly Warning",
            body: "Weekly usage at \(Int(usageData.weeklyUsage * 100))%"
        )

        checkThreshold(
            id: "weekly-critical",
            value: usageData.weeklyUsage,
            threshold: thresholds.weeklyCritical,
            title: "eximIA Meter - Weekly Critical",
            body: "Weekly usage at \(Int(usageData.weeklyUsage * 100))%! Consider slowing down."
        )

        checkThreshold(
            id: "session-warning",
            value: usageData.sessionUsage,
            threshold: thresholds.sessionWarning,
            title: "eximIA Meter - Session Warning",
            body: "Session usage at \(Int(usageData.sessionUsage * 100))%"
        )

        checkThreshold(
            id: "session-critical",
            value: usageData.sessionUsage,
            threshold: thresholds.sessionCritical,
            title: "eximIA Meter - Session Critical",
            body: "Session usage at \(Int(usageData.sessionUsage * 100))%! Near limit."
        )
    }

    func resetNotifications() {
        notifiedThresholds.removeAll()
    }

    private func checkThreshold(id: String, value: Double, threshold: Double, title: String, body: String) {
        guard value >= threshold, !notifiedThresholds.contains(id) else { return }

        notifiedThresholds.insert(id)

        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default

        let request = UNNotificationRequest(identifier: id, content: content, trigger: nil)
        UNUserNotificationCenter.current().add(request)
    }
}
