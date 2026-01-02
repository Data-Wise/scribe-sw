import SwiftUI

/// Individual note row in sidebar
struct NoteRow: View {
    let note: Note
    let isSelected: Bool
    let onSelect: () -> Void

    var body: some View {
        Button(action: onSelect) {
            VStack(alignment: .leading, spacing: ScribeSpacing.xs) {
                // Title
                Text(note.title.isEmpty ? "Untitled" : note.title)
                    .font(ScribeFonts.uiBody)
                    .foregroundColor(isSelected ? ScribeColors.accent : ScribeColors.textPrimary)
                    .lineLimit(1)
                
                // Preview + metadata
                HStack {
                    Text(note.preview.isEmpty ? "No content" : note.preview)
                        .font(ScribeFonts.uiCaption)
                        .foregroundColor(ScribeColors.textTertiary)
                        .lineLimit(1)
                    
                    Spacer()
                    
                    Text("\(note.wordCount)w")
                        .font(ScribeFonts.uiCaption)
                        .foregroundColor(ScribeColors.textTertiary)
                }
            }
            .padding(.vertical, ScribeSpacing.xs)
            .padding(.horizontal, ScribeSpacing.sm)
            .background(isSelected ? ScribeColors.accent.opacity(0.15) : Color.clear)
            .cornerRadius(4)
        }
        .buttonStyle(.plain)
        // .onDrag {
        //     NSItemProvider(object: note.id as NSString)
        // }
    }
}

// MARK: - Preview

#Preview {
    VStack {
        NoteRow(
            note: Note(title: "My First Note", content: "Some preview content here", wordCount: 42),
            isSelected: false,
            onSelect: {}
        )
        NoteRow(
            note: Note(title: "Selected Note", content: "This one is selected", wordCount: 128),
            isSelected: true,
            onSelect: {}
        )
    }
    .padding()
    .background(ScribeColors.surface)
}
