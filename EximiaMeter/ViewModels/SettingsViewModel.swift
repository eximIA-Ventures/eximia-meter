import SwiftUI
import CryptoKit

// MARK: - Update Channel

enum UpdateChannel: String, CaseIterable, Identifiable {
    case stable = "Stable"
    case beta = "Beta"

    var id: String { rawValue }

    var branch: String {
        switch self {
        case .stable: return "main"
        case .beta:   return "beta"
        }
    }

    var icon: String {
        switch self {
        case .stable: return "checkmark.shield.fill"
        case .beta:   return "flask.fill"
        }
    }

    var description: String {
        switch self {
        case .stable: return "Atualizações testadas e estáveis"
        case .beta:   return "Acesso antecipado a novas versões"
        }
    }
}

// MARK: - Menu Bar Style

enum MenuBarStyle: String, CaseIterable, Identifiable {
    case logoOnly = "Logo Only"
    case withIndicators = "Logo + Usage"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .logoOnly:       return "square.dashed"
        case .withIndicators: return "chart.bar.fill"
        }
    }

    var shortLabel: String {
        switch self {
        case .logoOnly:       return "Logo"
        case .withIndicators: return "Usage"
        }
    }
}

// MARK: - Popover Size

enum PopoverSize: String, CaseIterable, Identifiable {
    case compact = "Compact"
    case normal = "Normal"
    case large = "Large"
    case extraLarge = "Extra Large"

    var id: String { rawValue }

    var dimensions: NSSize {
        switch self {
        case .compact:    return NSSize(width: 380, height: 540)
        case .normal:     return NSSize(width: 440, height: 680)
        case .large:      return NSSize(width: 500, height: 780)
        case .extraLarge: return NSSize(width: 560, height: 860)
        }
    }

    var icon: String {
        switch self {
        case .compact:    return "rectangle.compress.vertical"
        case .normal:     return "rectangle"
        case .large:      return "rectangle.expand.vertical"
        case .extraLarge: return "arrow.up.left.and.arrow.down.right"
        }
    }

    var shortLabel: String {
        switch self {
        case .compact:    return "S"
        case .normal:     return "M"
        case .large:      return "L"
        case .extraLarge: return "XL"
        }
    }
}

@Observable
class SettingsViewModel {
    /// When true, suppresses cascading UserDefaults writes from didSet observers
    private var isBatchingUpdates = false

    var thresholds: ThresholdConfig {
        didSet { saveThresholds() }
    }

    var claudePlan: ClaudePlan = .max20x {
        didSet {
            UserDefaults.standard.set(claudePlan.rawValue, forKey: "claudePlan")
            guard !isBatchingUpdates else { return }
            // Auto-update limits when plan changes
            isBatchingUpdates = true
            weeklyTokenLimit = claudePlan.weeklyTokenLimit
            sessionTokenLimit = claudePlan.sessionTokenLimit
            isBatchingUpdates = false
        }
    }

    var refreshInterval: TimeInterval = 30 {
        didSet { UserDefaults.standard.set(refreshInterval, forKey: "refreshInterval") }
    }

    var launchAtLogin: Bool = false {
        didSet { UserDefaults.standard.set(launchAtLogin, forKey: "launchAtLogin") }
    }

    var preferredTerminal: TerminalLauncherService.Terminal = .terminalApp {
        didSet { UserDefaults.standard.set(preferredTerminal.rawValue, forKey: "preferredTerminal") }
    }

    var notificationsEnabled: Bool = true {
        didSet { UserDefaults.standard.set(notificationsEnabled, forKey: "notificationsEnabled") }
    }

    var soundEnabled: Bool = true {
        didSet { UserDefaults.standard.set(soundEnabled, forKey: "soundEnabled") }
    }

    var inAppPopupEnabled: Bool = true {
        didSet { UserDefaults.standard.set(inAppPopupEnabled, forKey: "inAppPopupEnabled") }
    }

    var alertSound: AlertSound = .default {
        didSet { UserDefaults.standard.set(alertSound.rawValue, forKey: "alertSound") }
    }

    var systemNotificationsEnabled: Bool = true {
        didSet { UserDefaults.standard.set(systemNotificationsEnabled, forKey: "systemNotificationsEnabled") }
    }

    var popoverSize: PopoverSize = .normal {
        didSet {
            UserDefaults.standard.set(popoverSize.rawValue, forKey: "popoverSize")
            NotificationCenter.default.post(name: Notification.Name("PopoverSizeChanged"), object: nil)
        }
    }

    var menuBarStyle: MenuBarStyle = .logoOnly {
        didSet {
            UserDefaults.standard.set(menuBarStyle.rawValue, forKey: "menuBarStyle")
            NotificationCenter.default.post(name: Notification.Name("MenuBarStyleChanged"), object: nil)
        }
    }

    var hasCompletedOnboarding: Bool = false {
        didSet { UserDefaults.standard.set(hasCompletedOnboarding, forKey: "hasCompletedOnboarding") }
    }

    // MARK: - Admin Mode

    /// SHA256 hash of the admin activation code
    private let adminCodeHash = "8f843e09cd149d20415454e2d97a225b0f89ebc20b3e4870b3f17c12746a134f"

    var isAdminMode: Bool = false {
        didSet { UserDefaults.standard.set(isAdminMode, forKey: "isAdminMode") }
    }

    var updateChannel: UpdateChannel = .stable {
        didSet { UserDefaults.standard.set(updateChannel.rawValue, forKey: "updateChannel") }
    }

    func verifyAdminCode(_ code: String) -> Bool {
        let hash = SHA256.hash(data: Data(code.utf8))
        let hex = hash.map { String(format: "%02x", $0) }.joined()
        return hex == adminCodeHash
    }

    func deactivateAdmin() {
        isAdminMode = false
        updateChannel = .stable
    }

    var weeklyTokenLimit: Int = 2_000_000_000 {
        didSet { UserDefaults.standard.set(weeklyTokenLimit, forKey: "weeklyTokenLimit") }
    }

    var sessionTokenLimit: Int = 200_000_000 {
        didSet { UserDefaults.standard.set(sessionTokenLimit, forKey: "sessionTokenLimit") }
    }

    // MARK: - Account / Auto-detect

    var isPlanAutoDetected: Bool = false

    var isApiConnected: Bool {
        AnthropicUsageService.shared.getAccountInfo().isConnected
    }

    var accountInfo: AnthropicUsageService.AccountInfo {
        AnthropicUsageService.shared.getAccountInfo()
    }

    init() {
        let defaults = UserDefaults.standard

        // Suppress cascading writes during initial load
        isBatchingUpdates = true

        if let data = defaults.data(forKey: "thresholds"),
           let decoded = try? JSONDecoder().decode(ThresholdConfig.self, from: data) {
            thresholds = decoded
        } else {
            thresholds = .default
        }

        // Load plan first
        if let planRaw = defaults.string(forKey: "claudePlan"),
           let plan = ClaudePlan(rawValue: planRaw) {
            claudePlan = plan
        }

        refreshInterval = defaults.double(forKey: "refreshInterval").nonZero ?? 30
        launchAtLogin = defaults.bool(forKey: "launchAtLogin")
        notificationsEnabled = defaults.object(forKey: "notificationsEnabled") as? Bool ?? true
        soundEnabled = defaults.object(forKey: "soundEnabled") as? Bool ?? true
        inAppPopupEnabled = defaults.object(forKey: "inAppPopupEnabled") as? Bool ?? true
        systemNotificationsEnabled = defaults.object(forKey: "systemNotificationsEnabled") as? Bool ?? true
        if let soundRaw = defaults.string(forKey: "alertSound"),
           let sound = AlertSound(rawValue: soundRaw) {
            alertSound = sound
        }
        hasCompletedOnboarding = defaults.bool(forKey: "hasCompletedOnboarding")

        if let sizeRaw = defaults.string(forKey: "popoverSize"),
           let size = PopoverSize(rawValue: sizeRaw) {
            popoverSize = size
        }

        if let styleRaw = defaults.string(forKey: "menuBarStyle"),
           let style = MenuBarStyle(rawValue: styleRaw) {
            menuBarStyle = style
        }

        // Use plan defaults if no custom limits saved
        weeklyTokenLimit = (defaults.integer(forKey: "weeklyTokenLimit")).nonZero ?? claudePlan.weeklyTokenLimit
        sessionTokenLimit = (defaults.integer(forKey: "sessionTokenLimit")).nonZero ?? claudePlan.sessionTokenLimit

        if let terminalRaw = defaults.string(forKey: "preferredTerminal"),
           let terminal = TerminalLauncherService.Terminal(rawValue: terminalRaw) {
            preferredTerminal = terminal
        }

        // Admin mode
        isAdminMode = defaults.bool(forKey: "isAdminMode")
        if let channelRaw = defaults.string(forKey: "updateChannel"),
           let channel = UpdateChannel(rawValue: channelRaw) {
            updateChannel = channel
        }

        isBatchingUpdates = false

        // Auto-detect plan from Keychain credentials
        autoDetectPlan()
    }

    private func autoDetectPlan() {
        let info = AnthropicUsageService.shared.getAccountInfo()
        guard info.isConnected, let tier = info.rateLimitTier else { return }

        let detected: ClaudePlan?
        switch tier.lowercased() {
        case "free", "standard", "tier1":
            detected = .pro
        case "scale", "tier2", "5x":
            detected = .max5x
        case "tier3", "20x":
            detected = .max20x
        default:
            // Log unknown tier for debugging
            print("[SettingsVM] Unknown rateLimitTier: \(tier)")
            detected = nil
        }

        if let plan = detected {
            isPlanAutoDetected = true
            claudePlan = plan
        }
    }

    private func saveThresholds() {
        if let data = try? JSONEncoder().encode(thresholds) {
            UserDefaults.standard.set(data, forKey: "thresholds")
        }
    }
}

// Helpers
private extension Double {
    var nonZero: Double? { self == 0 ? nil : self }
}

private extension Int {
    var nonZero: Int? { self == 0 ? nil : self }
}
