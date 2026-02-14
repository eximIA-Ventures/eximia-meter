import SwiftUI

struct PopoverContentView: View {
    @EnvironmentObject var appViewModel: AppViewModel

    @State private var alertBanner: AlertBannerData?
    @State private var autoDismissTask: DispatchWorkItem?
    @State private var updateAvailable = false
    @State private var remoteVersion: String?

    var body: some View {
        VStack(spacing: 0) {
            HeaderView()

            // Subtle amber gradient separator
            LinearGradient(
                colors: [.clear, ExTokens.Colors.accentPrimary.opacity(0.3), .clear],
                startPoint: .leading,
                endPoint: .trailing
            )
            .frame(height: 1)

            // Update banner
            if updateAvailable {
                Button {
                    AppDelegate.shared?.openSettings()
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "arrow.down.circle.fill")
                            .font(.system(size: 10))
                        Text("v\(remoteVersion ?? "?") available")
                            .font(.system(size: 10, weight: .semibold))
                        Spacer()
                        Text("Update")
                            .font(.system(size: 9, weight: .bold))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(ExTokens.Colors.accentPrimary.opacity(0.2))
                            .clipShape(RoundedRectangle(cornerRadius: ExTokens.Radius.xs))
                    }
                    .foregroundColor(ExTokens.Colors.accentPrimary)
                    .padding(.horizontal, ExTokens.Spacing.popoverPadding)
                    .padding(.vertical, 6)
                    .background(ExTokens.Colors.accentPrimary.opacity(0.08))
                }
                .buttonStyle(.plain)
            }

            // Alert banner overlay
            if let banner = alertBanner {
                AlertBannerView(data: banner) {
                    dismissBanner()
                }
            }

            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: ExTokens.Spacing._12) {
                    ProjectCarouselView()
                        .padding(.top, ExTokens.Spacing._8)

                    // Subtle divider
                    Rectangle()
                        .fill(ExTokens.Colors.borderDefault)
                        .frame(height: 1)
                        .padding(.horizontal, ExTokens.Spacing.popoverPadding)

                    UsageMetersSection()

                    HistorySection()
                }
                .padding(.bottom, ExTokens.Spacing._12)
            }

            Rectangle()
                .fill(ExTokens.Colors.borderDefault)
                .frame(height: 1)

            FooterView()
        }
        .frame(width: 420, height: 620)
        .background(ExTokens.Colors.backgroundPrimary)
        .animation(.easeInOut(duration: 0.3), value: alertBanner)
        .animation(.easeInOut(duration: 0.2), value: updateAvailable)
        .onReceive(NotificationCenter.default.publisher(for: NSPopover.willShowNotification)) { _ in
            appViewModel.projectsViewModel.refreshAIOSStatus()
            AnthropicUsageService.shared.refreshCredentials()
            checkForUpdates()
        }
        .onReceive(NotificationCenter.default.publisher(for: NotificationService.alertTriggeredNotification)) { notification in
            guard let userInfo = notification.userInfo,
                  let type = userInfo["type"] as? String,
                  let severity = userInfo["severity"] as? String,
                  let message = userInfo["message"] as? String else { return }

            showBanner(AlertBannerData(type: type, severity: severity, message: message))
        }
    }

    // MARK: - Update Check

    private func checkForUpdates() {
        let url = URL(string: "https://raw.githubusercontent.com/hugocapitelli/eximia-meter/main/Info.plist")!
        URLSession.shared.dataTask(with: url) { data, response, _ in
            DispatchQueue.main.async {
                guard let data,
                      let content = String(data: data, encoding: .utf8),
                      let http = response as? HTTPURLResponse,
                      http.statusCode == 200 else { return }

                if let range = content.range(of: "<key>CFBundleShortVersionString</key>"),
                   let start = content.range(of: "<string>", range: range.upperBound..<content.endIndex),
                   let end = content.range(of: "</string>", range: start.upperBound..<content.endIndex) {
                    let version = String(content[start.upperBound..<end.lowerBound])
                    let local = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
                    remoteVersion = version
                    updateAvailable = !version.isEmpty && AboutTabView.isNewer(remote: version, local: local)
                }
            }
        }.resume()
    }

    private func showBanner(_ data: AlertBannerData) {
        // Cancel previous auto-dismiss
        autoDismissTask?.cancel()

        alertBanner = data

        // Auto-dismiss after 8 seconds
        let task = DispatchWorkItem { [self] in
            dismissBanner()
        }
        autoDismissTask = task
        DispatchQueue.main.asyncAfter(deadline: .now() + 8, execute: task)
    }

    private func dismissBanner() {
        autoDismissTask?.cancel()
        autoDismissTask = nil
        withAnimation {
            alertBanner = nil
        }
    }
}
