import AppKit

enum AlertSound: String, Codable, CaseIterable, Identifiable {
    case `default` = "default"
    case glass = "Glass"
    case ping = "Ping"
    case pop = "Pop"
    case purr = "Purr"
    case submarine = "Submarine"
    case tink = "Tink"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .default:   return "Default"
        case .glass:     return "Glass"
        case .ping:      return "Ping"
        case .pop:       return "Pop"
        case .purr:      return "Purr"
        case .submarine: return "Submarine"
        case .tink:      return "Tink"
        }
    }

    func play() {
        if self == .default {
            NSSound.beep()
        } else {
            NSSound(named: NSSound.Name(rawValue))?.play()
        }
    }
}
