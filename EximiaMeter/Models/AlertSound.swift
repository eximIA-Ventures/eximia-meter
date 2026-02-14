import AppKit

enum AlertSound: String, Codable, CaseIterable, Identifiable {
    case `default` = "default"
    case basso = "Basso"
    case blow = "Blow"
    case bottle = "Bottle"
    case frog = "Frog"
    case funk = "Funk"
    case glass = "Glass"
    case hero = "Hero"
    case morse = "Morse"
    case ping = "Ping"
    case pop = "Pop"
    case purr = "Purr"
    case sosumi = "Sosumi"
    case submarine = "Submarine"
    case tink = "Tink"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .default:   return "Default (Beep)"
        case .basso:     return "Basso"
        case .blow:      return "Blow"
        case .bottle:    return "Bottle"
        case .frog:      return "Frog"
        case .funk:      return "Funk"
        case .glass:     return "Glass"
        case .hero:      return "Hero"
        case .morse:     return "Morse"
        case .ping:      return "Ping"
        case .pop:       return "Pop"
        case .purr:      return "Purr"
        case .sosumi:    return "Sosumi"
        case .submarine: return "Submarine"
        case .tink:      return "Tink"
        }
    }

    var emoji: String {
        switch self {
        case .default:   return "🔔"
        case .basso:     return "🎵"
        case .blow:      return "💨"
        case .bottle:    return "🍾"
        case .frog:      return "🐸"
        case .funk:      return "🎸"
        case .glass:     return "🥂"
        case .hero:      return "🦸"
        case .morse:     return "📡"
        case .ping:      return "📍"
        case .pop:       return "🫧"
        case .purr:      return "🐱"
        case .sosumi:    return "⚖️"
        case .submarine: return "🚢"
        case .tink:      return "🔧"
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
