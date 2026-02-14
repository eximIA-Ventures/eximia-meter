import SwiftUI

struct AboutTabView: View {
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
}
