import Foundation

struct AppSettingsStore {
    private static let defaults = UserDefaults.standard

    static var globalModel: ClaudeModel {
        get {
            guard let raw = defaults.string(forKey: "globalModel"),
                  let model = ClaudeModel(rawValue: raw) else { return .opus }
            return model
        }
        set {
            defaults.set(newValue.rawValue, forKey: "globalModel")
        }
    }

    static var lastRefresh: Date {
        get { defaults.object(forKey: "lastRefresh") as? Date ?? Date.distantPast }
        set { defaults.set(newValue, forKey: "lastRefresh") }
    }
}
