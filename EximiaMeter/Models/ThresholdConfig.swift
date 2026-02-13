import Foundation

struct ThresholdConfig: Codable {
    var sessionWarning: Double = 0.62
    var sessionCritical: Double = 0.93
    var weeklyWarning: Double = 0.65
    var weeklyCritical: Double = 0.80

    static let `default` = ThresholdConfig()
}
