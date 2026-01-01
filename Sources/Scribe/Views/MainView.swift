import SwiftUI

/// Main application view - Focus Mode with optional sidebars
/// Layout: [Left Sidebar?] | Editor + Stats Footer | [Right Sidebar?]
struct MainView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        HStack(spacing: 0) {
            // Left sidebar (notes/projects) - ⌘[
            if appState.showSidebar {
                LeftSidebarPlaceholder()
                    .frame(width: ScribeLayout.sidebarWidth)
                    .transition(.move(edge: .leading))
            }
            
            // Main content
            VStack(spacing: 0) {
                EditorView()
                StatsFooter()
            }
            .frame(maxWidth: .infinity)
            
            // Right sidebar (properties, outline, backlinks) - ⌘]
            if appState.showRightSidebar {
                RightSidebarPlaceholder()
                    .frame(width: ScribeLayout.sidebarWidth)
                    .transition(.move(edge: .trailing))
            }
        }
        .background(ScribeColors.background)
        .frame(
            minWidth: ScribeLayout.minWindowWidth,
            minHeight: ScribeLayout.minWindowHeight
        )
        .onAppear {
            if appState.notes.isEmpty {
                Task {
                    await appState.createNewNote()
                }
            }
        }
        .errorDialog(
            isPresented: $appState.showErrorDialog,
            title: appState.errorTitle,
            message: appState.errorMessage,
            level: appState.errorLevel == .error ? .error : .warning
        )
    }
}

// MARK: - Placeholder Sidebars (to be replaced with full implementation)

private struct LeftSidebarPlaceholder: View {
    var body: some View {
        VStack(alignment: .leading, spacing: ScribeSpacing.md) {
            Text("PROJECTS")
                .font(ScribeFonts.uiCaption)
                .foregroundColor(ScribeColors.textTertiary)
                .padding(.top, ScribeSpacing.md)
            
            Text("Coming soon...")
                .font(ScribeFonts.uiBody)
                .foregroundColor(ScribeColors.textSecondary)
            
            Spacer()
        }
        .padding(.horizontal, ScribeSpacing.sm)
        .frame(maxHeight: .infinity)
        .background(ScribeColors.surface)
    }
}

private struct RightSidebarPlaceholder: View {
    var body: some View {
        VStack(alignment: .leading, spacing: ScribeSpacing.md) {
            Text("PROPERTIES")
                .font(ScribeFonts.uiCaption)
                .foregroundColor(ScribeColors.textTertiary)
                .padding(.top, ScribeSpacing.md)
            
            Text("Coming soon...")
                .font(ScribeFonts.uiBody)
                .foregroundColor(ScribeColors.textSecondary)
            
            Spacer()
        }
        .padding(.horizontal, ScribeSpacing.sm)
        .frame(maxHeight: .infinity)
        .background(ScribeColors.surface)
    }
}

// MARK: - Preview

#Preview {
    MainView()
        .environmentObject(AppState(
            noteService: NoteService(database: DatabaseManager.shared),
            projectService: ProjectService(database: DatabaseManager.shared)
        ))
}
