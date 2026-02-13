import AppKit

struct TerminalLauncherService {
    enum Terminal: String, Codable, CaseIterable, Identifiable {
        case terminalApp = "Terminal"
        case iTerm2 = "iTerm"
        case warp = "Warp"

        var id: String { rawValue }

        var isInstalled: Bool {
            switch self {
            case .terminalApp:
                return true
            case .iTerm2:
                return NSWorkspace.shared.urlForApplication(withBundleIdentifier: "com.googlecode.iterm2") != nil
            case .warp:
                return NSWorkspace.shared.urlForApplication(withBundleIdentifier: "dev.warp.Warp-Stable") != nil
            }
        }
    }

    static func launch(project: Project, terminal: Terminal = .terminalApp) {
        let modelFlag = project.selectedModel.cliFlag
        launchCommand(path: project.path, command: "claude \(modelFlag)", terminal: terminal)
    }

    static func installAIOS(project: Project, terminal: Terminal = .terminalApp) {
        launchCommand(path: project.path, command: "npx aios-core install", terminal: terminal)
    }

    static func launchCommand(path: String, command: String, terminal: Terminal) {
        switch terminal {
        case .terminalApp:
            launchTerminalApp(path: path, command: command)
        case .iTerm2:
            launchiTerm2(path: path, command: command)
        case .warp:
            launchWarp(path: path, command: command)
        }
    }

    private static func launchTerminalApp(path: String, command: String) {
        let escapedPath = path.replacingOccurrences(of: "'", with: "'\\''")
        let script = """
        tell application "Terminal"
            activate
            do script "cd '\(escapedPath)' && \(command)"
        end tell
        """
        executeAppleScript(script)
    }

    private static func launchiTerm2(path: String, command: String) {
        let escapedPath = path.replacingOccurrences(of: "\"", with: "\\\"")
        let script = """
        tell application "iTerm"
            activate
            create window with default profile
            tell current session of current window
                write text "cd \\"\(escapedPath)\\" && \(command)"
            end tell
        end tell
        """
        executeAppleScript(script)
    }

    private static func launchWarp(path: String, command: String) {
        let escapedPath = path.replacingOccurrences(of: "'", with: "'\\''")
        let script = """
        tell application "Warp"
            activate
        end tell
        delay 0.5
        tell application "System Events"
            tell process "Warp"
                keystroke "t" using command down
                delay 0.3
                keystroke "cd '\(escapedPath)' && \(command)"
                key code 36
            end tell
        end tell
        """
        executeAppleScript(script)
    }

    private static func executeAppleScript(_ source: String) {
        DispatchQueue.global(qos: .userInitiated).async {
            guard let script = NSAppleScript(source: source) else { return }
            var error: NSDictionary?
            script.executeAndReturnError(&error)
            if let error {
                print("AppleScript error: \(error)")
            }
        }
    }
}
