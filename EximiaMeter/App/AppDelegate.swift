import SwiftUI
import AppKit

class AppDelegate: NSObject, NSApplicationDelegate, ObservableObject {
    private var statusItem: NSStatusItem?
    private var popover: NSPopover?
    private var settingsWindow: NSWindow?
    private var eventMonitor: Any?

    let appViewModel = AppViewModel()

    /// Shared reference accessible from views
    static weak var shared: AppDelegate?

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
        AppDelegate.shared = self

        setupStatusItem()
        setupPopover()
        setupEventMonitor()

        appViewModel.start()
    }

    // MARK: - Status Item

    private func setupStatusItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)

        if let button = statusItem?.button {
            button.image = createMenuBarIcon()
            button.image?.size = NSSize(width: 18, height: 18)
            button.action = #selector(togglePopover)
            button.target = self
        }
    }

    private func createMenuBarIcon() -> NSImage {
        let size = NSSize(width: 16, height: 16)
        let image = NSImage(size: size, flipped: true) { rect in
            guard let ctx = NSGraphicsContext.current?.cgContext else { return false }

            let vw: CGFloat = 120.4
            let vh: CGFloat = 136.01
            let scale = min(rect.width / vw, rect.height / vh)
            let ox = (rect.width - vw * scale) / 2
            let oy = (rect.height - vh * scale) / 2

            ctx.translateBy(x: ox, y: oy)
            ctx.scaleBy(x: scale, y: scale)

            // Right path
            let r = CGMutablePath()
            r.move(to: CGPoint(x: 58.88, y: 132.06))
            r.addCurve(to: CGPoint(x: 64.41, y: 135.56), control1: CGPoint(x: 58.88, y: 134.9), control2: CGPoint(x: 61.84, y: 136.78))
            r.addLine(to: CGPoint(x: 115.41, y: 111.47))
            r.addCurve(to: CGPoint(x: 120.39, y: 103.58), control1: CGPoint(x: 118.45, y: 110.03), control2: CGPoint(x: 120.4, y: 106.96))
            r.addLine(to: CGPoint(x: 120.37, y: 79.71))
            r.addLine(to: CGPoint(x: 120.37, y: 77.9))
            r.addLine(to: CGPoint(x: 120.31, y: 16.95))
            r.addCurve(to: CGPoint(x: 114.59, y: 9.14), control1: CGPoint(x: 120.31, y: 13.38), control2: CGPoint(x: 118.0, y: 10.22))
            r.addLine(to: CGPoint(x: 87.3, y: 0.46))
            r.addCurve(to: CGPoint(x: 76.61, y: 8.29), control1: CGPoint(x: 82.01, y: -1.22), control2: CGPoint(x: 76.6, y: 2.73))
            r.addLine(to: CGPoint(x: 76.65, y: 46.8))
            r.addCurve(to: CGPoint(x: 94.28, y: 71.12), control1: CGPoint(x: 76.66, y: 57.87), control2: CGPoint(x: 83.77, y: 67.68))
            r.addLine(to: CGPoint(x: 117.89, y: 78.9))
            r.addLine(to: CGPoint(x: 64.61, y: 100.28))
            r.addCurve(to: CGPoint(x: 58.86, y: 108.79), control1: CGPoint(x: 61.13, y: 101.67), control2: CGPoint(x: 58.86, y: 105.05))
            r.addLine(to: CGPoint(x: 58.88, y: 132.06))
            r.closeSubpath()

            // Left path
            let l = CGMutablePath()
            l.move(to: CGPoint(x: 61.33, y: 3.85))
            l.addCurve(to: CGPoint(x: 55.77, y: 0.38), control1: CGPoint(x: 61.31, y: 1.01), control2: CGPoint(x: 58.34, y: -0.85))
            l.addLine(to: CGPoint(x: 4.93, y: 24.8))
            l.addCurve(to: CGPoint(x: 0.0, y: 32.73), control1: CGPoint(x: 1.9, y: 26.27), control2: CGPoint(x: -0.02, y: 29.35))
            l.addLine(to: CGPoint(x: 0.18, y: 56.6))
            l.addLine(to: CGPoint(x: 0.18, y: 58.41))
            l.addLine(to: CGPoint(x: 0.65, y: 119.35))
            l.addCurve(to: CGPoint(x: 6.42, y: 127.12), control1: CGPoint(x: 0.68, y: 122.92), control2: CGPoint(x: 3.01, y: 126.06))
            l.addLine(to: CGPoint(x: 33.77, y: 135.63))
            l.addCurve(to: CGPoint(x: 44.41, y: 127.74), control1: CGPoint(x: 39.07, y: 137.28), control2: CGPoint(x: 44.45, y: 133.3))
            l.addLine(to: CGPoint(x: 44.12, y: 89.23))
            l.addCurve(to: CGPoint(x: 26.33, y: 65.02), control1: CGPoint(x: 44.04, y: 78.16), control2: CGPoint(x: 36.86, y: 68.4))
            l.addLine(to: CGPoint(x: 2.67, y: 57.4))
            l.addLine(to: CGPoint(x: 55.81, y: 35.67))
            l.addCurve(to: CGPoint(x: 61.5, y: 27.12), control1: CGPoint(x: 59.28, y: 34.25), control2: CGPoint(x: 61.53, y: 30.87))
            l.addLine(to: CGPoint(x: 61.33, y: 3.85))
            l.closeSubpath()

            ctx.setFillColor(NSColor.white.cgColor)
            ctx.addPath(r)
            ctx.fillPath()
            ctx.addPath(l)
            ctx.fillPath()

            return true
        }

        image.isTemplate = true
        return image
    }

    // MARK: - Popover

    private func setupPopover() {
        let popover = NSPopover()
        popover.contentSize = NSSize(width: 420, height: 620)
        popover.behavior = .transient
        popover.animates = true

        let contentView = PopoverContentView()
            .environmentObject(appViewModel)

        popover.contentViewController = NSHostingController(rootView: contentView)
        self.popover = popover
    }

    func getPopover() -> NSPopover? {
        popover
    }

    @objc private func togglePopover() {
        guard let popover, let button = statusItem?.button else { return }

        if popover.isShown {
            popover.performClose(nil)
        } else {
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
            popover.contentViewController?.view.window?.makeKey()
        }
    }

    // MARK: - Settings Window

    func openSettings() {
        // Close the popover if it's open
        if let popover, popover.isShown {
            popover.performClose(nil)
        }

        if let settingsWindow, settingsWindow.isVisible {
            settingsWindow.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
            return
        }

        let settingsView = SettingsWindowView()
            .environmentObject(appViewModel)

        let hostingController = NSHostingController(rootView: settingsView)
        let window = NSWindow(contentViewController: hostingController)
        window.title = "exímIA Meter Settings"
        window.setContentSize(NSSize(width: 520, height: 440))
        window.styleMask = [.titled, .closable, .miniaturizable]
        window.center()
        window.isReleasedWhenClosed = false
        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)

        self.settingsWindow = window
    }

    // MARK: - Event Monitor

    private func setupEventMonitor() {
        eventMonitor = NSEvent.addGlobalMonitorForEvents(matching: [.leftMouseDown, .rightMouseDown]) { [weak self] _ in
            if let popover = self?.popover, popover.isShown {
                popover.performClose(nil)
            }
        }
    }

    func applicationWillTerminate(_ notification: Notification) {
        if let eventMonitor {
            NSEvent.removeMonitor(eventMonitor)
        }
        appViewModel.stop()
    }
}
