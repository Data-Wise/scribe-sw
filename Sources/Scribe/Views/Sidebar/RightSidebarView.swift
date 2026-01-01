import SwiftUI

/// Right sidebar with tabs: Properties, Outline, Backlinks
struct RightSidebarView: View {
    @EnvironmentObject var appState: AppState
    @State private var selectedTab = 0
    
    var body: some View {
        VStack(spacing: 0) {
            // Tab picker
            Picker("", selection: $selectedTab) {
                Text("Properties").tag(0)
                Text("Outline").tag(1)
                Text("Backlinks").tag(2)
            }
            .pickerStyle(.segmented)
            .padding(ScribeSpacing.sm)
            
            Divider()
                .background(ScribeColors.border)
            
            // Tab content
            switch selectedTab {
            case 0:
                PropertiesPanel()
            case 1:
                OutlinePanel()
            case 2:
                BacklinksPanel()
            default:
                EmptyView()
            }
        }
        .background(ScribeColors.surface)
    }
}

// MARK: - Properties Panel

struct PropertiesPanel: View {
    @EnvironmentObject var appState: AppState
    
    private var currentNote: Note? {
        guard let id = appState.selectedNoteId else { return nil }
        return appState.notes.first { $0.id == id }
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: ScribeSpacing.md) {
                if let note = currentNote {
                    PropertyRow(label: "Words", value: "\(note.wordCount)")
                    PropertyRow(label: "Characters", value: "\(note.content.count)")
                    PropertyRow(label: "Created", value: formatDate(note.createdAt))
                    PropertyRow(label: "Modified", value: formatDate(note.updatedAt))
                    
                    Divider().background(ScribeColors.border)
                    
                    // Project assignment
                    VStack(alignment: .leading, spacing: ScribeSpacing.xs) {
                        Text("Project")
                            .font(ScribeFonts.uiCaption)
                            .foregroundColor(ScribeColors.textTertiary)
                        
                        Picker("Project", selection: projectBinding(for: note)) {
                            Text("None").tag(String?.none)
                            ForEach(appState.projects) { project in
                                Text("\(project.type.emoji) \(project.name)")
                                    .tag(Optional(project.id))
                            }
                        }
                        .labelsHidden()
                    }
                } else {
                    Text("No note selected")
                        .font(ScribeFonts.uiCaption)
                        .foregroundColor(ScribeColors.textTertiary)
                }
            }
            .padding(ScribeSpacing.sm)
        }
        .frame(maxHeight: .infinity)
    }
    
    private func formatDate(_ timestamp: Int64) -> String {
        let date = Date(unixTimestamp: timestamp)
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    private func projectBinding(for note: Note) -> Binding<String?> {
        Binding(
            get: { note.projectId },
            set: { newProjectId in
                if var updatedNote = appState.notes.first(where: { $0.id == note.id }) {
                    updatedNote.projectId = newProjectId
                    appState.saveNote(updatedNote)
                }
            }
        )
    }
}

// MARK: - Property Row

private struct PropertyRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .font(ScribeFonts.uiCaption)
                .foregroundColor(ScribeColors.textTertiary)
            Spacer()
            Text(value)
                .font(ScribeFonts.uiBody)
                .foregroundColor(ScribeColors.textSecondary)
        }
    }
}

// MARK: - Outline Panel

struct OutlinePanel: View {
    @EnvironmentObject var appState: AppState
    
    private var headings: [HeadingItem] {
        guard let id = appState.selectedNoteId,
              let note = appState.notes.first(where: { $0.id == id }) else {
            return []
        }
        return extractHeadings(from: note.content)
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: ScribeSpacing.xs) {
                if headings.isEmpty {
                    Text("No headings found")
                        .font(ScribeFonts.uiCaption)
                        .foregroundColor(ScribeColors.textTertiary)
                        .padding(ScribeSpacing.sm)
                } else {
                    ForEach(headings) { heading in
                        Text(heading.text)
                            .font(ScribeFonts.uiBody)
                            .foregroundColor(ScribeColors.textPrimary)
                            .padding(.leading, CGFloat(heading.level - 1) * 12)
                            .padding(.vertical, 2)
                    }
                }
            }
            .padding(ScribeSpacing.sm)
        }
        .frame(maxHeight: .infinity)
    }
    
    private func extractHeadings(from content: String) -> [HeadingItem] {
        let lines = content.components(separatedBy: "\n")
        var headings: [HeadingItem] = []
        
        for line in lines {
            if line.hasPrefix("# ") {
                headings.append(HeadingItem(level: 1, text: String(line.dropFirst(2))))
            } else if line.hasPrefix("## ") {
                headings.append(HeadingItem(level: 2, text: String(line.dropFirst(3))))
            } else if line.hasPrefix("### ") {
                headings.append(HeadingItem(level: 3, text: String(line.dropFirst(4))))
            } else if line.hasPrefix("#### ") {
                headings.append(HeadingItem(level: 4, text: String(line.dropFirst(5))))
            }
        }
        
        return headings
    }
}

private struct HeadingItem: Identifiable {
    let id = UUID()
    let level: Int
    let text: String
}

// MARK: - Backlinks Panel

struct BacklinksPanel: View {
    @EnvironmentObject var appState: AppState
    
    private var backlinks: [Note] {
        guard let id = appState.selectedNoteId,
              let currentNote = appState.notes.first(where: { $0.id == id }) else {
            return []
        }
        
        // Find notes that link to current note
        let titlePattern = "[[" + currentNote.title + "]]"
        return appState.notes.filter { note in
            note.id != id && note.content.contains(titlePattern)
        }
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: ScribeSpacing.xs) {
                if backlinks.isEmpty {
                    Text("No backlinks")
                        .font(ScribeFonts.uiCaption)
                        .foregroundColor(ScribeColors.textTertiary)
                        .padding(ScribeSpacing.sm)
                } else {
                    ForEach(backlinks) { note in
                        Button(action: {
                            appState.selectedNoteId = note.id
                        }) {
                            HStack {
                                Image(systemName: "arrow.turn.up.left")
                                    .font(.system(size: 10))
                                    .foregroundColor(ScribeColors.accent)
                                Text(note.title)
                                    .font(ScribeFonts.uiBody)
                                    .foregroundColor(ScribeColors.textPrimary)
                                    .lineLimit(1)
                            }
                            .padding(.vertical, 2)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding(ScribeSpacing.sm)
        }
        .frame(maxHeight: .infinity)
    }
}

// MARK: - Preview

#Preview {
    RightSidebarView()
        .frame(width: 250, height: 400)
        .environmentObject(AppState(
            noteService: NoteService(database: DatabaseManager.shared),
            projectService: ProjectService(database: DatabaseManager.shared)
        ))
}
