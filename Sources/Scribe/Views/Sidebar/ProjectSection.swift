import SwiftUI

/// Project section in sidebar with collapsible note list
struct ProjectSection: View {
    let project: Project
    let notes: [Note]
    let selectedNoteId: String?
    let onSelectNote: (String) -> Void
    let onSelectProject: () -> Void
    let onMoveNote: (String, String) -> Void
    
    @State private var isExpanded = true
    @State private var isDropTargeted = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Project header
            Button(action: {
                withAnimation(.easeInOut(duration: 0.15)) {
                    isExpanded.toggle()
                }
                onSelectProject()
            }) {
                HStack(spacing: ScribeSpacing.sm) {
                    // Expand/collapse indicator
                    Image(systemName: isExpanded ? "chevron.down" : "chevron.right")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(ScribeColors.textTertiary)
                        .frame(width: 12)
                    
                    // Project emoji + name
                    Text(project.type.emoji)
                        .font(.system(size: 14))
                    
                    Text(project.name)
                        .font(ScribeFonts.uiTitle)
                        .foregroundColor(ScribeColors.textPrimary)
                        .lineLimit(1)
                    
                    Spacer()
                    
                    // Note count
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
            // .onDrop(of: [.text], isTargeted: $isDropTargeted) { providers, location in
            //     guard let provider = providers.first else { return false }
            //     
            //     provider.loadObject(ofClass: NSString.self) { string, error in
            //         if let noteId = string as? String {
            //             DispatchQueue.main.async {
            //                 onMoveNote(noteId, project.id)
            //             }
            //         }
            //     }
            //     return true
            // }
            
            // Notes list (collapsible)
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
    let project = Project(name: "Research", type: .research)
    let notes = [
        Note(title: "Introduction", content: "Background info", wordCount: 150),
        Note(title: "Methods", content: "Study design", wordCount: 280),
        Note(title: "Results", content: "Findings here", wordCount: 420)
    ]
    
    return ProjectSection(
        project: project,
        notes: notes,
        selectedNoteId: notes[1].id,
        onSelectNote: { _ in },
        onSelectProject: {},
        onMoveNote: { _, _ in }
    )
    .padding()
    .background(ScribeColors.surface)
}
