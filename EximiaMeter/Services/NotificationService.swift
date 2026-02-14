import UserNotifications
import AppKit

class NotificationService: NSObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationService()

    /// Notification posted when an in-app alert should be shown
    static let alertTriggeredNotification = Notification.Name("ExAlertTriggered")

    private var notifiedThresholds: Set<String> = []
    private var lastNotifiedAt: [String: Date] = [:]
    private var permissionGranted = false

    private let cooldownInterval: TimeInterval = 300 // 5 minutes

    // Settings — updated from AppViewModel before each check
    var soundEnabled: Bool = true
    var inAppPopupEnabled: Bool = true
    var systemNotificationsEnabled: Bool = true
    var alertSound: AlertSound = .default

    override init() {
        super.init()
        // Always set delegate immediately so foreground notifications work
        let center = UNUserNotificationCenter.current()
        center.delegate = self
    }

    func requestPermission() {
        let bundleId = Bundle.main.bundleIdentifier ?? "nil"
        print("[Notifications] bundleIdentifier: \(bundleId)")

        guard Bundle.main.bundleIdentifier != nil else {
            print("[Notifications] unavailable: no bundle identifier (running via swift run?)")
            return
        }

        let center = UNUserNotificationCenter.current()

        // Check current authorization status first
        center.getNotificationSettings { settings in
            print("[Notifications] current status: \(settings.authorizationStatus.rawValue) (0=notDetermined, 1=denied, 2=authorized, 3=provisional)")
        }

        center.requestAuthorization(options: [.alert, .sound, .badge]) { [weak self] granted, error in
            DispatchQueue.main.async {
                self?.permissionGranted = granted
            }
            if let error {
                print("[Notifications] permission error: \(error)")
            }
            print("[Notifications] permission \(granted ? "granted" : "denied")")
        }
    }

    // MARK: - UNUserNotificationCenterDelegate

    /// Allow system notifications to appear even when the app is in the foreground
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        var options: UNNotificationPresentationOptions = [.banner, .list]
        if soundEnabled {
            options.insert(.sound)
        }
        completionHandler(options)
    }

    /// Handle notification tap
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        DispatchQueue.main.async {
            NSApp.activate()
        }
        completionHandler()
    }

    // MARK: - Check & Notify

    func checkAndNotify(usageData: UsageData, thresholds: ThresholdConfig) {
        // Smart reset: if usage drops below threshold, allow re-notification
        resetIfBelow(id: "session-warning", value: usageData.sessionUsage, threshold: thresholds.sessionWarning)
        resetIfBelow(id: "session-critical", value: usageData.sessionUsage, threshold: thresholds.sessionCritical)
        resetIfBelow(id: "weekly-warning", value: usageData.weeklyUsage, threshold: thresholds.weeklyWarning)
        resetIfBelow(id: "weekly-critical", value: usageData.weeklyUsage, threshold: thresholds.weeklyCritical)

        checkThreshold(
            id: "session-warning",
            value: usageData.sessionUsage,
            threshold: thresholds.sessionWarning,
            title: "Session Warning",
            body: "Session usage at \(Int(usageData.sessionUsage * 100))%",
            severity: "warning"
        )

        checkThreshold(
            id: "session-critical",
            value: usageData.sessionUsage,
            threshold: thresholds.sessionCritical,
            title: "Session Critical",
            body: "Session usage at \(Int(usageData.sessionUsage * 100))%! Near limit.",
            severity: "critical"
        )

        checkThreshold(
            id: "weekly-warning",
            value: usageData.weeklyUsage,
            threshold: thresholds.weeklyWarning,
            title: "Weekly Warning",
            body: "Weekly usage at \(Int(usageData.weeklyUsage * 100))%",
            severity: "warning"
        )

        checkThreshold(
            id: "weekly-critical",
            value: usageData.weeklyUsage,
            threshold: thresholds.weeklyCritical,
            title: "Weekly Critical",
            body: "Weekly usage at \(Int(usageData.weeklyUsage * 100))%! Consider slowing down.",
            severity: "critical"
        )
    }

    func resetNotifications() {
        notifiedThresholds.removeAll()
        lastNotifiedAt.removeAll()
    }

    /// Send a test system notification (for preview from Settings)
    func sendTestNotification(severity: String) {
        let title = severity == "critical" ? "Session Critical" : "Session Warning"
        let body = severity == "critical"
            ? "Session usage at 95%! Near limit."
            : "Session usage at 65% — warning level"

        print("[Notifications] sendTestNotification(\(severity)) — bundleId: \(Bundle.main.bundleIdentifier ?? "nil"), permissionGranted: \(permissionGranted)")

        // Check permission status before sending
        UNUserNotificationCenter.current().getNotificationSettings { [self] settings in
            print("[Notifications] authStatus: \(settings.authorizationStatus.rawValue), alertSetting: \(settings.alertSetting.rawValue)")

            guard settings.authorizationStatus == .authorized || settings.authorizationStatus == .provisional else {
                print("[Notifications] NOT authorized — requesting permission now")
                self.requestPermission()
                // Try sending anyway after a short delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    self.doSendNotification(title: title, body: body, severity: severity)
                }
                return
            }

            self.doSendNotification(title: title, body: body, severity: severity)
        }
    }

    private func doSendNotification(title: String, body: String, severity: String) {
        let content = UNMutableNotificationContent()
        content.title = "eximIA Meter — \(title)"
        content.body = body
        content.sound = soundEnabled ? .default : nil

        let id = "preview-\(severity)-\(Int(Date().timeIntervalSince1970 * 1000))"
        let request = UNNotificationRequest(identifier: id, content: content, trigger: nil)

        UNUserNotificationCenter.current().add(request) { error in
            if let error {
                print("[Notifications] test notification FAILED: \(error)")
            } else {
                print("[Notifications] test notification SENT OK: \(id)")
            }
        }
    }

    // MARK: - Private

    private func resetIfBelow(id: String, value: Double, threshold: Double) {
        if value < threshold {
            notifiedThresholds.remove(id)
        }
    }

    private func checkThreshold(id: String, value: Double, threshold: Double, title: String, body: String, severity: String) {
        guard value >= threshold else { return }
        guard !notifiedThresholds.contains(id) else { return }

        // Cooldown: don't re-fire the same alert within 5 minutes
        if let lastFired = lastNotifiedAt[id], Date().timeIntervalSince(lastFired) < cooldownInterval {
            return
        }

        notifiedThresholds.insert(id)
        lastNotifiedAt[id] = Date()

        // macOS system notification (Notification Center banner)
        if systemNotificationsEnabled {
            let content = UNMutableNotificationContent()
            content.title = "eximIA Meter — \(title)"
            content.body = body
            content.sound = soundEnabled ? .default : nil

            let request = UNNotificationRequest(identifier: id, content: content, trigger: nil)
            UNUserNotificationCenter.current().add(request) { error in
                if let error {
                    print("[Notifications] send failed: \(error)")
                }
            }
        }

        // Play custom sound (independent of system notification)
        if soundEnabled {
            alertSound.play()
        }

        // In-app popup event
        if inAppPopupEnabled {
            DispatchQueue.main.async {
                NotificationCenter.default.post(
                    name: NotificationService.alertTriggeredNotification,
                    object: nil,
                    userInfo: [
                        "type": id,
                        "severity": severity,
                        "message": body
                    ]
                )
            }
        }
    }
}
