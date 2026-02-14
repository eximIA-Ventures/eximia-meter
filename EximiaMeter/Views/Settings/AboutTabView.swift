import SwiftUI

struct AboutTabView: View {
    @State private var isUpdating = false

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: ExTokens.Spacing._16) {
                // Logo
                Image(systemName: "gauge.with.dots.needle.33percent")
                    .font(.system(size: 40))
                    .foregroundColor(ExTokens.Colors.accentPrimary)

                // App name
                VStack(spacing: 4) {
                    Text("exímIA Meter")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(ExTokens.Colors.textPrimary)

                    Text("Version \(appVersion) (\(buildNumber))")
                        .font(.system(size: 11, design: .monospaced))
                        .foregroundColor(ExTokens.Colors.textTertiary)
                }

                // Description
                Text("macOS menu bar app for monitoring\nClaude Code usage in real-time")
                    .font(.system(size: 11))
                    .foregroundColor(ExTokens.Colors.textSecondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(2)

                // Copyright
                Text(copyright)
                    .font(.system(size: 10))
                    .foregroundColor(ExTokens.Colors.textMuted)
            }

            Spacer()

            // Links + Actions
            VStack(spacing: ExTokens.Spacing._12) {
                // GitHub link
                Button {
                    if let url = URL(string: "https://github.com/hugocapitelli/eximia-meter") {
                        NSWorkspace.shared.open(url)
                    }
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "link")
                            .font(.system(size: 11))
                        Text("GitHub Repository")
                            .font(.system(size: 11, weight: .medium))
                    }
                    .foregroundColor(ExTokens.Colors.accentPrimary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(ExTokens.Colors.accentPrimary.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: ExTokens.Radius.md)
                            .stroke(ExTokens.Colors.accentPrimary.opacity(0.2), lineWidth: 1)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: ExTokens.Radius.md))
                }
                .buttonStyle(.plain)

                // Update
                Button {
                    updateApp()
                } label: {
                    HStack(spacing: 6) {
                        if isUpdating {
                            ProgressView()
                                .controlSize(.small)
                                .scaleEffect(0.7)
                        } else {
                            Image(systemName: "arrow.triangle.2.circlepath")
                                .font(.system(size: 11))
                        }
                        Text(isUpdating ? "Updating..." : "Check for Updates")
                            .font(.system(size: 11, weight: .medium))
                    }
                    .foregroundColor(ExTokens.Colors.statusSuccess)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(ExTokens.Colors.statusSuccess.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: ExTokens.Radius.md)
                            .stroke(ExTokens.Colors.statusSuccess.opacity(0.2), lineWidth: 1)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: ExTokens.Radius.md))
                }
                .buttonStyle(.plain)
                .disabled(isUpdating)

                // Uninstall
                Button {
                    AppDelegate.shared?.uninstallApp()
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "trash")
                            .font(.system(size: 11))
                        Text("Uninstall exímIA Meter")
                            .font(.system(size: 11, weight: .medium))
                    }
                    .foregroundColor(ExTokens.Colors.destructive)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(ExTokens.Colors.destructiveBg)
                    .overlay(
                        RoundedRectangle(cornerRadius: ExTokens.Radius.md)
                            .stroke(ExTokens.Colors.destructive.opacity(0.3), lineWidth: 1)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: ExTokens.Radius.md))
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, ExTokens.Spacing._32)
            .padding(.bottom, ExTokens.Spacing._24)
        }
    }

    // MARK: - Info.plist values

    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
    }

    private var buildNumber: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    }

    private var copyright: String {
        Bundle.main.infoDictionary?["NSHumanReadableCopyright"] as? String ?? "Copyright 2026 exímIA"
    }

    private func updateApp() {
        isUpdating = true
        let script = """
        set -e
        REPO_URL="https://github.com/hugocapitelli/eximia-meter.git"
        TMPDIR_PATH=$(mktemp -d)
        SRC_DIR="$TMPDIR_PATH/eximia-meter"
        trap "rm -rf $TMPDIR_PATH" EXIT
        git clone --depth 1 "$REPO_URL" "$SRC_DIR" 2>/dev/null
        cd "$SRC_DIR" && swift build -c release 2>/dev/null
        BINARY="$SRC_DIR/.build/release/EximiaMeter"
        APP_BUNDLE="$TMPDIR_PATH/exímIA Meter.app"
        mkdir -p "$APP_BUNDLE/Contents/MacOS"
        mkdir -p "$APP_BUNDLE/Contents/Resources"
        cp "$BINARY" "$APP_BUNDLE/Contents/MacOS/EximiaMeter"
        chmod +x "$APP_BUNDLE/Contents/MacOS/EximiaMeter"
        cp "$SRC_DIR/Info.plist" "$APP_BUNDLE/Contents/"
        cp "$SRC_DIR/Resources/AppIcon.icns" "$APP_BUNDLE/Contents/Resources/" 2>/dev/null || true
        echo -n "APPL????" > "$APP_BUNDLE/Contents/PkgInfo"
        rm -rf "/Applications/exímIA Meter.app"
        cp -R "$APP_BUNDLE" "/Applications/"
        open "/Applications/exímIA Meter.app"
        """

        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/bin/bash")
        process.arguments = ["-c", script]

        process.terminationHandler = { proc in
            DispatchQueue.main.async {
                isUpdating = false
                if proc.terminationStatus == 0 {
                    NSApp.terminate(self)
                } else {
                    let alert = NSAlert()
                    alert.messageText = "Update Failed"
                    alert.informativeText = "Could not update exímIA Meter. Check your internet connection and try again."
                    alert.alertStyle = .warning
                    alert.addButton(withTitle: "OK")
                    alert.runModal()
                }
            }
        }

        try? process.run()
    }
}
