import SwiftUI

struct OnboardingWindowView: View {
    @EnvironmentObject var appViewModel: AppViewModel
    @State private var currentStep = 0
    @State private var selectedProjectNames: Set<String> = []
    var onComplete: () -> Void

    private let totalSteps = 5

    private var settings: SettingsViewModel {
        appViewModel.settingsViewModel
    }

    private var projects: ProjectsViewModel {
        appViewModel.projectsViewModel
    }

    var body: some View {
        VStack(spacing: 0) {
            // Content
            Group {
                switch currentStep {
                case 0:
                    OnboardingWelcomeStep()
                case 1:
                    OnboardingPlanStep(settings: settings)
                case 2:
                    OnboardingFeaturesStep()
                case 3:
                    OnboardingProjectsStep(
                        projectsViewModel: projects,
                        selectedProjectNames: $selectedProjectNames
                    )
                case 4:
                    OnboardingDoneStep(
                        selectedPlan: settings.claudePlan,
                        projectCount: selectedProjectNames.count
                    )
                default:
                    EmptyView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(.horizontal, ExTokens.Spacing._24)
            .padding(.top, ExTokens.Spacing._24)

            // Bottom bar: dots + buttons
            VStack(spacing: ExTokens.Spacing._16) {
                // Page dots
                HStack(spacing: ExTokens.Spacing._6) {
                    ForEach(0..<totalSteps, id: \.self) { index in
                        Circle()
                            .fill(index == currentStep
                                ? ExTokens.Colors.accentPrimary
                                : ExTokens.Colors.textMuted)
                            .frame(width: 7, height: 7)
                    }
                }

                // Navigation buttons
                HStack(spacing: ExTokens.Spacing._12) {
                    if currentStep > 0 && currentStep < totalSteps - 1 {
                        ExButton(title: "Back", variant: .outline, size: .md, fullWidth: true) {
                            withAnimation(.easeInOut(duration: 0.25)) {
                                currentStep -= 1
                            }
                        }
                    }

                    if currentStep < totalSteps - 1 {
                        ExButton(
                            title: currentStep == 0 ? "Get Started" : "Next",
                            variant: .accent,
                            size: .md,
                            fullWidth: true
                        ) {
                            // When leaving projects step, save selected projects
                            if currentStep == 3 {
                                saveSelectedProjects()
                            }
                            withAnimation(.easeInOut(duration: 0.25)) {
                                currentStep += 1
                            }
                        }
                    } else {
                        ExButton(
                            title: "Open exímIA Meter",
                            variant: .accent,
                            size: .lg,
                            icon: "arrow.right",
                            fullWidth: true
                        ) {
                            settings.hasCompletedOnboarding = true
                            onComplete()
                        }
                    }
                }
            }
            .padding(.horizontal, ExTokens.Spacing._32)
            .padding(.bottom, ExTokens.Spacing._24)
            .padding(.top, ExTokens.Spacing._8)
        }
        .frame(width: 520, height: 520)
        .background(ExTokens.Colors.backgroundPrimary)
    }

    private func saveSelectedProjects() {
        let discovered = ProjectDiscoveryService.discoverProjects()
        let selected = discovered.filter { selectedProjectNames.contains($0.name) }
        projects.addDiscoveredProjects(selected)
    }
}
