import SwiftUI

/// Editor area with tabs and content
struct EditorArea: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        VStack(spacing: 0) {
            // Editor tabs
            if !appState.openTabs.isEmpty {
                EditorTabBar()
                Divider()
            }
            
            // Content
            Group {
                if let selectedNoteId = appState.selectedNoteId,
                   let note = appState.notes.first(where: { $0.id == selectedNoteId }) {
                    // Show note editor
                    HybridEditorView(note: note)
                } else {
                    // Show mission control
                    MissionControlView()
                }
            }
        }
    }
}

// MARK: - Editor Tab Bar

private struct EditorTabBar: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 0) {
                ForEach(appState.openTabs) { tab in
                    EditorTab(tab: tab)
                }
            }
        }
        .frame(height: 40)
        .background(Color(.controlBackgroundColor))
    }
}

private struct EditorTab: View {
    let tab: NoteTab
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        Button {
            appState.selectedNoteId = tab.noteId
            appState.activeTabId = tab.id
        } label: {
            HStack(spacing: 8) {
                // Note title
                Text(noteTitle)
                    .lineLimit(1)
                    .font(.system(size: 13))
                
                // Close button
                if !tab.isPinned {
                    Button {
                        appState.closeTab(tab.id)
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 10))
                            .foregroundColor(.secondary)
                    }
                    .buttonStyle(.plain)
                } else {
                    Image(systemName: "pin.fill")
                        .font(.system(size: 10))
                        .foregroundColor(.secondary)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(isActive ? Color.accentColor.opacity(0.1) : Color.clear)
            .overlay(
                Rectangle()
                    .frame(height: 2)
                    .foregroundColor(isActive ? .accentColor : .clear),
                alignment: .top
            )
        }
        .buttonStyle(.plain)
    }
    
    private var noteTitle: String {
        appState.notes.first(where: { $0.id == tab.noteId })?.title ?? "Untitled"
    }
    
    private var isActive: Bool {
        appState.activeTabId == tab.id
    }
}

#Preview {
    EditorArea()
        .environmentObject(AppState(noteService: NoteService(database: DatabaseManager.shared), projectService: ProjectService(database: DatabaseManager.shared)))
        .frame(width: 800, height: 600)
}
