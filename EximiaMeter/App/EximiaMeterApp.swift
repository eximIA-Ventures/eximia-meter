import SwiftUI

@main
struct EximiaMeterApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        Settings {
            SettingsWindowView()
                .environmentObject(appDelegate.appViewModel)
        }
    }
}
