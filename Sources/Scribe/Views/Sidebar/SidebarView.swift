import SwiftUI

/// Main left sidebar with projects and notes
struct SidebarView: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            HStack {
                Text("NOTES")
                    .font(ScribeFonts.uiCaption)
                    .foregroundColor(ScribeColors.textTertiary)
                
                Spacer()
                
                // New note button
                Button(action: {
                    Task {
                        await appState.createNewNote()
                    }
                }) {
                    Image(systemName: "plus")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(ScribeColors.textSecondary)
                }
                .buttonStyle(.plain)
                .help("New Note (⌘N)")
            }
            .padding(.horizontal, ScribeSpacing.sm)
            .padding(.vertical, ScribeSpacing.sm)
            
            Divider()
                .background(ScribeColors.border)
            
            // Project sections
            ScrollView {
                LazyVStack(alignment: .leading, spacing: ScribeSpacing.sm) {
                    ForEach(appState.projects) { project in
                        ProjectSection(
                            project: project,
                            notes: notesForProject(project.id),
                            selectedNoteId: appState.selectedNoteId,
                            onSelectNote: { noteId in
                                appState.selectedNoteId = noteId
                            },
                            onSelectProject: {
                                appState.selectedProjectId = project.id
                            },
                            onMoveNote: { noteId, projectId in
                                Task {
                                    await appState.moveNote(noteId, toProjectId: projectId)
                                }
                            }
                        )
                    }
                    
                    // Uncategorized notes (no project)
                    if !uncategorizedNotes.isEmpty {
                        UncategorizedSection(
                            notes: uncategorizedNotes,
                            selectedNoteId: appState.selectedNoteId,
                            onSelectNote: { noteId in
                                appState.selectedNoteId = noteId
                            },
                            onMoveNote: { noteId, _ in
                                Task {
                                    await appState.moveNote(noteId, toProjectId: nil)
                                }
                            }
                        )
                    }
                }
                .padding(.vertical, ScribeSpacing.sm)
            }
        }
        .background(ScribeColors.surface)
    }
    
    // MARK: - Helpers
    
    private func notesForProject(_ projectId: String) -> [Note] {
        appState.notes.filter { $0.projectId == projectId }
    }
    
    private var uncategorizedNotes: [Note] {
        appState.notes.filter { $0.projectId == nil }
    }
}

// MARK: - Uncategorized Section

private struct UncategorizedSection: View {
    let notes: [Note]
    let selectedNoteId: String?
    let onSelectNote: (String) -> Void
    let onMoveNote: (String, String) -> Void
    
    @State private var isExpanded = true
    @State private var isDropTargeted = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button(action: {
                withAnimation(.easeInOut(duration: 0.15)) {
                    isExpanded.toggle()
                }
            }) {
                HStack(spacing: ScribeSpacing.sm) {
                    Image(systemName: isExpanded ? "chevron.down" : "chevron.right")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(ScribeColors.textTertiary)
                        .frame(width: 12)
                    
                    Text("📥")
                        .font(.system(size: 14))
                    
                    Text("Uncategorized")
                        .font(ScribeFonts.uiTitle)
                        .foregroundColor(ScribeColors.textPrimary)
                    
                    Spacer()
                    
                    Text("\(notes.count)")
                        .font(ScribeFonts.uiCaption)
                        .foregroundColor(ScribeColors.textTertiary)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(ScribeColors.border.opacity(0.5))
                        .cornerRadius(4)
                }
                .padding(.vertical, ScribeSpacing.xs)
                .padding(.horizontal, ScribeSpacing.sm)
                .background(isDropTargeted ? ScribeColors.accent.opacity(0.2) : Color.clear)
                .cornerRadius(4)
            }
            .buttonStyle(.plain)
            .onDrop(of: [.text], isTargeted: $isDropTargeted) { providers, location in
                guard let provider = providers.first else { return false }
                
                provider.loadObject(ofClass: NSString.self) { string, error in
                    if let noteId = string as? String {
                        DispatchQueue.main.async {
                            onMoveNote(noteId, "")
                        }
                    }
                }
                return true
            }
            
            if isExpanded {
                ForEach(notes) { note in
                    NoteRow(
                        note: note,
                        isSelected: note.id == selectedNoteId,
                        onSelect: { onSelectNote(note.id) }
                    )
                    .padding(.leading, ScribeSpacing.lg)
                }
            }
        }
    }
}

// MARK: - Preview

#Preview {
    SidebarView()
        .frame(width: 250)
        .environmentObject(AppState(
            noteService: NoteService(database: DatabaseManager.shared),
            projectService: ProjectService(database: DatabaseManager.shared)
        ))
}
