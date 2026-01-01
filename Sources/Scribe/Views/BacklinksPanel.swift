import SwiftUI

/// Backlinks panel showing notes that link to current note
struct BacklinksPanel: View {
    let note: Note
    @EnvironmentObject var appState: AppState
    @State private var backlinks: [Note] = []
    @State private var isLoading = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                Label("Backlinks", systemImage: "link")
                    .font(.headline)
                
                Spacer()
                
                if isLoading {
                    ProgressView()
                        .scaleEffect(0.7)
                } else {
                    Text("\(backlinks.count)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 12)
            
            Divider()
            
            // Backlinks list
            if backlinks.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "link.slash")
                        .font(.largeTitle)
                        .foregroundColor(.secondary)
                    Text("No backlinks")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 32)
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(backlinks) { backlink in
                            BacklinkRow(note: backlink)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                }
            }
            Spacer()
        }
        .frame(width: 300)
        .background(Color(.controlBackgroundColor))
        .task {
            await loadBacklinks()
        }
        .onChange(of: note.id) { _, _ in
            Task { await loadBacklinks() }
        }
    }
    
    private func loadBacklinks() async {
        isLoading = true
        defer { isLoading = false }
        
        backlinks = await appState.backlinks(for: note.id)
    }
}

private struct BacklinkRow: View {
    let note: Note
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        Button {
            appState.openNote(note)
        } label: {
            HStack(alignment: .top, spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(note.title)
                        .font(.body)
                        .foregroundColor(.primary)
                        .lineLimit(1)
                    
                    Text(note.preview)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                    
                    // Tags
                    if !note.tags.isEmpty {
                        HStack(spacing: 4) {
                            ForEach(note.tags.prefix(3), id: \.self) { tag in
                                Text(tag)
                                    .font(.caption2)
                                    .padding(.horizontal, 4)
                                    .padding(.vertical, 2)
                                    .background(Color.accentColor.opacity(0.1))
                                    .cornerRadius(3)
                            }
                        }
                    }
                }
                
                Spacer()
                
                // Modified date
                Text(note.modifiedDate.formatted(.relative(presentation: .named)))
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .background(Color(.controlBackgroundColor))
            .cornerRadius(6)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    BacklinksPanel(note: Note(
        title: "Mediation Analysis",
        content: "Statistical mediation..."
    ))
    .environmentObject(AppState(
        noteService: NoteService(database: DatabaseManager.shared),
        projectService: ProjectService(database: DatabaseManager.shared)
    ))
    .frame(height: 400)
}
