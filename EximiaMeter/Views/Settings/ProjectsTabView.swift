import SwiftUI

struct ProjectsTabView: View {
    @EnvironmentObject var appViewModel: AppViewModel

    private var projects: ProjectsViewModel {
        appViewModel.projectsViewModel
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(spacing: ExTokens.Spacing._8) {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Projects")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(ExTokens.Colors.textPrimary)

                        Text("Toggle visibility and reorder by dragging")
                            .font(ExTokens.Typography.caption)
                            .foregroundColor(ExTokens.Colors.textTertiary)
                    }

                    Spacer()

                    HStack(spacing: 8) {
                        actionButton(icon: "magnifyingglass", label: "Discover") {
                            projects.discoverProjects()
                        }

                        actionButton(icon: "plus", label: "Add") {
                            addProject()
                        }
                    }
                }
            }
            .padding(.horizontal, ExTokens.Spacing._24)
            .padding(.top, ExTokens.Spacing._24)
            .padding(.bottom, ExTokens.Spacing._12)

            // Divider
            Rectangle()
                .fill(ExTokens.Colors.borderDefault)
                .frame(height: 1)
                .padding(.horizontal, ExTokens.Spacing._16)

            // Project List
            if projects.projects.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "folder.badge.questionmark")
                        .font(.system(size: 28))
                        .foregroundColor(ExTokens.Colors.textMuted)

                    Text("No projects found")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(ExTokens.Colors.textTertiary)

                    Text("Click Discover to find projects from ~/.claude/")
                        .font(.system(size: 10))
                        .foregroundColor(ExTokens.Colors.textMuted)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List {
                    ForEach(Array(projects.projects.enumerated()), id: \.element.id) { index, project in
                        ProjectSettingsRow(
                            index: index + 1,
                            project: project,
                            onToggleVisibility: {
                                projects.toggleMainPage(for: project)
                            },
                            onModelChange: { model in
                                projects.updateModel(for: project, model: model)
                            },
                            onRemove: {
                                projects.removeProject(project)
                            }
                        )
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets(top: 2, leading: 16, bottom: 2, trailing: 16))
                    }
                    .onMove { source, destination in
                        projects.moveProject(from: source, to: destination)
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
            }
        }
    }

    private func actionButton(icon: String, label: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 9))
                Text(label)
                    .font(.system(size: 9, weight: .bold))
                    .textCase(.uppercase)
                    .tracking(0.5)
            }
            .foregroundColor(ExTokens.Colors.accentPrimary)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(ExTokens.Colors.accentPrimary.opacity(0.1))
            .overlay(
                RoundedRectangle(cornerRadius: ExTokens.Radius.sm)
                    .stroke(ExTokens.Colors.accentPrimary.opacity(0.2), lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: ExTokens.Radius.sm))
        }
        .buttonStyle(.plain)
    }

    private func addProject() {
        let panel = NSOpenPanel()
        panel.canChooseDirectories = true
        panel.canChooseFiles = false
        panel.allowsMultipleSelection = false
        panel.message = "Select a project directory"

        if panel.runModal() == .OK, let url = panel.url {
            projects.addProject(path: url.path)
        }
    }
}

struct ProjectSettingsRow: View {
    let index: Int
    let project: Project
    var onToggleVisibility: () -> Void
    var onModelChange: (ClaudeModel) -> Void
    var onRemove: () -> Void

    @State private var selectedModel: ClaudeModel
    @State private var isHovered = false

    init(index: Int, project: Project, onToggleVisibility: @escaping () -> Void, onModelChange: @escaping (ClaudeModel) -> Void, onRemove: @escaping () -> Void) {
        self.index = index
        self.project = project
        self.onToggleVisibility = onToggleVisibility
        self.onModelChange = onModelChange
        self.onRemove = onRemove
        self._selectedModel = State(initialValue: project.selectedModel)
    }

    var body: some View {
        HStack(spacing: 8) {
            // Visibility toggle
            Button(action: onToggleVisibility) {
                Image(systemName: project.showOnMainPage ? "eye.fill" : "eye.slash")
                    .font(.system(size: 11))
                    .foregroundColor(project.showOnMainPage ? ExTokens.Colors.accentPrimary : ExTokens.Colors.textMuted)
            }
            .buttonStyle(.plain)
            .help(project.showOnMainPage ? "Hide from main page" : "Show on main page")

            // Index
            Text("\(index)")
                .font(.system(size: 9, weight: .bold, design: .monospaced))
                .foregroundColor(ExTokens.Colors.textMuted)
                .frame(width: 14)

            // Drag handle
            Image(systemName: "line.3.horizontal")
                .font(.system(size: 8))
                .foregroundColor(ExTokens.Colors.textMuted)

            // Folder icon
            Image(systemName: "folder.fill")
                .font(.system(size: 12))
                .foregroundColor(Color(hex: "#3B82F6"))

            // Project info
            VStack(alignment: .leading, spacing: 1) {
                Text(project.name)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(ExTokens.Colors.textPrimary)

                Text(project.path)
                    .font(.system(size: 8, design: .monospaced))
                    .foregroundColor(ExTokens.Colors.textMuted)
                    .lineLimit(1)
                    .truncationMode(.middle)
            }

            Spacer()

            // Model picker
            ModelPickerView(selectedModel: $selectedModel, compact: true)
                .onChange(of: selectedModel) { _, newValue in
                    onModelChange(newValue)
                }

            // Remove button
            Button(action: onRemove) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 12))
                    .foregroundColor(isHovered ? ExTokens.Colors.statusCritical : ExTokens.Colors.textMuted)
            }
            .buttonStyle(.plain)
            .onHover { hovering in isHovered = hovering }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(
            project.showOnMainPage
                ? ExTokens.Colors.backgroundCard
                : Color.clear
        )
        .overlay(
            RoundedRectangle(cornerRadius: ExTokens.Radius.md)
                .stroke(
                    project.showOnMainPage ? ExTokens.Colors.borderDefault : Color.clear,
                    lineWidth: 1
                )
        )
        .clipShape(RoundedRectangle(cornerRadius: ExTokens.Radius.md))
    }
}
