import SwiftUI

struct ThresholdEvaluatorService {
    static func evaluateSessionColor(percentage: Double, config: ThresholdConfig) -> Color {
        if percentage >= config.sessionCritical {
            return ExTokens.Colors.statusCritical
        } else if percentage >= config.sessionWarning {
            return ExTokens.Colors.statusWarning
        } else {
            return ExTokens.Colors.statusSuccess
        }
    }

    static func evaluateWeeklyColor(percentage: Double, config: ThresholdConfig) -> Color {
        if percentage >= config.weeklyCritical {
            return ExTokens.Colors.statusCritical
        } else if percentage >= config.weeklyWarning {
            return ExTokens.Colors.statusWarning
        } else {
            return ExTokens.Colors.statusSuccess
        }
    }
}
